import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/arabic_digits.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_footer_link.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
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
  bool _showContactUs = false;

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
    _showContactUs = false;
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
    if (ConnectivityErrorHandler.shouldShowMessage(error) &&
        !_isCredentialLoginError(error)) {
      unawaited(
        ConnectivityErrorHandler.promptRetry(
          context: context,
          ref: ref,
          onRetry: _onLogin,
        ),
      );
      return;
    }

    final isCredentialError = _isCredentialLoginError(error);
    setState(() {
      _clearErrors();
      if (isCredentialError) {
        _usernameErrorBorder = true;
        _passwordError = error;
        _showContactUs = true;
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
      return;
    }

    final error = ref.read(authNotifierProvider).errorMessage;
    if (error != null) {
      _applyLoginApiError(error);
    }
  }

  Future<void> _openWhatsApp() async {
    try {
      final info = await ref.read(appInfoProvider.future);
      if (!mounted) return;
      final uri = WhatsAppLink.buildUri(
        info.whatsapp,
        fallbackPhone: info.phone,
      );
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب')),
        );
        return;
      }

      var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح واتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage != null) {
        _applyLoginApiError(next.errorMessage!);
      }
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;
    ref.watch(appInfoProvider);

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
                      inputFormatters: const [ArabicDigitsInputFormatter()],
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
                      errorActionLabel: _showContactUs ? 'تواصل معنا' : null,
                      onErrorAction: _showContactUs ? _openWhatsApp : null,
                      onChanged: (_) {
                        if (_passwordError != null || _showContactUs) {
                          setState(() {
                            _passwordError = null;
                            _usernameErrorBorder = false;
                            _showContactUs = false;
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
