import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/features/analysis/analyzing_page.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/capture/capture_page.dart';
import 'package:afaskin/features/consent/consent_page.dart';
import 'package:afaskin/features/history/history_page.dart';
import 'package:afaskin/features/home/analysis_home_page.dart';
import 'package:afaskin/features/home/home_shell.dart';
import 'package:afaskin/features/onboarding/onboarding_page.dart';
import 'package:afaskin/features/profile/profile_page.dart';
import 'package:afaskin/features/questionnaire/questionnaire_page.dart';
import 'package:afaskin/features/recommendation/product_detail_page.dart';
import 'package:afaskin/features/recommendation/recommendations_page.dart';
import 'package:afaskin/features/settings/settings_page.dart';
import 'package:afaskin/features/splash/splash_page.dart';
import 'package:afaskin/features/style_guide/style_guide_page.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const String splash = '/';

  // First-run setup, in order.
  static const String onboarding = '/onboarding';
  static const String consent = '/consent';
  static const String setupProfile = '/setup/profile';
  static const String setupQuestionnaire = '/setup/questionnaire';

  // Main tabs.
  static const String home = '/analysis';
  static const String history = '/history';
  static const String settings = '/settings';

  // Full-screen flows (above the tab bar).
  static const String capture = '/analysis/capture';
  static const String analyzing = '/analysis/capture/analyzing';
  static const String result = '/analysis/result';
  static String recommendations(String analysisId) =>
      '/analysis/recommendations/${Uri.encodeComponent(analysisId)}';
  static String product(String id) =>
      '/analysis/product/${Uri.encodeComponent(id)}';
  static const String editProfile = '/edit/profile';
  static const String editQuestionnaire = '/edit/questionnaire';
  static const String about = '/about';

  /// Debug builds only.
  static const String styleGuide = '/dev/style-guide';

  static const List<String> setupOrder = [
    onboarding,
    consent,
    setupProfile,
    setupQuestionnaire,
  ];

  static String forStep(SetupStep? step) => switch (step) {
    SetupStep.onboarding => onboarding,
    SetupStep.consent => consent,
    SetupStep.profile => setupProfile,
    SetupStep.questionnaire => setupQuestionnaire,
    null => home,
  };
}

/// Pure redirect rule, kept separate so it can be unit-tested.
///
/// - Until setup is complete, only setup routes up to the first unfinished
///   step are reachable (no skipping consent via a deep link).
/// - After setup, the setup routes bounce to home.
String? setupRedirect(SessionState session, String location) {
  if (location == AppRoutes.splash) return null;
  final step = session.nextStep;
  final locIndex = AppRoutes.setupOrder.indexOf(location);

  if (step != null) {
    final required = AppRoutes.forStep(step);
    final reqIndex = AppRoutes.setupOrder.indexOf(required);
    if (location == AppRoutes.styleGuide && kDebugMode) return null;
    if (locIndex == -1 || locIndex > reqIndex) return required;
    return null;
  }
  return locIndex == -1 ? null : AppRoutes.home;
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // Re-run redirects whenever setup progress changes.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) =>
        setupRedirect(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(path: AppRoutes.consent, builder: (_, _) => const ConsentPage()),
      GoRoute(
        path: AppRoutes.setupProfile,
        builder: (_, _) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.setupQuestionnaire,
        builder: (_, _) => const QuestionnairePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const AnalysisHomePage(),
                routes: [
                  // Full-screen (root navigator), stacked above the tab.
                  GoRoute(
                    path: 'capture',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const CapturePage(),
                    routes: [
                      GoRoute(
                        path: 'analyzing',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const AnalyzingPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'result',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ResultPage(),
                  ),
                  GoRoute(
                    path: 'recommendations/:analysisId',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => RecommendationsPage(
                      analysisId: state.pathParameters['analysisId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'product/:id',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => ProductDetailPage(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: rootKey,
        builder: (_, _) => const ProfilePage(editing: true),
      ),
      GoRoute(
        path: AppRoutes.editQuestionnaire,
        parentNavigatorKey: rootKey,
        builder: (_, _) => const QuestionnairePage(editing: true),
      ),
      GoRoute(
        path: AppRoutes.about,
        parentNavigatorKey: rootKey,
        builder: (_, _) => const ComingSoonPage(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.styleGuide,
          parentNavigatorKey: rootKey,
          builder: (_, _) => const StyleGuidePage(),
        ),
    ],
  );
}
