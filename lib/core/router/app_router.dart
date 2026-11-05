import 'package:afaskin/features/dev/dev_home_page.dart';
import 'package:afaskin/features/style_guide/style_guide_page.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const String home = '/';

  /// Debug builds only.
  static const String styleGuide = '/dev/style-guide';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Phase 0 placeholder; Phase 1 replaces it with splash/onboarding.
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DevHomePage(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.styleGuide,
          builder: (context, state) => const StyleGuidePage(),
        ),
    ],
  );
}
