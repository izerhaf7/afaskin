import 'package:afaskin/app.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

AnalysisRepository fastMockRepo() =>
    // Fresh bundle per test: rootBundle caches futures across tests, and a
    // future from a finished test's fake-async zone never completes.
    AnalysisRepositoryMock(PlatformAssetBundle(), latency: Duration.zero);

/// Pumps the whole app with in-memory stores and a zero-latency mock repo.
Future<({MemoryFlagStore flags, MemoryUserStore user})> pumpApp(
  WidgetTester tester, {
  MemoryFlagStore? flags,
  MemoryUserStore? user,
  double textScale = 1,
  Size size = const Size(360, 720),
  AnalysisRepository? repo,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  // Looping loaders respect "reduce motion", so pumpAndSettle can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final f = flags ?? MemoryFlagStore();
  final u = user ?? MemoryUserStore();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flagStoreProvider.overrideWithValue(f),
        userStoreProvider.overrideWithValue(u),
        analysisRepositoryProvider.overrideWithValue(repo ?? fastMockRepo()),
        ...overrides,
      ],
      child: const AfaSkinApp(),
    ),
  );
  return (flags: f, user: u);
}

/// Taps a widget after scrolling it into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // Lazily built list item: scroll the main list until it exists.
    await tester.dragUntilVisible(
      finder,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

/// Pumps until [finder] matches, letting real async work (asset loading)
/// run between frames.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      final texts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .join(' | ');
      throw TestFailure('Timed out waiting for $finder. On screen: $texts');
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  await tester.pumpAndSettle();
}

/// Stores for a user who already finished setup.
({MemoryFlagStore flags, MemoryUserStore user}) setupDoneStores() => (
  flags: MemoryFlagStore(onboardingDone: true, consentAccepted: true),
  user: MemoryUserStore()
    ..profile = const UserProfile(
      age: 21,
      gender: Gender.female,
      budgetMax: 150000,
    )
    ..answers = const QuestionnaireAnswers(
      version: '2026-11',
      answers: {'q1': 4, 'q2': 2},
    ),
);
