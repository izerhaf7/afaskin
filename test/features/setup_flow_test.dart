import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

Future<void> _runSetup(WidgetTester tester, double scale) async {
  final stores = await pumpApp(tester, textScale: scale);

  // Splash -> onboarding.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  expect(find.text('Kenali kulitmu'), findsOneWidget);

  // Walk all 3 onboarding pages.
  await tapVisible(tester, find.text('Lanjut'));
  expect(find.text('Cara kerjanya'), findsOneWidget);
  await tapVisible(tester, find.text('Lanjut'));
  expect(find.text('Tips foto yang baik'), findsOneWidget);
  await tapVisible(tester, find.text('Mulai'));

  // Consent: button disabled until both boxes are ticked.
  expect(find.text('Sebelum mulai'), findsOneWidget);
  final accept = find.widgetWithText(FilledButton, 'Setuju dan lanjut');
  expect(tester.widget<FilledButton>(accept).enabled, isFalse);
  await tapVisible(tester, find.byType(Checkbox).first);
  expect(tester.widget<FilledButton>(accept).enabled, isFalse);
  await tapVisible(tester, find.byType(Checkbox).last);
  expect(tester.widget<FilledButton>(accept).enabled, isTrue);
  await tapVisible(tester, accept);

  // Profile: validation, then fill.
  expect(find.text('Profil kamu'), findsOneWidget);
  await tapVisible(tester, find.text('Lanjut'));
  expect(find.text('Masukkan umur antara 12 dan 100 tahun.'), findsOneWidget);
  await tester.enterText(find.byKey(const Key('profile_age')), '21');
  await tapVisible(tester, find.text('Perempuan'));
  await tapVisible(tester, find.text('Sampai Rp150.000'));
  await tapVisible(tester, find.text('Lanjut'));

  // Questionnaire from mock: 7 questions.
  await waitFor(tester, find.text('Pertanyaan 1 dari 7'));
  for (var i = 1; i <= 7; i++) {
    expect(find.text('Pertanyaan $i dari 7'), findsOneWidget);
    await tapVisible(tester, find.text('3'));
    await tapVisible(tester, find.text(i == 7 ? 'Selesai' : 'Lanjut'));
  }

  // Home tab.
  expect(find.text('Siap cek kulitmu?'), findsOneWidget);
  expect(stores.flags.onboardingDone && stores.flags.consentAccepted, isTrue);
  expect(
    stores.user.profile,
    const UserProfile(age: 21, gender: Gender.female, budgetMax: 150000),
  );
  expect(stores.user.answers!.answers.length, 7);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'first run: splash -> onboarding -> consent -> profile -> '
    'questionnaire -> home',
    (tester) => _runSetup(tester, 1),
  );

  testWidgets(
    'same flow works at 130% text scale',
    (tester) => _runSetup(tester, 1.3),
  );

  testWidgets('returning user lands on home and can switch tabs', (
    tester,
  ) async {
    await pumpApp(
      tester,
      flags: MemoryFlagStore(onboardingDone: true, consentAccepted: true),
      user: MemoryUserStore()
        ..profile = const UserProfile(
          age: 21,
          gender: Gender.male,
          budgetMax: 50000,
        )
        ..answers = const QuestionnaireAnswers(
          version: 'v',
          answers: {'q1': 1},
        ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Siap cek kulitmu?'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat'), findsOneWidget);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profil'));
    await tester.pumpAndSettle();
    // Edit mode pre-fills the saved profile.
    expect(find.text('21'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('consent not accepted yet: resumes at consent', (tester) async {
    await pumpApp(tester, flags: MemoryFlagStore(onboardingDone: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Sebelum mulai'), findsOneWidget);
  });
}
