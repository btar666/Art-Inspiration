import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/catalog_snapshot.dart';

/// بطاقة ملخص بيانات المتجر من أمان ERP
class ErpStoreOverviewCard extends StatelessWidget {
  const ErpStoreOverviewCard({
    super.key,
    required this.catalog,
    this.ordersTotal,
    this.userName,
  });

  final CatalogSnapshot catalog;
  final int? ordersTotal;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    if (catalog.source != CatalogDataSource.api &&
        catalog.source != CatalogDataSource.cache &&
        catalog.source != CatalogDataSource.offline) {
      return const SizedBox.shrink();
    }

    final stats = catalog.stats;
    final currency = catalog.storeSettings;

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات المتجر (أمان ERP)',
            style: AppTextStyles.homeSectionTitle(),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 10.h),
          _Row(
            label: 'المنتجات',
            value: '${stats.totalProducts}',
            ok: stats.totalProducts > 0,
          ),
          _Row(
            label: 'الأسعار',
            value: '${currency.currencyCode} (${currency.currencySymbol})',
            ok: true,
          ),
          _Row(
            label: 'البراندات',
            value: '${stats.brandCount}',
            ok: stats.brandCount > 0,
            detail: stats.productsWithoutBrand > 0
                ? '${stats.productsWithoutBrand} منتج بدون براند'
                : null,
          ),
          _Row(
            label: 'الأقسام',
            value: stats.hasCategories ? '${stats.categoryCount}' : 'غير متوفرة',
            ok: stats.hasCategories,
            detail: stats.hasCategories ? null : 'لا توجد تصنيفات في أمان ERP',
          ),
          _Row(
            label: 'صور المنتجات',
            value: stats.hasProductImages
                ? '${stats.productsWithImages}'
                : 'غير متوفرة',
            ok: stats.hasProductImages,
            detail: stats.hasProductImages ? null : 'حقل image فارغ',
          ),
          _Row(
            label: 'إعدادات المتجر',
            value: currency.currencyArabicName,
            ok: true,
          ),
          if (ordersTotal != null)
            _Row(
              label: 'الفواتير / الطلبات',
              value: '$ordersTotal',
              ok: ordersTotal! > 0,
            ),
          if (userName != null && userName!.isNotEmpty)
            _Row(
              label: 'المستخدم',
              value: userName!,
              ok: true,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.ok,
    this.detail,
  });

  final String label;
  final String value;
  final bool ok;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle_outline : Icons.info_outline,
                size: 16.sp,
                color: ok ? Colors.green.shade600 : Colors.orange.shade700,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.settingsMenuItem(),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.homeProductCategory(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (detail != null)
            Padding(
              padding: EdgeInsets.only(right: 22.w, top: 2.h),
              child: Text(
                detail!,
                style: AppTextStyles.settingsMenuItem(
                  color: Colors.orange.shade800,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
