import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../settings/data/models/delivery_address_model.dart';
import '../../../cart/presentation/widgets/cart_checkout_footer.dart';
import '../../../cart/presentation/widgets/cart_page_metrics.dart';
import '../../../settings/presentation/providers/saved_addresses_provider.dart';
import '../../../settings/presentation/widgets/address_form_bottom_sheet.dart';
import '../../data/checkout_provider.dart';
import '../widgets/checkout_field_metrics.dart';

/// الخطوة 1 — معلومات الزبون والعنوان
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _secondPhoneController = TextEditingController();
  int _nameShakeTick = 0;
  int _phoneShakeTick = 0;
  int _addressShakeTick = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(checkoutCustomerStorageProvider).load();
      final draft = ref.read(checkoutDraftProvider);
      _nameController.text = draft?.customerName.isNotEmpty == true
          ? draft!.customerName
          : saved.name;
      _phoneController.text =
          draft?.phone.isNotEmpty == true ? draft!.phone : saved.phone;
      _secondPhoneController.text = draft?.secondPhone.isNotEmpty == true
          ? draft!.secondPhone
          : saved.secondPhone;
      _applyDefaultAddress();
    });
  }

  void _applyDefaultAddress() {
    final draft = ref.read(checkoutDraftProvider);
    if (draft?.selectedAddress != null) return;

    final current =
        DeliveryAddressModel.currentFrom(ref.read(savedAddressesNotifierProvider));
    if (current == null) return;

    ref.read(checkoutDraftProvider.notifier).selectAddress(current);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _secondPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final selected = await context.push<DeliveryAddressModel>(
      AppRoutes.settingsAddresses,
      extra: true,
    );
    if (selected == null || !mounted) return;
    ref.read(checkoutDraftProvider.notifier).selectAddress(selected);
    setState(() {});
  }

  Future<void> _onAddNewAddress() async {
    final result = await AddressFormBottomSheet.showAddDialog(context);
    if (result == null || !mounted) return;

    final notifier = ref.read(savedAddressesNotifierProvider.notifier);
    notifier.addAddress(result);

    final addresses = ref.read(savedAddressesNotifierProvider);
    if (addresses.isEmpty) return;

    ref.read(checkoutDraftProvider.notifier).selectAddress(addresses.last);
    setState(() {});
  }

  void _onNext() {
    _formKey.currentState!.validate();
    final nameInvalid = _nameController.text.trim().isEmpty;
    final phoneInvalid = _phoneController.text.trim().length < 10;
    final draft = ref.read(checkoutDraftProvider);
    final addressInvalid = draft?.selectedAddress == null;

    if (nameInvalid || phoneInvalid || addressInvalid) {
      setState(() {
        if (nameInvalid) _nameShakeTick++;
        if (phoneInvalid) _phoneShakeTick++;
        if (addressInvalid) _addressShakeTick++;
      });
      return;
    }

    ref.read(checkoutDraftProvider.notifier).updateCustomerInfo(
          name: _nameController.text,
          phone: _phoneController.text,
          secondPhone: _secondPhoneController.text,
        );

    ref.read(checkoutCustomerStorageProvider).save(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          secondPhone: _secondPhoneController.text.trim(),
        );

    context.push(AppRoutes.checkoutReview);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(checkoutDraftProvider);
    if (draft == null || !draft.hasItems) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              PageBackHeader(
                title: 'طلب منتج',
                onBack: () => context.pop(),
              ),
              const Expanded(
                child: Center(child: Text('السلة فارغة')),
              ),
            ],
          ),
        ),
      );
    }

    final address = draft.selectedAddress;
    final addressLabel = address?.fullAddress ?? 'أختر العنوان';
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight = screenHeight * CartPageMetrics.footerHeightFraction;
    final bottomRadius = CartPageMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: CartPageMetrics.pageBackground,
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
                    children: [
                      PageBackHeader(
                        title: 'طلب منتج',
                        onBack: () => context.pop(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'أكتب معلوماتك',
                          style: AppTextStyles.checkoutSectionTitle(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      FormErrorAnimator(
                        tick: _nameShakeTick,
                        child: AppTextField(
                          hint: 'الاسم',
                          controller: _nameController,
                          icon: Icons.person_outline,
                          height: CheckoutFieldMetrics.fieldHeight(),
                          borderRadius: CheckoutFieldMetrics.borderRadius(),
                          validator: (v) => _nameController.text.trim().isEmpty
                              ? 'أدخل الاسم'
                              : null,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      FormErrorAnimator(
                        tick: _phoneShakeTick,
                        child: AppTextField(
                          hint: '0770 000 000',
                          controller: _phoneController,
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          height: CheckoutFieldMetrics.fieldHeight(),
                          borderRadius: CheckoutFieldMetrics.borderRadius(),
                          validator: (v) =>
                              _phoneController.text.trim().length < 10
                                  ? 'أدخل رقم هاتف صحيح'
                                  : null,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        hint: 'رقم ثاني (أختياري)',
                        controller: _secondPhoneController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        height: CheckoutFieldMetrics.fieldHeight(),
                        borderRadius: CheckoutFieldMetrics.borderRadius(),
                      ),
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'العنوان',
                          style: AppTextStyles.checkoutSectionTitle(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      FormErrorAnimator(
                        tick: _addressShakeTick,
                        child: GestureDetector(
                          onTap: _pickAddress,
                          child: SizedBox(
                            height: CheckoutFieldMetrics.fieldHeight(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(
                                  CheckoutFieldMetrics.borderRadius(),
                                ),
                                border: Border.all(
                                  color: address == null
                                      ? AppColors.dotGrid
                                      : AppColors.primary,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 26.sp,
                                ),
                                Expanded(
                                  child: Text(
                                    addressLabel,
                                    style: AppTextStyles.authField(
                                      color: address == null
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.textSecondary,
                                  size: 22.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: GestureDetector(
                          onTap: _onAddNewAddress,
                          behavior: HitTestBehavior.opaque,
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'أضافة عنوان جديد',
                                  style: AppTextStyles.checkoutLink(
                                    color:
                                        CheckoutFieldMetrics.addAddressLinkColor(),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  height: 1.h,
                                  color:
                                      CheckoutFieldMetrics.addAddressLinkColor(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'طريقة الدفع',
                          style: AppTextStyles.checkoutSectionTitle(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _PaymentOption(
                        label: 'عند الأستلام',
                        selected: true,
                        onTap: () {},
                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: footerHeight,
            child: ColoredBox(
              color: CartPageMetrics.pageBackground,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: CartPageMetrics.footerPadding(),
                  child: Transform.translate(
                    offset: CartPageMetrics.footerButtonOffset(),
                    child: CartCheckoutFooter(
                      label: 'التالي',
                      onTap: _onNext,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: CheckoutFieldMetrics.fieldHeight(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              CheckoutFieldMetrics.borderRadius(),
            ),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.dotGrid,
              width: 1.2,
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.authField(color: AppColors.textPrimary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
      ),
      ),
    );
  }
}
