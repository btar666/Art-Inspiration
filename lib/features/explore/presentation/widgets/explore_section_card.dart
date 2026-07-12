import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/explore_models.dart';
import 'explore_section_card_metrics.dart';

/// كارد قسم — كونتينر أبيض + صورة + اسم القسم
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
                child: Image.asset(
                  section.iconAsset,
                  width: double.infinity,
                  fit: BoxFit.contain,
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
