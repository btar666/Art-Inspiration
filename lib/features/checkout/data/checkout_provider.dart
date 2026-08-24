import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/onboarding_storage.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../settings/data/models/delivery_address_model.dart';
import '../../settings/presentation/providers/saved_addresses_provider.dart';

/// طريقة استلام الطلب
enum CheckoutDeliveryMethod {
  pickupAtCompany,
  delivery,
}

extension CheckoutDeliveryMethodX on CheckoutDeliveryMethod {
  String get label {
    switch (this) {
      case CheckoutDeliveryMethod.pickupAtCompany:
        return 'استلام في الشركة';
      case CheckoutDeliveryMethod.delivery:
        return 'توصيل';
    }
  }
}

/// مسودة الطلب أثناء عملية الشراء
class CheckoutDraft {
  const CheckoutDraft({
    required this.items,
    this.customerName = '',
    this.phone = '',
    this.secondPhone = '',
    this.deliveryMethod = CheckoutDeliveryMethod.delivery,
    this.selectedAddress,
  });

  final List<CartItemModel> items;
  final String customerName;
  final String phone;
  final String secondPhone;
  final CheckoutDeliveryMethod deliveryMethod;
  final DeliveryAddressModel? selectedAddress;

  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasItems => items.isNotEmpty;

  bool get requiresAddress =>
      deliveryMethod == CheckoutDeliveryMethod.delivery;

  bool get hasAddress => !requiresAddress || selectedAddress != null;

  String get deliveryAddressLabel {
    if (deliveryMethod == CheckoutDeliveryMethod.pickupAtCompany) {
      return CheckoutDeliveryMethod.pickupAtCompany.label;
    }
    return selectedAddress?.fullAddress ?? '';
  }

  CheckoutDraft copyWith({
    List<CartItemModel>? items,
    String? customerName,
    String? phone,
    String? secondPhone,
    CheckoutDeliveryMethod? deliveryMethod,
    DeliveryAddressModel? selectedAddress,
    bool clearAddress = false,
  }) {
    return CheckoutDraft(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      secondPhone: secondPhone ?? this.secondPhone,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      selectedAddress:
          clearAddress ? null : (selectedAddress ?? this.selectedAddress),
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutDraft?> {
  @override
  CheckoutDraft? build() => null;

  void startFromCart(List<CartItemModel> items) {
    if (items.isEmpty) {
      state = null;
      return;
    }
    final addresses = ref.read(savedAddressesNotifierProvider);
    state = CheckoutDraft(
      items: List.of(items),
      deliveryMethod: CheckoutDeliveryMethod.delivery,
      selectedAddress: DeliveryAddressModel.currentFrom(addresses),
    );
    syncFromProfileAndAddress();
  }

  /// يحدّث الاسم والهاتف من البروفايل والعنوان من «العنوان الحالي» المحفوظ
  void syncFromProfileAndAddress() {
    if (state == null) return;

    final user = ref.read(authNotifierProvider).user;
    final addresses = ref.read(savedAddressesNotifierProvider);
    final currentAddress = DeliveryAddressModel.currentFrom(addresses);
    final saved = ref.read(checkoutCustomerStorageProvider).load();
    final isDelivery =
        state!.deliveryMethod == CheckoutDeliveryMethod.delivery;

    final userName = user?.name.trim() ?? '';
    final userPhone = (user?.phone ?? '').trim();

    state = state!.copyWith(
      customerName: userName.isNotEmpty ? userName : saved.name,
      phone: userPhone.isNotEmpty ? userPhone : saved.phone,
      secondPhone: saved.secondPhone,
      selectedAddress: isDelivery ? currentAddress : null,
      clearAddress: isDelivery && currentAddress == null,
    );
  }

  void setDeliveryMethod(CheckoutDeliveryMethod method) {
    if (state == null) return;

    if (method == CheckoutDeliveryMethod.pickupAtCompany) {
      state = state!.copyWith(
        deliveryMethod: method,
        clearAddress: true,
      );
      return;
    }

    final current =
        DeliveryAddressModel.currentFrom(ref.read(savedAddressesNotifierProvider));
    state = state!.copyWith(
      deliveryMethod: method,
      selectedAddress: current,
      clearAddress: current == null,
    );
  }

  void updateCustomerInfo({
    required String name,
    required String phone,
    String? secondPhone,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      customerName: name.trim(),
      phone: phone.trim(),
      secondPhone: secondPhone?.trim() ?? '',
    );
  }

  void selectAddress(DeliveryAddressModel address) {
    if (state == null) return;
    state = state!.copyWith(selectedAddress: address);
  }

  void clear() => state = null;
}

final checkoutDraftProvider =
    NotifierProvider<CheckoutNotifier, CheckoutDraft?>(CheckoutNotifier.new);

String formatIraqiPrice(int value) {
  final formatted = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$formatted د.ع';
}

/// حفظ بيانات الزبون للطلبات التالية
class CheckoutCustomerStorage {
  CheckoutCustomerStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _nameKey = 'checkout_customer_name';
  static const _phoneKey = 'checkout_customer_phone';
  static const _secondPhoneKey = 'checkout_customer_second_phone';

  ({String name, String phone, String secondPhone}) load() => (
        name: _prefs.getString(_nameKey) ?? '',
        phone: _prefs.getString(_phoneKey) ?? '',
        secondPhone: _prefs.getString(_secondPhoneKey) ?? '',
      );

  Future<void> save({
    required String name,
    required String phone,
    String secondPhone = '',
  }) async {
    await _prefs.setString(_nameKey, name);
    await _prefs.setString(_phoneKey, phone);
    await _prefs.setString(_secondPhoneKey, secondPhone);
  }
}

final checkoutCustomerStorageProvider = Provider<CheckoutCustomerStorage>((ref) {
  return CheckoutCustomerStorage(ref.watch(sharedPreferencesProvider));
});
