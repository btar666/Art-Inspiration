import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../data/models/delivery_address_model.dart';
import '../providers/saved_addresses_provider.dart';
import '../widgets/address_form_bottom_sheet.dart';
import '../widgets/saved_address_card_widget.dart';
import '../widgets/settings_bottom_bar.dart';

/// صفحة عناوين التوصيل المحفوظة
class SavedAddressesPage extends ConsumerWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(savedAddressesNotifierProvider);
    final isEmpty = addresses.isEmpty;
    final notifier = ref.read(savedAddressesNotifierProvider.notifier);

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
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.orderCardDivider.withValues(
                          alpha: 0.75,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return SavedAddressCardWidget(
                          address: address,
                          onEdit: () => _onEditAddress(
                            context,
                            notifier,
                            address,
                          ),
                          onDelete: () => notifier.removeAddress(address.id),
                        );
                      },
                    ),
            ),
            SettingsBottomBar(
              label: isEmpty ? 'أضافة عنوان' : 'أضافة عنوان جديد',
              onTap: () => _onAddAddress(context, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddAddress(
    BuildContext context,
    SavedAddressesNotifier notifier,
  ) async {
    final result = await AddressFormBottomSheet.showAdd(context);
    if (result == null) return;
    notifier.addAddress(result);
  }

  Future<void> _onEditAddress(
    BuildContext context,
    SavedAddressesNotifier notifier,
    DeliveryAddressModel address,
  ) async {
    final result = await AddressFormBottomSheet.showEdit(
      context,
      governorate: address.governorate,
      area: address.area,
      landmark: address.landmark,
      lat: address.lat,
      lng: address.lng,
    );
    if (result == null) return;
    notifier.updateAddress(address.id, result);
  }
}
