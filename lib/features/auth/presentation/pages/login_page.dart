import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/erp_dev_session.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_footer_link.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../widgets/auth_message_dialog.dart';

/// صفحة تسجيل الدخول
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  int _usernameShakeTick = 0;
  int _passwordShakeTick = 0;
  int _logoShakeTick = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isUsernameInvalid() => _usernameController.text.trim().isEmpty;

  bool _isPasswordInvalid() => _passwordController.text.length < 6;

  Future<void> _onLogin() async {
    _formKey.currentState!.validate();

    final usernameInvalid = _isUsernameInvalid();
    final passwordInvalid = _isPasswordInvalid();

    if (usernameInvalid || passwordInvalid) {
      setState(() {
        if (usernameInvalid) _usernameShakeTick++;
        if (passwordInvalid) _passwordShakeTick++;
        _logoShakeTick++;
      });

      final issues = <String>[
        if (usernameInvalid) 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف',
        if (passwordInvalid) 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      ];
      await AuthMessageDialog.showValidation(context, issues: issues);
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).login(
          identifier: _usernameController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
      return;
    }

    final error = ref.read(authNotifierProvider).errorMessage;
    if (error != null) {
      await AuthMessageDialog.showError(
        context,
        title: 'فشل تسجيل الدخول',
        message: error,
      );
    }
  }

  Future<void> _onErpDevContinue() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await ErpDevSession.apply(prefs);
    ref.invalidate(authNotifierProvider);
    ref.invalidate(catalogProvider);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final showErpBypass = ErpDevSession.isActive;

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
                    SizedBox(height: 24.h),
                    AuthHeader(
                      title: 'تسجيل الدخول',
                      subtitle: 'أدخل معلوماتك لتسجيل الدخول الى حسابك',
                      errorTick: _logoShakeTick,
                    ),
                    SizedBox(height: 32.h),
                    FormErrorAnimator(
                      tick: _usernameShakeTick,
                      child: AppTextField(
                        hint: 'البريد أو رقم الهاتف',
                        controller: _usernameController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.text,
                        validator: (v) => _isUsernameInvalid()
                            ? 'أدخل البريد أو رقم الهاتف'
                            : null,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideX(
                            begin: 0.08,
                            end: 0,
                            duration: 400.ms,
                            delay: 100.ms,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    FormErrorAnimator(
                      tick: _passwordShakeTick,
                      child: AppTextField(
                        hint: 'Password',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) =>
                            _isPasswordInvalid() ? 'أدخل كلمة مرور صحيحة' : null,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .slideX(
                            begin: 0.08,
                            end: 0,
                            duration: 400.ms,
                            delay: 200.ms,
                          ),
                    ),
                    SizedBox(height: 28.h),
                    AppButton(
                      label: isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
                      expanded: true,
                      onPressed: isLoading ? null : _onLogin,
                    )
                        .animate()
                        .fadeIn(duration: 450.ms, delay: 300.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          duration: 450.ms,
                          delay: 300.ms,
                        ),
                    if (showErpBypass) ...[
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: isLoading ? null : _onErpDevContinue,
                        child: const Text(
                          'متابعة وعرض المنتجات (ERP مؤقت)',
                        ),
                      ),
                    ],
                    AuthFooterLink(
                      prefix: 'ليس لديك حساب ؟',
                      linkText: 'أطلب الأنضمام',
                      onTap: () => context.push(AppRoutes.register),
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
