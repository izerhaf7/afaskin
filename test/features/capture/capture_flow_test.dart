import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/capture/capture_page.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:afaskin/features/capture/face_guidance.dart';
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

/// PNG 1x1 valid untuk jalur galeri: layar "Atur posisi" men-decode byte ini
/// untuk mendapat ukuran gambar, jadi tidak boleh byte acak.
final _galleryImage = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB4, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Poses the fake camera was asked for, in order (reset per test).
final _poses = <CapturePose>[];

/// Stand-in for the live camera: a button that "captures" [_raw]. Reports a
/// yaw of +30° for side photos, like ML Kit would for a turned head.
Widget _fakeCamera({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
  CapturePose pose = CapturePose.front,
  double? avoidYawSign,
  ValueChanged<double?>? onYawCaptured,
}) => Center(
  child: TextButton(
    onPressed: () {
      _poses.add(pose);
      onYawCaptured?.call(pose == CapturePose.side ? 30 : 0);
      onCaptured(_raw);
    },
    child: Text(active ? 'FAKE SHUTTER' : 'PAUSED'),
  ),
);

/// Front photo, then skip the optional side photos.
Future<void> _captureFrontOnly(WidgetTester tester) async {
  await tapVisible(tester, find.text('FAKE SHUTTER'));
  await tapVisible(tester, find.text('Lewati, analisis sekarang'));
}

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
        // Jalur galeri memakai PNG valid supaya layar "Atur posisi" bisa
        // membaca ukuran gambar; jalur kamera memakai byte penanda biasa.
        final isGallery = raw == _galleryImage;
        expect(isGallery || raw == _raw, isTrue);
        return isGallery ? _galleryImage : _processed;
      }),
      // Layar "Atur posisi" tidak bisa men-decode byte palsu di test VM, jadi
      // crop-nya diganti: yang diuji di sini adalah alurnya, bukan geometri.
      photoCropProvider.overrideWithValue(
        (raw, rect, {int target = 1200}) async {
          expect(raw, _galleryImage);
          return _processed;
        },
      ),
      photoSizeProvider.overrideWithValue((_) async => const Size(400, 600)),
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
  setUp(_poses.clear);

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<Uint8List>[]);
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

    // Three views: front, then both sides (each side photo turns the other way).
    expect(find.text('Foto 1 dari 3 · Tampak depan'), findsOneWidget);
    await tapVisible(tester, find.text('FAKE SHUTTER'));
    expect(find.text('Foto 2 dari 3 · Tampak samping'), findsOneWidget);
    await tapVisible(tester, find.text('FAKE SHUTTER'));
    expect(find.text('Foto 3 dari 3 · Sisi lainnya'), findsOneWidget);
    await tapVisible(tester, find.text('FAKE SHUTTER'));
    await waitFor(tester, find.text('Hasil analisis'));
    expect(_poses, [CapturePose.front, CapturePose.side, CapturePose.side]);

    // Photos are dropped from memory once the server accepted them, and the
    // result (not the photo) lands in history.
    expect(container.read(pendingPhotoProvider), isNull);
    expect(container.read(pendingSidePhotosProvider), isEmpty);
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
    await _openCapture(tester, permission: permission, gallery: _galleryImage);

    expect(find.text('Akses kamera ditolak'), findsOneWidget);
    await tapVisible(tester, find.text('Buka pengaturan HP'));
    expect(permission.settingsOpened, 1);

    await tapVisible(tester, find.text('Pilih dari galeri'));
    await waitFor(tester, find.text('Atur posisi'));
    await tapVisible(tester, find.text('Gunakan foto ini'));
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
    await _captureFrontOnly(tester);
    await waitFor(tester, find.text('Foto perlu diambil ulang'));

    expect(find.text('Foto terlalu gelap'), findsOneWidget);
    expect(find.text('Foto kurang tajam'), findsOneWidget);
    expect(container.read(pendingPhotoProvider), isNull);

    await tapVisible(tester, find.text('Ambil ulang foto'));
    // Back on the camera at the front photo, stream resumed.
    expect(find.text('FAKE SHUTTER'), findsOneWidget);
    expect(find.text('Foto 1 dari 3 · Tampak depan'), findsOneWidget);
  });

  testWidgets('network error keeps the photo and retries', (tester) async {
    final repo = _MockRepo();
    var calls = 0;
    when(
      () => repo.analyze(
        imageJpeg: any(named: 'imageJpeg'),
        payload: any(named: 'payload'),
        onStage: any(named: 'onStage'),
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
    await _captureFrontOnly(tester);
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
                onStage: any(named: 'onStage'),
              ),
            ).captured.last
            as AnalyzePayload;
    expect(payload.profile.budgetMax, 150000);
    expect(payload.questionnaire, {'q1': 4, 'q2': 2});
  });

  testWidgets('side photos are sent together with the front photo', (
    tester,
  ) async {
    final repo = _MockRepo();
    when(
      () => repo.analyze(
        imageJpeg: any(named: 'imageJpeg'),
        payload: any(named: 'payload'),
        sideImagesJpeg: any(named: 'sideImagesJpeg'),
        onStage: any(named: 'onStage'),
      ),
    ).thenAnswer(
      (inv) => fastMockRepo().analyze(
        imageJpeg: _processed,
        payload: inv.namedArguments[#payload] as AnalyzePayload,
      ),
    );
    await _openCapture(
      tester,
      permission: _FakePermission(CameraPermissionState.granted),
      repo: repo,
    );
    await tapVisible(tester, find.text('FAKE SHUTTER')); // front
    await tapVisible(tester, find.text('FAKE SHUTTER')); // first side
    await tapVisible(tester, find.text('Lewati, analisis sekarang'));
    await waitFor(tester, find.text('Hasil analisis'));

    final sides =
        verify(
              () => repo.analyze(
                imageJpeg: any(named: 'imageJpeg'),
                payload: any(named: 'payload'),
                sideImagesJpeg: captureAny(named: 'sideImagesJpeg'),
                onStage: any(named: 'onStage'),
              ),
            ).captured.single
            as List<Uint8List>;
    expect(sides, [_processed]);
  });
}
