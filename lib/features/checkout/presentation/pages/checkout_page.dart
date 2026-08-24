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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/saved_addresses_provider.dart';
import '../../../settings/presentation/widgets/address_form_bottom_sheet.dart';
import '../../data/checkout_provider.dart';
import '../widgets/checkout_field_metrics.dart';
import '../widgets/checkout_review_overlay_metrics.dart';

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
    // قراءة فقط — بدون تعديل providers أثناء البناء
    _seedControllersFromLocalData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDraftThenRefreshProfile();
    });
  }

  /// يملأ الحقول فوراً من المسودة / الجلسة المحلية دون تعديل أي provider
  void _seedControllersFromLocalData() {
    final draft = ref.read(checkoutDraftProvider);
    if (draft != null &&
        (draft.customerName.isNotEmpty || draft.phone.isNotEmpty)) {
      _nameController.text = draft.customerName;
      _phoneController.text = draft.phone;
      _secondPhoneController.text = draft.secondPhone;
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    final saved = ref.read(checkoutCustomerStorageProvider).load();
    final userName = user?.name.trim() ?? '';
    final userPhone = (user?.phone ?? '').trim();

    _nameController.text = userName.isNotEmpty ? userName : saved.name;
    _phoneController.text = userPhone.isNotEmpty ? userPhone : saved.phone;
    _secondPhoneController.text =
        draft?.secondPhone.isNotEmpty == true
            ? draft!.secondPhone
            : saved.secondPhone;
  }

  Future<void> _syncDraftThenRefreshProfile() async {
    ref.read(checkoutDraftProvider.notifier).syncFromProfileAndAddress();
    _writeDraftToControllers();
    if (mounted) setState(() {});
    await _refreshProfileInBackground();
  }

  void _writeDraftToControllers() {
    final draft = ref.read(checkoutDraftProvider);
    if (draft == null) return;
    _nameController.text = draft.customerName;
    _phoneController.text = draft.phone;
    _secondPhoneController.text = draft.secondPhone;
  }

  Future<void> _refreshProfileInBackground() async {
    final nameBefore = _nameController.text;
    final phoneBefore = _phoneController.text;
    final secondBefore = _secondPhoneController.text;

    await ref.read(authNotifierProvider.notifier).refreshProfile();
    if (!mounted) return;

    ref.read(checkoutDraftProvider.notifier).syncFromProfileAndAddress();
    final draft = ref.read(checkoutDraftProvider);
    if (draft == null) return;

    // لا نكتب فوق ما عدّله المستخدم أثناء التحديث
    if (_nameController.text == nameBefore) {
      _nameController.text = draft.customerName;
    }
    if (_phoneController.text == phoneBefore) {
      _phoneController.text = draft.phone;
    }
    if (_secondPhoneController.text == secondBefore) {
      _secondPhoneController.text = draft.secondPhone;
    }

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
    final addressInvalid =
        draft != null && draft.requiresAddress && draft.selectedAddress == null;

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
    final isDelivery =
        draft.deliveryMethod == CheckoutDeliveryMethod.delivery;
    final footerPadding = CartPageMetrics.footerPadding();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                PageBackHeader(
                  title: 'طلب منتج',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      0,
                      20.w,
                      CheckoutReviewOverlayMetrics.scrollBottomInset(context),
                    ),
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
                          'طريقة الاستلام',
                          style: AppTextStyles.checkoutSectionTitle(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _CheckoutRadioOption(
                        label: CheckoutDeliveryMethod.pickupAtCompany.label,
                        selected: draft.deliveryMethod ==
                            CheckoutDeliveryMethod.pickupAtCompany,
                        onTap: () {
                          ref
                              .read(checkoutDraftProvider.notifier)
                              .setDeliveryMethod(
                                CheckoutDeliveryMethod.pickupAtCompany,
                              );
                        },
                      ),
                      SizedBox(height: 12.h),
                      _CheckoutRadioOption(
                        label: CheckoutDeliveryMethod.delivery.label,
                        selected: draft.deliveryMethod ==
                            CheckoutDeliveryMethod.delivery,
                        onTap: () {
                          ref
                              .read(checkoutDraftProvider.notifier)
                              .setDeliveryMethod(
                                CheckoutDeliveryMethod.delivery,
                              );
                        },
                      ),
                      if (isDelivery) ...[
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
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20.w),
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
                      ],
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'طريقة الدفع',
                          style: AppTextStyles.checkoutSectionTitle(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _CheckoutRadioOption(
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
          Positioned(
            left: footerPadding.left,
            right: footerPadding.right,
            bottom: CheckoutReviewOverlayMetrics.overlayBottomOffset(context),
            child: CartCheckoutFooter(
              label: 'التالي',
              onTap: _onNext,
              glassy: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutRadioOption extends StatelessWidget {
  const _CheckoutRadioOption({
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
