import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/models/order_status.dart';
import '../../data/local_orders_storage.dart';
import '../widgets/checkout_bottom_bar.dart';

/// صفحة تتبع الطلب
class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(localOrdersNotifierProvider);
    OrderDetailModel? order;
    for (final item in orders) {
      if (item.id == orderId) {
        order = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageBackHeader(
              title: 'تتبع الطلب',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 24.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.orderCardBorder),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          AppAssets.orderTrackingIllustration,
                          height: 160.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'تم تأكيد طلبك بنجاح !',
                          style: AppTextStyles.checkoutSuccessTitle(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'تتبع الطلب',
                      style: AppTextStyles.checkoutSectionTitle(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _TrackingTimeline(status: order?.status ?? OrderStatus.reviewing),
                ],
              ),
            ),
            CheckoutBottomBar(
              label: 'عرض الطلبات',
              secondaryLabel: 'الرئيسية',
              onTap: () => context.go(AppRoutes.orders),
              onSecondaryTap: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.status});

  final OrderStatus status;

  int get _activeIndex => switch (status) {
        OrderStatus.reviewing => 0,
        OrderStatus.delivering => 1,
        OrderStatus.delivered => 2,
        OrderStatus.cancelled => 0,
      };

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('قيد المراجعة', 'بأنتظار أنطلاق الطلب', Icons.receipt_long_outlined),
      ('قيد التوصيل', 'الطلب في طريقه اليك', Icons.local_shipping_outlined),
      ('تم توصيل طلبك', '', Icons.verified_outlined),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TrackingStep(
            title: steps[i].$1,
            subtitle: steps[i].$2,
            icon: steps[i].$3,
            isActive: i <= _activeIndex,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = isActive ? AppColors.primary : AppColors.dotGrid;
    final textColor =
        isActive ? AppColors.textPrimary : AppColors.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: dotColor.withValues(alpha: 0.45), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.ordersDetailValue(color: textColor),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.ordersDetailLabel(color: textColor),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? AppColors.primary : AppColors.dotGrid,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
