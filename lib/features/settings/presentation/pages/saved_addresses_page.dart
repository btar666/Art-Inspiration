import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../cart/presentation/widgets/cart_checkout_footer.dart';
import '../../data/models/delivery_address_model.dart';
import '../providers/saved_addresses_provider.dart';
import '../widgets/address_delete_confirm_dialog.dart';
import '../widgets/address_form_bottom_sheet.dart';
import '../widgets/saved_address_card_widget.dart';
import '../widgets/saved_addresses_page_metrics.dart';
import '../widgets/settings_bottom_bar.dart';

/// صفحة عناوين التوصيل المحفوظة
class SavedAddressesPage extends ConsumerStatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  ConsumerState<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends ConsumerState<SavedAddressesPage> {
  String? _selectedId;

  /// عند الفتح من صفحة الطلب — اختيار عنوان والعودة به
  bool _selectForOrder(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    return extra == true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_selectForOrder(context)) return;
      final addresses = ref.read(savedAddressesNotifierProvider);
      if (addresses.isEmpty || !mounted) return;
      final current = addresses.where((a) => a.isCurrent).firstOrNull;
      setState(() => _selectedId = (current ?? addresses.first).id);
    });
  }

  Future<void> _onAddAddress() async {
    final selectForOrder = _selectForOrder(context);
    final result = await AddressFormBottomSheet.showAddDialog(context);
    if (result == null) return;

    final notifier = ref.read(savedAddressesNotifierProvider.notifier);
    notifier.addAddress(result);

    if (!selectForOrder || !mounted) return;

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

    ref
        .read(savedAddressesNotifierProvider.notifier)
        .setCurrentAddress(_selectedId!);

    final updated = ref.read(savedAddressesNotifierProvider);
    for (final address in updated) {
      if (address.id == _selectedId) {
        context.pop(address);
        return;
      }
    }
  }

  Future<void> _onEditAddress(DeliveryAddressModel address) async {
    final notifier = ref.read(savedAddressesNotifierProvider.notifier);
    final result = await AddressFormBottomSheet.showEditDialog(
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

  Future<void> _confirmDeleteAddress(String id) async {
    final confirmed = await AddressDeleteConfirmDialog.show(context);
    if (!confirmed || !mounted) return;

    final notifier = ref.read(savedAddressesNotifierProvider.notifier);
    notifier.removeAddress(id);

    if (_selectedId != id) return;

    final remaining = ref.read(savedAddressesNotifierProvider);
    setState(() {
      _selectedId = remaining.isEmpty ? null : remaining.first.id;
    });
  }

  Widget _buildFooter({
    required bool isEmpty,
    required bool selectForOrder,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight =
        screenHeight * SavedAddressesPageMetrics.footerHeightFraction;

    String label;
    VoidCallback onTap;

    if (selectForOrder) {
      if (isEmpty) {
        label = 'أضافة عنوان';
        onTap = _onAddAddress;
      } else {
        label = 'اختيار';
        onTap = _confirmSelection;
      }
    } else {
      label = isEmpty ? 'أضافة عنوان' : 'أضافة عنوان جديد';
      onTap = _onAddAddress;
    }

    return SizedBox(
      height: footerHeight,
      child: ColoredBox(
        color: SavedAddressesPageMetrics.pageBackground,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: SavedAddressesPageMetrics.footerPadding(),
            child: Transform.translate(
              offset: SavedAddressesPageMetrics.footerButtonOffset(),
              child: CartCheckoutFooter(
                label: label,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(savedAddressesNotifierProvider);
    final isEmpty = addresses.isEmpty;
    final notifier = ref.read(savedAddressesNotifierProvider.notifier);
    final selectForOrder = _selectForOrder(context);
    final bottomRadius = SavedAddressesPageMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: SavedAddressesPageMetrics.pageBackground,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
                child: SafeArea(
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
                                padding:
                                    SavedAddressesPageMetrics.listPadding(),
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
                                  final isSelected = _selectedId == address.id;

                                  if (selectForOrder) {
                                    return SavedAddressCardWidget(
                                      address: address,
                                      selectionMode: true,
                                      isSelected: isSelected,
                                      onSelect: () => setState(
                                        () => _selectedId = address.id,
                                      ),
                                      onEdit: () => _onEditAddress(address),
                                      onDelete: () =>
                                          _confirmDeleteAddress(address.id),
                                    );
                                  }

                                  return SavedAddressCardWidget(
                                    address: address,
                                    onSelect: () =>
                                        notifier.setCurrentAddress(address.id),
                                    onEdit: () => _onEditAddress(address),
                                    onDelete: () =>
                                        _confirmDeleteAddress(address.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildFooter(
            isEmpty: isEmpty,
            selectForOrder: selectForOrder,
          ),
        ],
      ),
    );
  }
}
