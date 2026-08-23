import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/aman_rest_api.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/models/erp_price_policy.dart';
import '../../auth/data/auth_storage.dart';
import '../../auth/data/models/auth_models.dart';

final erpPartyResolverProvider = Provider<ErpPartyResolver>((ref) {
  return ErpPartyResolver(
    api: ref.watch(amanRestApiProvider),
    authStorage: ref.watch(authStorageProvider),
  );
});

/// ربط زبون التطبيق بعميل أمان ERP (`party_id`)
class ErpPartyResolver {
  ErpPartyResolver({
    required AmanRestApi api,
    required AuthStorage authStorage,
  })  : _api = api,
        _authStorage = authStorage;

  final AmanRestApi _api;
  final AuthStorage _authStorage;

  /// جلب `price_policy` من سجل العميل في أمان ERP
  Future<ErpPricePolicy> fetchPricePolicy({
    String? phone,
    String? name,
    bool createIfMissing = true,
  }) async {
    final partyId = await resolve(
      phone: phone,
      name: name,
      createIfMissing: createIfMissing,
    );
    final customer = await _api.getById(ApiEndpoints.customer(partyId));
    return ErpPricePolicy.fromErp(customer['price_policy']?.toString());
  }

  /// يعيد `party_id` من `id_erp` أو بالبحث/الإنشاء عبر الهاتف في أمان ERP
  Future<int> resolve({
    String? phone,
    String? name,
    bool createIfMissing = true,
  }) async {
    final user = _authStorage.user;
    final stored = int.tryParse(user?.erpId?.trim() ?? '');
    if (stored != null && stored > 0) return stored;

    final lookupPhone = _digitsOnly(
      (phone?.trim().isNotEmpty == true) ? phone!.trim() : (user?.phone ?? ''),
    );
    if (lookupPhone.isEmpty) {
      throw const ApiException(
        message: 'لا يمكن ربط الفاتورة بالعميل — رقم الهاتف غير متوفر',
      );
    }

    final existing = await _findCustomerIdByPhone(lookupPhone);
    if (existing != null) {
      await _persistErpId(user, existing);
      return existing;
    }

    if (!createIfMissing) {
      throw const ApiException(
        message: 'لا يوجد عميل مرتبط في أمان ERP لهذا الحساب',
      );
    }

    final createdId = await _createCustomer(
      name: (name?.trim().isNotEmpty == true)
          ? name!.trim()
          : (user?.name.trim().isNotEmpty == true ? user!.name : 'عميل'),
      phone: lookupPhone,
    );
    await _persistErpId(user, createdId);
    return createdId;
  }

  Future<int?> _findCustomerIdByPhone(String phone) async {
    for (final candidate in _phoneCandidates(phone)) {
      final result = await _api.list(
        path: ApiEndpoints.customers,
        page: 1,
        perPage: 20,
        query: {'phone': candidate},
      );
      final id = _firstCustomerId(result.items, preferredPhone: phone);
      if (id != null) return id;

      final byQuery = await _api.list(
        path: ApiEndpoints.customers,
        page: 1,
        perPage: 20,
        query: {'q': candidate},
      );
      final qId = _firstCustomerId(byQuery.items, preferredPhone: phone);
      if (qId != null) return qId;
    }
    return null;
  }

  Future<int> _createCustomer({
    required String name,
    required String phone,
  }) async {
    final created = await _api.create(
      path: ApiEndpoints.customers,
      body: {
        'name': name,
        'phone': phone,
        'type': 'customer',
        'price_policy': 'retail',
        'is_active': true,
      },
    );

    final id = int.tryParse((created['id'] ?? '').toString());
    if (id == null || id <= 0) {
      throw const ApiException(message: 'تعذر إنشاء عميل في أمان ERP');
    }
    return id;
  }

  Future<void> _persistErpId(AuthUser? user, int partyId) async {
    if (user == null) return;
    final updated = user.copyWith(erpId: partyId.toString());
    await _authStorage.saveUser(updated);
  }

  int? _firstCustomerId(
    List<Map<String, dynamic>> items, {
    required String preferredPhone,
  }) {
    if (items.isEmpty) return null;

    final preferredDigits = _digitsOnly(preferredPhone);
    for (final item in items) {
      final itemPhone = _digitsOnly((item['phone'] ?? '').toString());
      if (itemPhone.isNotEmpty &&
          (itemPhone == preferredDigits ||
              itemPhone.endsWith(preferredDigits) ||
              preferredDigits.endsWith(itemPhone))) {
        final id = int.tryParse((item['id'] ?? '').toString());
        if (id != null && id > 0) return id;
      }
    }

    final first = int.tryParse((items.first['id'] ?? '').toString());
    return (first != null && first > 0) ? first : null;
  }

  List<String> _phoneCandidates(String phone) {
    final digits = _digitsOnly(phone);
    final candidates = <String>{digits};

    if (digits.startsWith('0') && digits.length > 1) {
      candidates.add(digits.substring(1));
      candidates.add('964${digits.substring(1)}');
    } else if (digits.startsWith('964')) {
      candidates.add('0${digits.substring(3)}');
      candidates.add(digits.substring(3));
    } else if (digits.startsWith('7')) {
      candidates.add('0$digits');
      candidates.add('964$digits');
    }

    return candidates.where((e) => e.isNotEmpty).toList();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}
