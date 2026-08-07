import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/unified_search_bar.dart';

/// شريط بحث الفواتير — بحث مباشر داخل الشريط
class OrdersSearchRow extends StatelessWidget {
  const OrdersSearchRow({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: UnifiedSearchBar(
        hintText: 'أبحث عن طلب ..',
        showScanner: false,
        showFilter: false,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}
