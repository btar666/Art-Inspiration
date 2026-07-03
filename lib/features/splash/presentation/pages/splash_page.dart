import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../shared/widgets/app_animated_logo.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/decorative_dot_grid.dart';
import '../../../../shared/widgets/sparkle_icon.dart';
import '../widgets/app_logo.dart';

/// شاشة السبلاش مع أنيميشن احترافي
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _rotationComplete = Completer<void>();

  @override
  void initState() {
    super.initState();
    _navigateAfterRotation();
  }

  void _onRotationComplete() {
    if (!_rotationComplete.isCompleted) {
      _rotationComplete.complete();
    }
  }

  Future<void> _navigateAfterRotation() async {
    await _rotationComplete.future;
    await Future<void>.delayed(AppConstants.splashPostRotationDelay);
    if (!mounted) return;

    final nextRoute = AppConstants.alwaysShowOnboarding
        ? AppRoutes.onboarding
        : (ref.read(onboardingStorageProvider).isCompleted
            ? AppRoutes.login
            : AppRoutes.onboarding);

    context.go(nextRoute);
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
                  SizedBox(height: 20.h),
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
