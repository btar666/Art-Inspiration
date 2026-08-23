import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../providers/saved_addresses_provider.dart';
import '../widgets/address_form_bottom_sheet.dart';
import '../widgets/saved_address_card_widget.dart';
import '../widgets/settings_bottom_bar.dart';

/// اختيار عنوان للطلب — مثل التطبيق القديم
class SelectAddressForOrderPage extends ConsumerStatefulWidget {
  const SelectAddressForOrderPage({super.key});

  @override
  ConsumerState<SelectAddressForOrderPage> createState() =>
      _SelectAddressForOrderPageState();
}

class _SelectAddressForOrderPageState
    extends ConsumerState<SelectAddressForOrderPage> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addresses = ref.read(savedAddressesNotifierProvider);
      if (addresses.isEmpty || !mounted) return;
      final current = addresses.where((a) => a.isCurrent).firstOrNull;
      setState(() => _selectedId = (current ?? addresses.first).id);
    });
  }

  Future<void> _onAddAddress() async {
    final result = await AddressFormBottomSheet.showAdd(context);
    if (result == null) return;

    ref.read(savedAddressesNotifierProvider.notifier).addAddress(result);
    final addresses = ref.read(savedAddressesNotifierProvider);
    if (addresses.isNotEmpty) {
      setState(() => _selectedId = addresses.last.id);
    }
  }

  void _confirmSelection() {
    if (_selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان')),
      );
      return;
    }

    ref.read(savedAddressesNotifierProvider.notifier).setCurrentAddress(_selectedId!);

    final updated = ref.read(savedAddressesNotifierProvider);
    for (final address in updated) {
      if (address.id == _selectedId) {
        context.pop(address);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(savedAddressesNotifierProvider);
    final isEmpty = addresses.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'اختر العنوان',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: isEmpty
                  ? const SettingsEmptyState(
                      title: 'لا توجد عناوين محفوظة',
                      imageAsset: AppAssets.noAddressesIllustration,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                      physics: const ClampingScrollPhysics(),
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final isSelected = _selectedId == address.id;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _selectedId = address.id),
                          child: SavedAddressCardWidget(
                            address: address,
                            selectionMode: true,
                            isSelected: isSelected,
                            onEdit: () {},
                            onDelete: () {},
                          ),
                        );
                      },
                    ),
            ),
            if (!isEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextButton(
                  onPressed: _onAddAddress,
                  child: const Text('أضافة عنوان جديد'),
                ),
              ),
              SettingsBottomBar(
                label: 'اختيار',
                onTap: _confirmSelection,
              ),
            ] else
              SettingsBottomBar(
                label: 'أضافة عنوان',
                onTap: _onAddAddress,
              ),
          ],
        ),
      ),
    );
  }
}
