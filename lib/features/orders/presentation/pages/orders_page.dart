import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/data/local_orders_storage.dart';
import '../../data/models/order_model.dart';
import '../../data/orders_mock_data.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_page_header.dart';
import '../widgets/orders_search_row.dart';

/// صفحة الفواتير
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> get _allOrders {
    final local = ref.watch(localOrdersNotifierProvider);
    final mock = OrdersMockData.orders;
    final localIds = local.map((o) => o.id).toSet();
    final merged = [
      ...local,
      ...mock.where((o) => !localIds.contains(o.id)),
    ];
    return merged;
  }

  List<OrderModel> get _filteredOrders {
    if (_query.trim().isEmpty) return _allOrders;
    final q = _query.trim();
    return _allOrders
        .where(
          (o) =>
              o.orderName.contains(q) ||
              o.address.contains(q) ||
              o.status.label.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrdersPageHeader(
              onNotificationTap: () => context.push(AppRoutes.notifications),
            ),
            OrdersSearchRow(
              onSearchTap: () => _showSearchSheet(context),
              onFilterTap: () {},
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  100.h + bottomInset,
                ),
                itemCount: _filteredOrders.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return OrderCard(
                    order: order,
                    onTap: () => context.push(
                      AppRoutes.orderDetailsPath(order.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            20.h + MediaQuery.paddingOf(context).bottom,
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'أبحث عن طلب ..',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            onChanged: (value) {
              setState(() => _query = value);
            },
          ),
        );
      },
    );
  }
}
