import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/capture/capture_page.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

class _FakePermission implements CameraPermissionService {
  _FakePermission(this.current, {this.onRequest});

  CameraPermissionState current;
  final CameraPermissionState? onRequest;
  int settingsOpened = 0;

  @override
  Future<CameraPermissionState> status() async => current;
  @override
  Future<CameraPermissionState> request() async =>
      current = onRequest ?? current;
  @override
  Future<void> openSettings() async => settingsOpened++;
}

class _FakeGallery implements GalleryPicker {
  _FakeGallery(this.result);
  final Uint8List? result;
  @override
  Future<Uint8List?> pick() async => result;
}

class _MockRepo extends Mock implements AnalysisRepository;

final _raw = Uint8List.fromList([1, 2, 3]);
final _processed = Uint8List.fromList([9, 9, 9]);

/// Stand-in for the live camera: a button that "captures" [_raw].
Widget _fakeCamera({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
}) => Center(
  child: TextButton(
    onPressed: () => onCaptured(_raw),
    child: Text(active ? 'FAKE SHUTTER' : 'PAUSED'),
  ),
);

Future<ProviderContainer> _openCapture(
  WidgetTester tester, {
  required _FakePermission permission,
  AnalysisRepository? repo,
  Uint8List? gallery,
}) async {
  final stores = setupDoneStores();
  await pumpApp(
    tester,
    flags: stores.flags,
    user: stores.user,
    repo: repo,
    overrides: [
      cameraPermissionProvider.overrideWithValue(permission),
      galleryPickerProvider.overrideWithValue(_FakeGallery(gallery)),
      cameraViewBuilderProvider.overrideWithValue(_fakeCamera),
      photoProcessorProvider.overrideWithValue((raw) async {
        expect(raw, _raw);
        return _processed;
      }),
    ],
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('Mulai analisis'));
  // Saved answers -> re-analyze sheet -> straight to the camera.
  await tapVisible(tester, find.text('Langsung ambil foto'));
  return ProviderScope.containerOf(tester.element(find.byType(CapturePage)));
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      const AnalyzePayload(
        profile: UserProfile(age: 1, gender: Gender.unspecified, budgetMax: 1),
        questionnaire: {},
      ),
    );
  });

  testWidgets('explains before asking, then captures and analyzes', (
    tester,
  ) async {
    final permission = _FakePermission(
      CameraPermissionState.denied,
      onRequest: CameraPermissionState.granted,
    );
    final container = await _openCapture(tester, permission: permission);

    // Rationale first, not the system dialog.
    expect(find.text('Izinkan akses kamera'), findsOneWidget);
    await tapVisible(tester, find.text('Izinkan kamera'));
    expect(find.text('FAKE SHUTTER'), findsOneWidget);

    await tapVisible(tester, find.text('FAKE SHUTTER'));
    await waitFor(tester, find.text('Hasil analisis'));

    // Photo is dropped from memory once the server accepted it, and the
    // result (not the photo) lands in history.
    expect(container.read(pendingPhotoProvider), isNull);
    expect(container.read(historyProvider), hasLength(1));
    expect(
      container.read(latestAnalysisProvider)!.skinType.label,
      SkinType.oily,
    );
  });

  testWidgets('permanently denied: points to phone settings, gallery works', (
    tester,
  ) async {
    final permission = _FakePermission(CameraPermissionState.permanentlyDenied);
    await _openCapture(tester, permission: permission, gallery: _raw);

    expect(find.text('Akses kamera ditolak'), findsOneWidget);
    await tapVisible(tester, find.text('Buka pengaturan HP'));
    expect(permission.settingsOpened, 1);

    await tapVisible(tester, find.text('Pilih dari galeri'));
    await waitFor(tester, find.text('Hasil analisis'));
  });

  testWidgets('quality rejected: shows reasons and returns to the camera', (
    tester,
  ) async {
    final container = await _openCapture(
      tester,
      permission: _FakePermission(CameraPermissionState.granted),
      repo: AnalysisRepositoryMock(
        PlatformAssetBundle(),
        scenario: MockScenario.qualityFail,
        latency: Duration.zero,
      ),
    );
    await tapVisible(tester, find.text('FAKE SHUTTER'));
    await waitFor(tester, find.text('Foto perlu diambil ulang'));

    expect(find.text('Foto terlalu gelap'), findsOneWidget);
    expect(find.text('Foto kurang tajam'), findsOneWidget);
    expect(container.read(pendingPhotoProvider), isNull);

    await tapVisible(tester, find.text('Ambil ulang foto'));
    // Back on the camera, stream resumed.
    expect(find.text('FAKE SHUTTER'), findsOneWidget);
  });

  testWidgets('network error keeps the photo and retries', (tester) async {
    final repo = _MockRepo();
    var calls = 0;
    when(
      () => repo.analyze(
        imageJpeg: any(named: 'imageJpeg'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((inv) async {
      expect(inv.namedArguments[#imageJpeg], _processed);
      if (calls++ == 0) throw const NetworkFailure();
      return await fastMockRepo().analyze(
        imageJpeg: _processed,
        payload: inv.namedArguments[#payload] as AnalyzePayload,
      );
    });

    final container = await _openCapture(
      tester,
      permission: _FakePermission(CameraPermissionState.granted),
      repo: repo,
    );
    await tapVisible(tester, find.text('FAKE SHUTTER'));
    await waitFor(tester, find.text('Coba lagi'));
    expect(find.text('Koneksi terputus'), findsOneWidget);
    expect(container.read(pendingPhotoProvider), _processed);

    await tapVisible(tester, find.text('Coba lagi'));
    await waitFor(tester, find.text('Hasil analisis'));
    expect(calls, 2);

    final payload =
        verify(
              () => repo.analyze(
                imageJpeg: any(named: 'imageJpeg'),
                payload: captureAny(named: 'payload'),
              ),
            ).captured.last
            as AnalyzePayload;
    expect(payload.profile.budgetMax, 150000);
    expect(payload.questionnaire, {'q1': 4, 'q2': 2});
  });
}
