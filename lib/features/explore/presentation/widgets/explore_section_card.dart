import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton/skeleton_image_placeholder.dart';
import '../../data/models/explore_models.dart';
import 'explore_section_card_metrics.dart';

/// كارد قسم — يعرض صورة الـ API فقط
class ExploreSectionCard extends StatelessWidget {
  const ExploreSectionCard({
    super.key,
    required this.section,
    this.onTap,
  });

  final ExploreSectionModel section;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.circular(ExploreSectionCardMetrics.borderRadius()),
          boxShadow: ExploreSectionCardMetrics.cardShadow(),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: ExploreSectionCardMetrics.imagePadding(),
                child: section.hasNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: section.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        fadeInDuration: Duration.zero,
                        placeholder: (_, __) => SkeletonImagePlaceholder(
                          borderRadius: BorderRadius.circular(12.r),
                          animated: false,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.broken_image_outlined,
                          size: 32.sp,
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        size: 32.sp,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
              ),
            ),
            Padding(
              padding: ExploreSectionCardMetrics.labelPadding(),
              child: Text(
                section.name,
                style: AppTextStyles.exploreSectionLabel(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
