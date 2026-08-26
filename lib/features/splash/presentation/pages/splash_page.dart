import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/floating_cart_suppression.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../shared/widgets/connectivity_error_dialog.dart';
import '../../../../shared/widgets/app_animated_logo.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/decorative_dot_grid.dart';
import '../../../../shared/widgets/sparkle_icon.dart';
import '../../../auth/data/auth_storage.dart';
import '../../../onboarding/data/onboarding_content.dart';
import '../../../onboarding/data/onboarding_images.dart';
import '../widgets/app_logo.dart';

/// شاشة السبلاش مع أنيميشن احترافي
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _rotationComplete = Completer<void>();
  var _onboardingImagesPrecached = false;
  var _isCheckingConnectivity = false;

  @override
  void initState() {
    super.initState();
    _navigateAfterRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_onboardingImagesPrecached) return;
    _onboardingImagesPrecached = true;
    _precacheOnboardingImages();
  }

  Future<void> _precacheOnboardingImages() async {
    final assets = OnboardingContent.items
        .map((item) => item.imageAsset)
        .whereType<String>();
    await OnboardingImages.precacheAll(context, assets);
  }

  void _onRotationComplete() {
    if (!_rotationComplete.isCompleted) {
      _rotationComplete.complete();
    }
  }

  Future<void> _navigateAfterRotation() async {
    // لا نبقى عالقين على السبلاش إذا لم يكتمل الأنيميشن
    await Future.any<void>([
      _rotationComplete.future,
      Future<void>.delayed(const Duration(milliseconds: 2500)),
    ]);
    await Future<void>.delayed(AppConstants.splashPostRotationDelay);
    if (!mounted) return;

    final route = _resolveStartRoute();
    if (route == AppRoutes.home) {
      await _navigateToHomeWhenOnline();
      return;
    }

    _goAfterSplash(route);
  }

  Future<void> _navigateToHomeWhenOnline() async {
    if (_isCheckingConnectivity) return;
    _isCheckingConnectivity = true;

    try {
      final canProceed = await ensureAppConnectivity(
        ref,
        () async {
          if (!mounted) return false;
          return ConnectivityErrorDialog.show(
            context,
            barrierDismissible: false,
          );
        },
      );

      if (!mounted || !canProceed) return;
      _goAfterSplash(AppRoutes.home);
    } finally {
      _isCheckingConnectivity = false;
    }
  }

  /// أول فتح → Onboarding | بعده → الرئيسية أو تسجيل الدخول
  String _resolveStartRoute() {
    final storage = ref.read(onboardingStorageProvider);
    final isLoggedIn = ref.read(authStorageProvider).isLoggedIn;

    // مستخدم مسجّل مسبقاً = ليس أول تثبيت — لا نعرض الـ Onboarding
    if (!storage.isCompleted && isLoggedIn) {
      storage.markCompleted();
      return AppRoutes.home;
    }

    if (!storage.isCompleted) {
      return AppRoutes.onboarding;
    }

    if (isLoggedIn) {
      return AppRoutes.home;
    }

    return AppRoutes.login;
  }

  /// يمنع ظهور زر السلة فوق السبلاش أثناء الانتقال
  void _goAfterSplash(String route) {
    final suppressed = ref.read(floatingCartSuppressedProvider.notifier);
    suppressed.state = true;
    context.go(route);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      suppressed.state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DecorativeBackground(
          child: Stack(
          children: [
            const DecorativeDotGrid(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(top: 48, left: 28),
            ),
            Positioned(
              top: 120.h,
              left: 60.w,
              child: SparkleIcon(size: 14.w, delay: 200.ms),
            ),
            Positioned(
              top: 200.h,
              right: 50.w,
              child: SparkleIcon(size: 18.w, filled: false, delay: 400.ms),
            ),
            Positioned(
              bottom: 180.h,
              left: 40.w,
              child: SparkleIcon(size: 12.w, delay: 600.ms),
            ),
            Positioned(
              bottom: 220.h,
              right: 70.w,
              child: SparkleIcon(size: 16.w, delay: 300.ms),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAnimatedLogo(
                    size: 80,
                    enableRotation: true,
                    enableEntrance: true,
                    shakeOnTap: true,
                    rotationDuration: AppConstants.splashLogoRotationDuration,
                    onRotationComplete: _onRotationComplete,
                  ),
                  SizedBox(height: 12.h),
                  const AppLogoText(animate: true),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
