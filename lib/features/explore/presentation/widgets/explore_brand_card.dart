import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/explore_models.dart';

/// كارد براند في تبويب البراندات
class ExploreBrandCard extends StatelessWidget {
  const ExploreBrandCard({
    super.key,
    required this.brand,
    this.onTap,
  });

  final ExploreBrandModel brand;
  final VoidCallback? onTap;

  static const double _chevronSize = 28;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.orderCardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(
                        color: AppColors.orderCardBorder,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 16.h,
                    ),
                    alignment: Alignment.center,
                    child: brand.logoAsset != null
                        ? Image.asset(
                            brand.logoAsset!,
                            fit: BoxFit.contain,
                          )
                        : Text(
                            brand.name,
                            style: AppTextStyles.exploreBrandLogo().copyWith(
                              fontSize: 28.sp,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                height: 38.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  border: Border(
                    top: BorderSide(color: AppColors.orderCardBorder),
                  ),
                ),
                child: Row(
                  children: [
                    _BrandChevronButton(size: _chevronSize.w),
                    Expanded(
                      child: Text(
                        brand.name,
                        style: AppTextStyles.exploreBrandLabel(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: _chevronSize.w),
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

class _BrandChevronButton extends StatelessWidget {
  const _BrandChevronButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.chevron_left_rounded,
        size: size * 0.64,
        color: AppColors.background,
      ),
    );
  }
}
