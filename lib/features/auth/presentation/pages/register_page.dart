import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_footer_link.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../../data/iraqi_governorates.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_message_dialog.dart';

/// صفحة طلب الانضمام / إنشاء حساب
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGovernorate;
  int _nameShakeTick = 0;
  int _phoneShakeTick = 0;
  int _governorateShakeTick = 0;
  int _shopShakeTick = 0;
  int _passwordShakeTick = 0;
  int _logoShakeTick = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _shopController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isNameInvalid() => _nameController.text.trim().isEmpty;

  bool _isPhoneInvalid() => _phoneController.text.trim().length < 10;

  bool _isGovernorateInvalid() => _selectedGovernorate == null;

  bool _isShopInvalid() => _shopController.text.trim().isEmpty;

  bool _isPasswordInvalid() => _passwordController.text.length < 5;

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _formKey.currentState!.validate();

    final nameInvalid = _isNameInvalid();
    final phoneInvalid = _isPhoneInvalid();
    final governorateInvalid = _isGovernorateInvalid();
    final shopInvalid = _isShopInvalid();
    final passwordInvalid = _isPasswordInvalid();

    if (nameInvalid ||
        phoneInvalid ||
        governorateInvalid ||
        shopInvalid ||
        passwordInvalid) {
      setState(() {
        if (nameInvalid) _nameShakeTick++;
        if (phoneInvalid) _phoneShakeTick++;
        if (governorateInvalid) _governorateShakeTick++;
        if (shopInvalid) _shopShakeTick++;
        if (passwordInvalid) _passwordShakeTick++;
        _logoShakeTick++;
      });

      final issues = <String>[
        if (nameInvalid) 'يرجى إدخال اسمك الكامل',
        if (phoneInvalid) 'يرجى إدخال رقم هاتف صحيح (10 أرقام على الأقل)',
        if (governorateInvalid) 'يرجى اختيار محافظتك',
        if (shopInvalid) 'يرجى إدخال اسم المتجر',
        if (passwordInvalid) 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      ];
      await AuthMessageDialog.showValidation(context, issues: issues);
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          shopName: _shopController.text.trim(),
          governorate: _selectedGovernorate!,
        );

    if (!mounted) return;

    if (success) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.go(AppRoutes.requestSuccess);
      return;
    }

    final error = ref.read(authNotifierProvider).errorMessage;
    if (error != null) {
      await AuthMessageDialog.showError(
        context,
        title: 'تعذر إرسال الطلب',
        message: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: DecorativeBackground(
        child: AuthPageBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    AuthHeader(
                      title: 'طلب أنضمام',
                      subtitle: 'أدخل معلوماتك لأنشاء حساب جديد في التطبيق',
                      errorTick: _logoShakeTick,
                    ),
                    SizedBox(height: 28.h),
                    FormErrorAnimator(
                      tick: _nameShakeTick,
                      child: AppTextField(
                        hint: 'أسمك',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (v) =>
                            _isNameInvalid() ? 'أدخل اسمك' : null,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: 80.ms)
                          .slideX(begin: 0.08, end: 0),
                    ),
                    SizedBox(height: 14.h),
                    FormErrorAnimator(
                      tick: _phoneShakeTick,
                      child: AppTextField(
                        hint: 'رقم الهاتف',
                        controller: _phoneController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            _isPhoneInvalid() ? 'أدخل رقم هاتف صحيح' : null,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: 140.ms)
                          .slideX(begin: 0.08, end: 0),
                    ),
                    SizedBox(height: 14.h),
                    FormErrorAnimator(
                      tick: _governorateShakeTick,
                      child: AppDropdownField<String>(
                        hint: 'محافظتك',
                        icon: Icons.map_outlined,
                        value: _selectedGovernorate,
                        items: IraqiGovernorates.all,
                        onChanged: (v) =>
                            setState(() => _selectedGovernorate = v),
                        validator: (v) =>
                            _isGovernorateInvalid() ? 'اختر محافظتك' : null,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: 200.ms)
                          .slideX(begin: 0.08, end: 0),
                    ),
                    SizedBox(height: 14.h),
                    FormErrorAnimator(
                      tick: _shopShakeTick,
                      child: AppTextField(
                        hint: 'اسم الكوزمتك',
                        controller: _shopController,
                        icon: Icons.storefront_outlined,
                        validator: (v) =>
                            _isShopInvalid() ? 'أدخل اسم المتجر' : null,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: 260.ms)
                          .slideX(begin: 0.08, end: 0),
                    ),
                    SizedBox(height: 14.h),
                    FormErrorAnimator(
                      tick: _passwordShakeTick,
                      child: AppTextField(
                        hint: 'كلمة المرور',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) =>
                            _isPasswordInvalid() ? 'أدخل كلمة مرور (6 أحرف)' : null,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: 320.ms)
                          .slideX(begin: 0.08, end: 0),
                    ),
                    SizedBox(height: 28.h),
                    AppButton(
                      label: isLoading ? 'جاري الإرسال...' : 'تقديم الطلب',
                      expanded: true,
                      onPressed: isLoading ? null : _onSubmit,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 380.ms)
                        .slideY(begin: 0.12, end: 0),
                    AuthFooterLink(
                      prefix: 'لديك حساب ؟',
                      linkText: 'سجل الدخول اليه',
                      onTap: () => context.go(AppRoutes.login),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
