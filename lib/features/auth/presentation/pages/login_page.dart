import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_footer_link.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../providers/auth_provider.dart';

/// صفحة تسجيل الدخول
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  int _usernameShakeTick = 0;
  int _passwordShakeTick = 0;
  int _logoShakeTick = 0;
  String? _usernameError;
  String? _passwordError;
  bool _usernameErrorBorder = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isUsernameInvalid() => _usernameController.text.trim().isEmpty;

  bool _isPasswordInvalid() => _passwordController.text.length < 5;

  void _clearErrors() {
    _usernameError = null;
    _passwordError = null;
    _usernameErrorBorder = false;
  }

  bool _isCredentialLoginError(String error) {
    final text = error.toLowerCase();
    return text.contains('هاتف') ||
        text.contains('كلمة') ||
        text.contains('مرور') ||
        text.contains('password') ||
        text.contains('صحيح');
  }

  void _applyLoginApiError(String error) {
    final isCredentialError = _isCredentialLoginError(error);
    setState(() {
      _clearErrors();
      if (isCredentialError) {
        _usernameErrorBorder = true;
        _passwordError = error;
        _usernameShakeTick++;
        _passwordShakeTick++;
      } else {
        _usernameError = error;
        _usernameShakeTick++;
      }
      _logoShakeTick++;
    });
  }

  Future<void> _onLogin() async {
    final usernameInvalid = _isUsernameInvalid();
    final passwordInvalid = _isPasswordInvalid();

    if (usernameInvalid || passwordInvalid) {
      setState(() {
        _clearErrors();
        if (usernameInvalid) {
          _usernameError = 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف';
          _usernameShakeTick++;
        }
        if (passwordInvalid) {
          _passwordError = 'كلمة المرور يجب أن تكون 5 أحرف على الأقل';
          _passwordShakeTick++;
        }
        _logoShakeTick++;
      });
      return;
    }

    setState(_clearErrors);

    final success = await ref.read(authNotifierProvider.notifier).login(
          identifier: _usernameController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage != null &&
          !next.isLoggedIn) {
        _applyLoginApiError(next.errorMessage!);
      }
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: DecorativeBackground(
        child: AuthPageBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
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
                      errorText: _usernameError,
                      showErrorBorder: _usernameErrorBorder,
                      onChanged: (_) {
                        if (_usernameError != null || _usernameErrorBorder) {
                          setState(() {
                            _usernameError = null;
                            _usernameErrorBorder = false;
                          });
                        }
                      },
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
                      errorText: _passwordError,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = null;
                            _usernameErrorBorder = false;
                          });
                        }
                      },
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
    );
  }
}
