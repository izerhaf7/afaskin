import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

class _NoCamera implements CameraPermissionService {
  @override
  Future<CameraPermissionState> status() async => CameraPermissionState.denied;
  @override
  Future<CameraPermissionState> request() async => CameraPermissionState.denied;
  @override
  Future<void> openSettings() async {}
}

bool _enabled(WidgetTester tester, String label) => tester
    .widget<FilledButton>(find.widgetWithText(FilledButton, label))
    .enabled;

Future<void> _runSetup(WidgetTester tester, double scale) async {
  final stores = await pumpApp(
    tester,
    textScale: scale,
    size: const Size(390, 844),
    overrides: [cameraPermissionProvider.overrideWithValue(_NoCamera())],
  );

  // Splash -> onboarding.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  expect(find.text('Kenali kulitmu dari satu foto'), findsOneWidget);
  await tapVisible(tester, find.text('Lanjut'));
  expect(find.text('Tiga langkah, kurang dari semenit'), findsOneWidget);
  await tapVisible(tester, find.text('Lanjut'));
  expect(find.text('Foto yang baik, hasil yang akurat'), findsOneWidget);
  await tapVisible(tester, find.text('Mulai'));

  // Consent: both cards must be ticked.
  expect(find.text('Sebelum mulai'), findsOneWidget);
  expect(_enabled(tester, 'Setuju dan lanjut'), isFalse);
  await tapVisible(tester, find.byKey(const Key('consent_medical')));
  expect(_enabled(tester, 'Setuju dan lanjut'), isFalse);
  await tapVisible(tester, find.byKey(const Key('consent_photo')));
  expect(_enabled(tester, 'Setuju dan lanjut'), isTrue);
  await tapVisible(tester, find.text('Setuju dan lanjut'));

  // Profile: nickname, then age (17+).
  expect(
    find.text('Kenalan dulu dong, Alfa mau tau nih nama kamu?'),
    findsOneWidget,
  );
  expect(find.text('1/2'), findsOneWidget);
  expect(_enabled(tester, 'Lanjut'), isFalse);
  await tester.enterText(find.byKey(const Key('profile_name')), 'Rani');
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('Lanjut'));

  expect(find.text('Salam kenal, Rani! Umur kamu berapa?'), findsOneWidget);
  await tester.enterText(find.byKey(const Key('profile_age')), '15');
  await tester.pumpAndSettle();
  expect(
    find.text('Waduh, sepertinya umurnya belum cukup nih.'),
    findsOneWidget,
  );
  expect(
    find.text('Afa Skin untuk pengguna 17 tahun ke atas.'),
    findsOneWidget,
  );
  expect(_enabled(tester, 'Lanjut ke kuesioner'), isFalse);
  await tester.enterText(find.byKey(const Key('profile_age')), '23');
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('Lanjut ke kuesioner'));

  // Questionnaire from mock: 7 questions, auto-advance after each pick.
  await waitFor(tester, find.text('1/7'));
  expect(find.textContaining('Makasih, Rani!'), findsOneWidget);
  for (var i = 1; i <= 7; i++) {
    expect(find.text('$i/7'), findsOneWidget);
    await tapVisible(tester, find.text('3'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }
  await tapVisible(tester, find.text('Ambil foto wajah'));

  // Setup ends at the camera (permission explained first).
  expect(find.text('Izinkan akses kamera'), findsOneWidget);
  expect(stores.flags.onboardingDone && stores.flags.consentAccepted, isTrue);
  expect(stores.user.name, 'Rani');
  // Gender and budget are asked later ("Lengkapi profilmu").
  expect(stores.user.profile, const UserProfile(age: 23));
  expect(stores.user.answers!.answers.length, 7);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'first run: splash -> onboarding -> consent -> nickname/age -> '
    'questionnaire -> camera',
    (tester) => _runSetup(tester, 1),
  );

  testWidgets(
    'same flow works at 130% text scale',
    (tester) => _runSetup(tester, 1.3),
  );

  testWidgets('returning user lands on home and can switch tabs', (
    tester,
  ) async {
    final stores = setupDoneStores();
    await pumpApp(tester, flags: stores.flags, user: stores.user);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Bagaimana kulitmu hari ini?'), findsOneWidget);
    // No history yet: first-analysis card.
    expect(find.text('Analisis pertama'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat'), findsOneWidget);

    await tester.tap(find.text('Pengaturan').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Rani · 21 tahun · Perempuan'), findsOneWidget);
    await tester.tap(find.text('Ubah'));
    await tester.pumpAndSettle();
    // Edit mode walks all four questions, pre-filled.
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('Rani'), findsOneWidget);
  });

  testWidgets('consent not accepted yet: resumes at consent', (tester) async {
    await pumpApp(tester, flags: MemoryFlagStore(onboardingDone: true));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Sebelum mulai'), findsOneWidget);
  });
}
