import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/data/local_orders_storage.dart';
import '../../data/models/order_model.dart';
import '../../data/orders_mock_data.dart';
import '../providers/orders_provider.dart';
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

  List<OrderModel> _allOrders(List<OrderModel> erpOrders) {
    final local = ref.watch(localOrdersNotifierProvider);
    final seenIds = <String>{};
    final merged = <OrderModel>[];

    for (final order in [...local, ...erpOrders]) {
      if (seenIds.add(order.id)) {
        merged.add(order);
      }
    }

    if (merged.isEmpty) {
      return OrdersMockData.orders;
    }

    return merged;
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (_query.trim().isEmpty) return orders;
    final q = _query.trim();
    return orders
        .where(
          (o) =>
              o.orderName.contains(q) ||
              o.address.contains(q) ||
              o.status.label.contains(q),
        )
        .toList();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(erpOrdersProvider);
    ref.invalidate(localOrdersNotifierProvider);
    await ref.read(erpOrdersProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final erpAsync = ref.watch(erpOrdersListProvider);

    return erpAsync.when(
      loading: () => _buildScaffold(
        context,
        bottomInset,
        const [],
        isLoading: true,
      ),
      error: (_, __) {
        final orders = _allOrders(const []);
        return _buildScaffold(context, bottomInset, _filteredOrders(orders));
      },
      data: (erpOrders) {
        final orders = _allOrders(erpOrders);
        return _buildScaffold(context, bottomInset, _filteredOrders(orders));
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double bottomInset,
    List<OrderModel> orders, {
    bool isLoading = false,
  }) {
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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 160.h),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : orders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 160.h),
                              Center(
                                child: Text(
                                  'لا توجد طلبات',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              0,
                              20.w,
                              100.h + bottomInset,
                            ),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return OrderCard(
                                order: order,
                                onTap: () => context.push(
                                  AppRoutes.orderDetailsPath(order.id),
                                ),
                              );
                            },
                          ),
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
