import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../data/models/order_model.dart';
import '../../data/models/orders_list_state.dart';
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
  final _scrollController = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    ref.read(ordersListProvider.notifier).loadMore();
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (_query.trim().isEmpty) return orders;
    final q = _query.trim();
    return orders
        .where(
          (o) => o.orderName.contains(q) || o.address.contains(q),
        )
        .toList();
  }

  Future<void> _onRefresh() async {
    await ref.read(ordersListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final ordersAsync = ref.watch(ordersListProvider);

    return ordersAsync.when(
      loading: () => _buildScaffold(
        context,
        bottomInset,
        const [],
        isLoading: true,
      ),
      error: (_, __) => _buildScaffold(
        context,
        bottomInset,
        const [],
        errorMessage: 'تعذر جلب الفواتير',
      ),
      data: (listState) {
        return _buildScaffold(
          context,
          bottomInset,
          _filteredOrders(listState.orders),
          listState: listState,
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double bottomInset,
    List<OrderModel> orders, {
    bool isLoading = false,
    String? errorMessage,
    OrdersListState? listState,
  }) {
    final hasMore = listState?.hasMore ?? false;
    final isLoadingMore = listState?.isLoadingMore ?? false;
    final currentPage = listState?.currentPage ?? 1;
    final lastPage = listState?.lastPage ?? 1;
    final total = listState?.total ?? orders.length;

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
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            if (total > 0 && !isLoading && errorMessage == null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${orders.length} من $total',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                ),
              ),
            SizedBox(height: 8.h),
            Expanded(
              child: AppRefreshIndicator(
                onRefresh: _onRefresh,
                child: isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 160.h),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : errorMessage != null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 160.h),
                              Center(
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
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
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  0,
                                  20.w,
                                  100.h + bottomInset,
                                ),
                                itemCount: orders.length +
                                    (hasMore || isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 14.h),
                                itemBuilder: (context, index) {
                                  if (index >= orders.length) {
                                    return PaginationFooter(
                                      currentPage: currentPage,
                                      lastPage: lastPage,
                                      hasMore: hasMore,
                                      isLoadingMore: isLoadingMore,
                                      onLoadMore: () => ref
                                          .read(ordersListProvider.notifier)
                                          .loadMore(),
                                    );
                                  }

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
}
