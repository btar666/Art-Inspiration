import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/unified_search_bar.dart';

/// شريط بحث الفواتير — نفس تصميم الصفحة الرئيسية
class OrdersSearchRow extends StatelessWidget {
  const OrdersSearchRow({
    super.key,
    this.onFilterTap,
    this.onSearchTap,
  });

  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: UnifiedSearchBar(
        hintText: 'أبحث عن طلب ..',
        showScanner: false,
        onFilterTap: onFilterTap,
        onSearchTap: onSearchTap,
      ),
    );
  }
}
