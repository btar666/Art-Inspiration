import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/floating_cart_button.dart';
import '../widgets/home_content.dart';
import '../widgets/home_logo_header_overlay.dart';

/// الصفحة الرئيسية
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if ((offset - _scrollOffset).abs() < 0.5) return;
    setState(() => _scrollOffset = offset);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HomeContent(scrollController: _scrollController),
          HomeLogoHeaderOverlay(scrollOffset: _scrollOffset),
          DraggableFloatingCartButton(
            itemCount: 1,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
