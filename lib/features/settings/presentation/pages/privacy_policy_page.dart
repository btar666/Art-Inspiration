import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../app_api/models/return_policy_item.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';

/// صفحة سياسة الخصوصية — كل النص من api/privacy_policy
///
/// آبل تشترط سياسة خصوصية يمكن الوصول إليها داخل التطبيق، فلها عنصر مستقل
/// في الإعدادات بدل أن تُدفن أسفل صفحة أخرى.
class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final policyAsync = ref.watch(privacyPolicyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'سياسة الخصوصية',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: policyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ConnectivityErrorGate(
                  error: error,
                  onRetry: () async => ref.invalidate(privacyPolicyProvider),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                data: (items) => _PolicyBody(
                  items: items,
                  bottomInset: bottomInset,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyBody extends StatelessWidget {
  const _PolicyBody({
    required this.items,
    required this.bottomInset,
  });

  final List<ReturnPolicyItem> items;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _PolicyEmpty();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) ...[
            _PolicyCard(item: item),
            SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.item});

  final ReturnPolicyItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.settingsCardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.orderCardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.title.isNotEmpty) ...[
            Text(
              item.title,
              style: AppTextStyles.settingsMenuItem().copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 12.h),
          ],
          if (item.details.isNotEmpty)
            Text(
              item.details,
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.textSecondary,
              ).copyWith(
                fontWeight: FontWeight.w500,
                height: 1.85,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }
}

/// ‏api/privacy_policy قد يعود فارغاً. لا نخترع نصاً قانونياً محلّه.
class _PolicyEmpty extends StatelessWidget {
  const _PolicyEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 44.sp,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          SizedBox(height: 14.h),
          Text(
            'سياسة الخصوصية غير متوفرة حالياً',
            style: AppTextStyles.settingsMenuItem(
              color: AppColors.textSecondary,
            ).copyWith(height: 1.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
