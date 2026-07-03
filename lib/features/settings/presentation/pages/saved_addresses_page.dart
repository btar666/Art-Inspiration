import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../data/models/delivery_address_model.dart';
import '../../data/saved_addresses_mock_data.dart';
import '../widgets/address_form_bottom_sheet.dart';
import '../widgets/saved_address_card_widget.dart';
import '../widgets/settings_bottom_bar.dart';

/// صفحة عناوين التوصيل المحفوظة
class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  late List<DeliveryAddressModel> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = List.of(SavedAddressesMockData.initial());
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _addresses.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'عناوين التوصيل المحفوظة',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: isEmpty
                  ? const SettingsEmptyState(
                      title: 'لا توجد عناوين محفوظة',
                      icon: Icons.location_on_outlined,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.orderCardDivider.withValues(
                          alpha: 0.75,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        return SavedAddressCardWidget(
                          address: address,
                          onEdit: () => _onEditAddress(address),
                          onDelete: () => _deleteAddress(address.id),
                        );
                      },
                    ),
            ),
            SettingsBottomBar(
              label: isEmpty ? 'أضافة عنوان' : 'أضافة عنوان جديد',
              onTap: _onAddAddress,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddAddress() async {
    final result = await AddressFormBottomSheet.showAdd(context);
    if (result == null) return;

    setState(() {
      final isFirst = _addresses.isEmpty;
      _addresses.add(
        DeliveryAddressModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          governorate: result.governorate,
          area: result.area,
          landmark: result.landmark,
          lat: result.lat,
          lng: result.lng,
          isCurrent: isFirst,
        ),
      );
    });
  }

  Future<void> _onEditAddress(DeliveryAddressModel address) async {
    final result = await AddressFormBottomSheet.showEdit(
      context,
      governorate: address.governorate,
      area: address.area,
      landmark: address.landmark,
      lat: address.lat,
      lng: address.lng,
    );
    if (result == null) return;

    setState(() {
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index == -1) return;
      _addresses[index] = address.copyWith(
        governorate: result.governorate,
        area: result.area,
        landmark: result.landmark,
        lat: result.lat,
        lng: result.lng,
      );
    });
  }

  void _deleteAddress(String id) {
    setState(() {
      final wasCurrent = _addresses.any((a) => a.id == id && a.isCurrent);
      _addresses.removeWhere((a) => a.id == id);
      if (wasCurrent && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isCurrent: true);
      }
    });
  }
}
