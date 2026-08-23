import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/notifications/notification_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../home/data/products_repository.dart';
import '../models/slider_item_model.dart';

/// يفتح الهدف المرتبط بعنصر السلايدر (منتج / قسم / براند)
Future<void> openSliderLink({
  required BuildContext context,
  required WidgetRef ref,
  required SliderItemModel item,
}) async {
  if (!item.hasLink) return;

  switch (item.linkType) {
    case SliderLinkType.product:
      final productId = item.linkId?.toString();
      if (productId == null) return;
      await openProductByItemId(
        ref: ref,
        itemId: productId,
        context: context,
      );
    case SliderLinkType.category:
    case SliderLinkType.brand:
      final sectionName = await _resolveSectionName(ref, item);
      if (sectionName == null || !context.mounted) return;
      context.push(AppRoutes.exploreSectionPath(sectionName));
    case SliderLinkType.none:
      break;
  }
}

Future<String?> _resolveSectionName(
  WidgetRef ref,
  SliderItemModel item,
) async {
  final directName = item.linkName?.trim();
  if (directName != null && directName.isNotEmpty) return directName;

  final linkId = item.linkId;
  if (linkId == null) return null;

  final repo = ref.read(productsRepositoryProvider);
  return switch (item.linkType) {
    SliderLinkType.category => repo.categoryNameByErpId(linkId),
    SliderLinkType.brand => repo.brandNameByErpId(linkId),
    _ => null,
  };
}
