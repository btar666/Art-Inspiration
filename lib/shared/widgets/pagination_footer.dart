import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// تذييل التصفح — مؤشر تحميل أو زر الصفحة التالية
class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
    required this.isLoadingMore,
    this.onLoadMore,
  });

  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore && !isLoadingMore) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          if (isLoadingMore)
            const CircularProgressIndicator()
          else if (hasMore)
            OutlinedButton(
              onPressed: onLoadMore,
              child: const Text('تحميل المزيد'),
            ),
        ],
      ),
    );
  }
}
