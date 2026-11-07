import 'dart:typed_data';
import 'dart:ui';

import 'package:afaskin/features/capture/face_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

const _cfg = GuidanceConfig();

/// A face centered in the oval, sized at 85% of the oval width.
FaceObservation _face({
  double dx = 0,
  double dy = 0,
  double scale = 0.85,
  double? yaw = 0,
  double? pitch = 0,
}) {
  final w = _cfg.oval.width * scale;
  final h = w * 1.25;
  final c = _cfg.oval.center + Offset(dx, dy);
  return FaceObservation(
    box: Rect.fromCenter(center: c, width: w, height: h),
    yaw: yaw,
    pitch: pitch,
  );
}

GuidanceStatus _eval(List<FaceObservation> faces, {double? lum = 130}) =>
    evaluateGuidance(faces: faces, luminance: lum);

void main() {
  group('evaluateGuidance', () {
    test('ready when centered, frontal, well lit', () {
      expect(_eval([_face()]), GuidanceStatus.ready);
      expect(GuidanceStatus.ready.isReady, isTrue);
    });

    test('no face / multiple faces', () {
      expect(_eval([]), GuidanceStatus.noFace);
      expect(_eval([_face(), _face(dx: 0.1)]), GuidanceStatus.multipleFaces);
    });

    test('lighting', () {
      expect(_eval([_face()], lum: 40), GuidanceStatus.tooDark);
      // Darkness wins even with no face (detection is unreliable then).
      expect(_eval([], lum: 40), GuidanceStatus.tooDark);
      expect(_eval([_face()], lum: 240), GuidanceStatus.tooBright);
      // Unknown luminance skips the light check.
      expect(_eval([_face()], lum: null), GuidanceStatus.ready);
    });

    test('distance', () {
      expect(_eval([_face(scale: 0.4)]), GuidanceStatus.tooFar);
      expect(_eval([_face(scale: 1.4)]), GuidanceStatus.tooClose);
    });

    test('position inside the oval', () {
      expect(_eval([_face(dx: 0.15)]), GuidanceStatus.offCenter);
      expect(_eval([_face(dy: -0.15)]), GuidanceStatus.offCenter);
      expect(_eval([_face(dx: 0.03)]), GuidanceStatus.ready);
    });

    test('head angle within +-15 degrees', () {
      expect(_eval([_face(yaw: 20)]), GuidanceStatus.notFrontal);
      expect(_eval([_face(pitch: -16)]), GuidanceStatus.notFrontal);
      expect(_eval([_face(yaw: 14.9, pitch: -14.9)]), GuidanceStatus.ready);
      expect(_eval([_face(yaw: null, pitch: null)]), GuidanceStatus.ready);
    });

    test('side photo: turn 20-50 degrees, second side the other way', () {
      GuidanceStatus side(double? yaw, {double? avoid}) => evaluateGuidance(
        faces: [_face(yaw: yaw)],
        luminance: 130,
        pose: CapturePose.side,
        avoidYawSign: avoid,
      );
      expect(side(5), GuidanceStatus.turnHead);
      expect(side(-19.9), GuidanceStatus.turnHead);
      expect(side(30), GuidanceStatus.ready);
      expect(side(-30), GuidanceStatus.ready);
      expect(side(60), GuidanceStatus.turnLess);
      // First side photo was +30: the second must turn to negative yaw.
      expect(side(30, avoid: 1), GuidanceStatus.turnOtherSide);
      expect(side(-30, avoid: 1), GuidanceStatus.ready);
      // No yaw from the detector: leave it to the server.
      expect(side(null), GuidanceStatus.ready);
      // The front photo rule is unchanged.
      expect(_eval([_face(yaw: 30)]), GuidanceStatus.notFrontal);
    });

    test('every status has an Indonesian message', () {
      for (final s in GuidanceStatus.values) {
        expect(s.message, isNotEmpty);
      }
      expect(GuidanceStatus.tooFar.message, 'Dekatkan wajah');
      expect(GuidanceStatus.tooDark.message, 'Cari tempat lebih terang');
      expect(GuidanceStatus.notFrontal.message, 'Hadapkan wajah lurus');
    });
  });

  test('normalizeFaceBox mirrors x for the front camera', () {
    const box = Rect.fromLTRB(100, 200, 300, 500);
    final plain = normalizeFaceBox(
      box,
      uprightWidth: 1000,
      uprightHeight: 1000,
      mirror: false,
    );
    expect(plain, const Rect.fromLTRB(0.1, 0.2, 0.3, 0.5));
    final mirrored = normalizeFaceBox(
      box,
      uprightWidth: 1000,
      uprightHeight: 1000,
      mirror: true,
    );
    expect(mirrored.left, closeTo(0.7, 1e-9));
    expect(mirrored.right, closeTo(0.9, 1e-9));
  });

  test('meanLuma / meanLumaBgra', () {
    final y = Uint8List(64 * 64)..fillRange(0, 64 * 64, 100);
    expect(meanLuma(y, width: 64, height: 64, bytesPerRow: 64), 100);
    final bgra = Uint8List(16 * 16 * 4);
    for (var i = 0; i < bgra.length; i += 4) {
      bgra
        ..[i] = 200
        ..[i + 1] = 200
        ..[i + 2] = 200
        ..[i + 3] = 255;
    }
    expect(
      meanLumaBgra(bgra, width: 16, height: 16, bytesPerRow: 64),
      closeTo(200, 0.01),
    );
  });
}
