import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../app_api/models/slider_item_model.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../../../app_api/presentation/slider_navigation.dart';
import '../providers/home_slider_index_provider.dart';
import '../../../../shared/widgets/skeleton/home_page_skeleton.dart';

/// بانر ترويجي متحرك بعرض الشاشة الكامل — من api/slider
class HomePromoBanner extends ConsumerStatefulWidget {
  const HomePromoBanner({super.key});

  @override
  ConsumerState<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends ConsumerState<HomePromoBanner> {
  final _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final sliderAsync = ref.watch(sliderProvider);

    return sliderAsync.when(
      loading: () => const HomeBannerSkeleton(),
      error: (error, _) => ConnectivityErrorGate(
        error: error,
        onRetry: () async => ref.invalidate(sliderProvider),
        child: const HomeBannerSkeleton(),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _BannerShell(child: _FallbackBanner(onRetry: null));
        }
        return _SliderBanner(
          items: items,
          controller: _controller,
          onItemTap: (item) => openSliderLink(
            context: context,
            ref: ref,
            item: item,
          ),
        );
      },
    );
  }
}

class _SliderBanner extends ConsumerWidget {
  const _SliderBanner({
    required this.items,
    required this.controller,
    required this.onItemTap,
  });

  final List<SliderItemModel> items;
  final CarouselSliderController controller;
  final ValueChanged<SliderItemModel> onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              carouselController: controller,
              itemCount: items.length,
              options: CarouselOptions(
                height: height,
                viewportFraction: 1,
                enlargeCenterPage: false,
                autoPlay: items.length > 1,
                onPageChanged: (index, _) {
                  ref.read(homeSliderPageIndexProvider.notifier).state = index;
                  ref
                      .read(homeSearchHintCycleProvider.notifier)
                      .update((n) => n + 1);
                },
              ),
              itemBuilder: (context, index, _) {
                final item = items[index];
                return Consumer(
                  builder: (context, ref, _) {
                    final isActive =
                        ref.watch(homeSliderPageIndexProvider) == index;
                    return _SliderSlide(
                      item: item,
                      isActive: isActive,
                      onTap: item.hasLink ? () => onItemTap(item) : null,
                    );
                  },
                );
              },
            ),
            if (items.length > 1)
              _SliderDots(
                count: items.length,
                controller: controller,
              ),
          ],
        );
      },
    );
  }
}

class _SliderDots extends ConsumerWidget {
  const _SliderDots({
    required this.count,
    required this.controller,
  });

  final int count;
  final CarouselSliderController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeSliderPageIndexProvider);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 14.h,
      child: Center(
        child: AnimatedSmoothIndicator(
          activeIndex: currentIndex.clamp(0, count - 1),
          count: count,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: Colors.white.withValues(alpha: 0.85),
            dotHeight: 6.h,
            dotWidth: 6.w,
            expansionFactor: 3,
            spacing: 6.w,
          ),
          onDotClicked: (index) => controller.animateToPage(index),
        ),
      ),
    );
  }
}

class _SliderSlide extends StatelessWidget {
  const _SliderSlide({
    required this.item,
    required this.isActive,
    this.onTap,
  });

  final SliderItemModel item;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: AppColors.homeBannerBg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.isVideo)
              _SliderVideoPlayer(url: item.mediaUrl, isActive: isActive)
            else
              CachedNetworkImage(
                imageUrl: item.mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: (screenWidth * dpr).round().clamp(1, 2048),
                memCacheHeight:
                    (MediaQuery.sizeOf(context).height * 0.5 * dpr)
                        .round()
                        .clamp(1, 2048),
                fadeInDuration: const Duration(milliseconds: 120),
                fadeOutDuration: Duration.zero,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  size: 40.sp,
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
            if (item.title.trim().isNotEmpty)
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 36.h,
                child: Text(
                  item.title,
                  style: AppTextStyles.homeLogoTitle().copyWith(
                    fontSize: 13.sp,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                      ),
                    ],
                  ),
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

class _SliderVideoPlayer extends StatefulWidget {
  const _SliderVideoPlayer({
    required this.url,
    required this.isActive,
  });

  final String url;
  final bool isActive;

  @override
  State<_SliderVideoPlayer> createState() => _SliderVideoPlayerState();
}

class _SliderVideoPlayerState extends State<_SliderVideoPlayer> {
  VideoPlayerController? _controller;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant _SliderVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeController();
      _initController();
      return;
    }
    _syncPlayback();
  }

  Future<void> _initController() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() => _hasError = false);
      _syncPlayback();
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (widget.isActive) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Icon(
        Icons.videocam_off_outlined,
        size: 40.sp,
        color: AppColors.primary.withValues(alpha: 0.35),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeBannerBg,
      child: child,
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ART INSPIRATION',
                  style: AppTextStyles.homeLogoTitle().copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'اكتشفي جمالك مع أفضل منتجات العناية',
                  style: AppTextStyles.homeProductDescription(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.spa_outlined,
            size: 48.sp,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
