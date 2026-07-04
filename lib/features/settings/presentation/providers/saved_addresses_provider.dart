import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/delivery_address_model.dart';
import '../../data/saved_addresses_storage.dart';

/// حالة عناوين التوصيل المحفوظة
class SavedAddressesNotifier extends Notifier<List<DeliveryAddressModel>> {
  @override
  List<DeliveryAddressModel> build() {
    return ref.read(savedAddressesStorageProvider).loadAddresses();
  }

  Future<void> _persist() =>
      ref.read(savedAddressesStorageProvider).saveAddresses(state);

  void addAddress(AddressFormResult result) {
    final isFirst = state.isEmpty;
    final address = DeliveryAddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      governorate: result.governorate,
      area: result.area,
      landmark: result.landmark,
      lat: result.lat,
      lng: result.lng,
      isCurrent: isFirst,
    );
    state = [...state, address];
    _persist();
  }

  void updateAddress(String id, AddressFormResult result) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final items = [...state];
    items[index] = items[index].copyWith(
      governorate: result.governorate,
      area: result.area,
      landmark: result.landmark,
      lat: result.lat,
      lng: result.lng,
    );
    state = items;
    _persist();
  }

  void setCurrentAddress(String id) {
    state = [
      for (final address in state)
        address.copyWith(isCurrent: address.id == id),
    ];
    _persist();
  }

  void removeAddress(String id) {
    final wasCurrent = state.any((a) => a.id == id && a.isCurrent);
    var items = state.where((a) => a.id != id).toList();

    if (wasCurrent && items.isNotEmpty) {
      items = [
        items[0].copyWith(isCurrent: true),
        ...items.skip(1),
      ];
    }

    state = items;
    _persist();
  }
}

final savedAddressesNotifierProvider =
    NotifierProvider<SavedAddressesNotifier, List<DeliveryAddressModel>>(
  SavedAddressesNotifier.new,
);
