import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/global_floating_cart_overlay.dart';

/// جذر التطبيق
class ArtInspirationApp extends ConsumerWidget {
  const ArtInspirationApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          scrollBehavior: const AppScrollBehavior(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  if (child != null) child,
                  ListenableBuilder(
                    listenable: router.routeInformationProvider,
                    builder: (context, _) {
                      return GlobalFloatingCartOverlay(
                        location:
                            router.routeInformationProvider.value.uri.path,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
