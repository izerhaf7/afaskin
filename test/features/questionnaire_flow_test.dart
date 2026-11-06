import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/questionnaire/questionnaire_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _scale = LikertScale(
  min: 1,
  max: 5,
  minLabel: 'Tidak pernah',
  maxLabel: 'Hampir selalu',
  labels: [
    'Tidak pernah',
    'Jarang',
    'Kadang-kadang',
    'Sering',
    'Hampir selalu',
  ],
);
final _q = Questionnaire(
  version: 'test',
  questions: [
    for (var i = 1; i <= 3; i++)
      Question(id: 'q$i', text: 'Pertanyaan nomor $i?', scale: _scale),
  ],
);

double _progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byKey(const Key('flow_progress')))
    .value!;

FilledButton _cta(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

Future<MemoryUserStore> _pump(
  WidgetTester tester, {
  QuizMode mode = QuizMode.setup,
  QuestionnaireAnswers? initial,
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Alfa animates forever otherwise; reduced motion freezes him.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final user = MemoryUserStore()..name = 'Rani';
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (_, _) => const Text('START'),
        routes: [
          GoRoute(
            path: 'q',
            builder: (_, _) => QuestionnaireFlow(
              questionnaire: _q,
              mode: mode,
              initial: initial,
              autoAdvance: const Duration(milliseconds: 100),
            ),
          ),
        ],
      ),
      GoRoute(path: AppRoutes.capture, builder: (_, _) => const Text('CAMERA')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flagStoreProvider.overrideWithValue(MemoryFlagStore()),
        userStoreProvider.overrideWithValue(user),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.go('/start/q');
  await tester.pumpAndSettle();
  return user;
}

void main() {
  testWidgets('Alfa asks one question at a time; picking auto-advances', (
    tester,
  ) async {
    final user = await _pump(tester);

    expect(find.text('Pertanyaan nomor 1?'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(
      find.text('Makasih, Rani! Sekarang 3 pertanyaan singkat, ya.'),
      findsOneWidget,
    );
    expect(_progress(tester), closeTo(1 / 3, 1e-9));
    // Every value has its own label.
    for (final l in _scale.labels!) {
      expect(find.text(l), findsOneWidget);
    }
    expect(_cta(tester).enabled, isFalse);

    // Picking an answer moves on by itself.
    await tester.tap(find.text('Hampir selalu'));
    await tester.pumpAndSettle();
    expect(find.text('Pertanyaan nomor 2?'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(_progress(tester), closeTo(2 / 3, 1e-9));
    expect(_cta(tester).enabled, isFalse);

    // Back keeps the earlier answer, and "Lanjut" works too.
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Pertanyaan nomor 1?'), findsOneWidget);
    expect(_cta(tester).enabled, isTrue);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kadang-kadang'));
    await tester.pumpAndSettle();

    // Last question: lead line and "Ambil foto wajah".
    expect(find.text('Pertanyaan terakhir!'), findsOneWidget);
    expect(find.text('Ambil foto wajah'), findsOneWidget);
    await tester.tap(find.text('Tidak pernah'));
    await tester.pumpAndSettle();
    // No auto-advance past the last question.
    expect(find.text('Pertanyaan nomor 3?'), findsOneWidget);

    await tester.tap(find.text('Ambil foto wajah'));
    await tester.pumpAndSettle();

    expect(find.text('CAMERA'), findsOneWidget);
    expect(user.answers!.version, 'test');
    expect(user.answers!.answers, {'q1': 5, 'q2': 3, 'q3': 1});
    expect(user.answers!.answeredAt, isNotNull);
  });

  testWidgets('edit mode saves and goes back; old answers pre-selected', (
    tester,
  ) async {
    final user = await _pump(
      tester,
      mode: QuizMode.edit,
      initial: const QuestionnaireAnswers(
        version: 'old',
        answers: {'q1': 2, 'q2': 4, 'q3': 1, 'q99': 4},
      ),
    );
    expect(_cta(tester).enabled, isTrue);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('START'), findsOneWidget);
    // Stale question id dropped.
    expect(user.answers!.answers, {'q1': 2, 'q2': 4, 'q3': 1});
  });

  test('LikertScale.labelFor falls back to end labels', () {
    const plain = LikertScale(
      min: 1,
      max: 5,
      minLabel: 'Tidak pernah',
      maxLabel: 'Selalu',
    );
    expect(plain.labelFor(1), 'Tidak pernah');
    expect(plain.labelFor(3), isNull);
    expect(plain.labelFor(5), 'Selalu');
    expect(_scale.labelFor(2), 'Jarang');
  });
}
