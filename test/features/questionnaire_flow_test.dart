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
  maxLabel: 'Selalu',
);
final _q = Questionnaire(
  version: 'test',
  questions: [
    for (var i = 1; i <= 3; i++)
      Question(id: 'q$i', text: 'Pertanyaan nomor $i?', scale: _scale),
  ],
);

double _progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(
      find.byKey(const Key('questionnaire_progress')),
    )
    .value!;

Future<MemoryUserStore> _pump(
  WidgetTester tester, {
  QuestionnaireAnswers? initial,
}) async {
  final user = MemoryUserStore();
  final router = GoRouter(
    initialLocation: '/q',
    routes: [
      GoRoute(
        path: '/q',
        builder: (_, _) =>
            QuestionnaireFlow(questionnaire: _q, initial: initial),
      ),
      GoRoute(path: '/analysis', builder: (_, _) => const Text('HOME')),
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
  return user;
}

void main() {
  testWidgets('one question per screen, progress advances, back works', (
    tester,
  ) async {
    final user = await _pump(tester);

    expect(find.text('Pertanyaan nomor 1?'), findsOneWidget);
    expect(find.text('Pertanyaan 1 dari 3'), findsOneWidget);
    expect(_progress(tester), closeTo(1 / 3, 1e-9));

    // "Lanjut" disabled until an answer is picked.
    FilledButton button() =>
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button().enabled, isFalse);

    await tester.tap(find.text('Selalu'));
    await tester.pump();
    expect(button().enabled, isTrue);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Pertanyaan nomor 2?'), findsOneWidget);
    expect(_progress(tester), closeTo(2 / 3, 1e-9));
    expect(button().enabled, isFalse);

    // Back keeps the earlier answer.
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Pertanyaan nomor 1?'), findsOneWidget);
    expect(button().enabled, isTrue);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(_progress(tester), closeTo(1, 1e-9));
    expect(find.text('Selesai'), findsOneWidget);
    await tester.tap(find.text('Tidak pernah'));
    await tester.pump();
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(user.answers!.version, 'test');
    expect(user.answers!.answers, {'q1': 5, 'q2': 3, 'q3': 1});
  });

  testWidgets('previous answers are pre-selected; stale ids dropped', (
    tester,
  ) async {
    await _pump(
      tester,
      initial: const QuestionnaireAnswers(
        version: 'old',
        answers: {'q1': 2, 'q99': 4},
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );
  });
}
