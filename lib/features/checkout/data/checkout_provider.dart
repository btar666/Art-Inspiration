import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/onboarding_storage.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../settings/data/models/delivery_address_model.dart';
import '../../settings/presentation/providers/saved_addresses_provider.dart';

/// مسودة الطلب أثناء عملية الشراء
class CheckoutDraft {
  const CheckoutDraft({
    required this.items,
    this.customerName = '',
    this.phone = '',
    this.secondPhone = '',
    this.selectedAddress,
  });

  final List<CartItemModel> items;
  final String customerName;
  final String phone;
  final String secondPhone;
  final DeliveryAddressModel? selectedAddress;

  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasItems => items.isNotEmpty;

  bool get hasAddress => selectedAddress != null;

  CheckoutDraft copyWith({
    List<CartItemModel>? items,
    String? customerName,
    String? phone,
    String? secondPhone,
    DeliveryAddressModel? selectedAddress,
    bool clearAddress = false,
  }) {
    return CheckoutDraft(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      secondPhone: secondPhone ?? this.secondPhone,
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
      selectedAddress: DeliveryAddressModel.currentFrom(addresses),
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
