import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/explore_models.dart';
import '../widgets/explore_pinned_header.dart';
import '../widgets/explore_scroll_metrics.dart';
import '../widgets/explore_tab_content.dart';

/// صفحة الاكسبلور — عام | براندات | اقسام
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();
  ExploreTab _selectedTab = ExploreTab.general;
  double _headerHeight = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabSelected(ExploreTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _updateHeaderHeight() {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final height = box.size.height;
    if ((height - _headerHeight).abs() > 0.5) {
      setState(() => _headerHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final fallbackHeader = ExploreScrollMetrics.pinnedHeaderHeight(topInset);
    final scrollTopPadding =
        _headerHeight > 0 ? _headerHeight : fallbackHeader;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeaderHeight());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: scrollTopPadding)),
              ExploreTabSlivers.build(
                tab: _selectedTab,
                bottomInset: bottomInset,
              ),
            ],
          ),
          ExplorePinnedHeader(
            headerKey: _headerKey,
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}
