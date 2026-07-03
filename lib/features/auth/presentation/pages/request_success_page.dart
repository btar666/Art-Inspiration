import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

/// صفحة نجاح تقديم طلب الانضمام
class RequestSuccessPage extends StatelessWidget {
  const RequestSuccessPage({super.key});

  static const _description =
      'سيتم مراجعة طلبك من قبل الإدارة خلال 24-48 ساعة، '
      'وسنُبلغك عبر الهاتف عند الموافقة على حسابك في التطبيق.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                AppAssets.frameIllustration,
                height: 280.h,
                fit: BoxFit.contain,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),
              SizedBox(height: 36.h),
              Text(
                'تم تقديم طلبك بنجاح !',
                style: AppTextStyles.successTitle(),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),
              SizedBox(height: 16.h),
              Text(
                _description,
                style: AppTextStyles.successBody(),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 450.ms),
              const Spacer(flex: 3),
              AppButton(
                label: 'العودة لتسجيل الدخول',
                expanded: true,
                onPressed: () => context.go(AppRoutes.login),
              )
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 450.ms, delay: 600.ms),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
