import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_footer_link.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/form_error_animator.dart';

/// صفحة تسجيل الدخول
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _onLogin() {
    _formKey.currentState!.validate();

    final usernameInvalid = _isUsernameInvalid();
    final passwordInvalid = _isPasswordInvalid();

    if (usernameInvalid || passwordInvalid) {
      setState(() {
        if (usernameInvalid) _usernameShakeTick++;
        if (passwordInvalid) _passwordShakeTick++;
        _logoShakeTick++;
      });
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
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
                        hint: 'User Name',
                        controller: _usernameController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.text,
                        validator: (v) => _isUsernameInvalid()
                            ? 'أدخل اسم المستخدم'
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
                      label: 'تسجيل الدخول',
                      expanded: true,
                      onPressed: _onLogin,
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
      ),
    );
  }
}
