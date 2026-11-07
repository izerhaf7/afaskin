import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:afaskin/ml/landmarks.dart';
import 'package:afaskin/ml/vision.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Crop untuk model landmark & masker kulit (Dart) vs `cv2` (Python) pada foto
/// dataset `vision_face.jpg` dengan titik MediaPipe yang sama
/// (`test/fixtures/landmark_golden.json`).
void main() {
  final g = jsonDecode(File('test/fixtures/landmark_golden.json').readAsStringSync()) as Map<String, dynamic>;
  final vg = jsonDecode(File('test/fixtures/vision_golden.json').readAsStringSync()) as Map<String, dynamic>;
  final pts = [
    for (final p in (vg['points'] as List).take(468))
      (((p as List)[0] as num).toDouble(), (p[1] as num).toDouble()),
  ];
  final im = RgbImage.from(img.decodeJpg(File('test/fixtures/vision_face.jpg').readAsBytesSync())!);

  test('transformasi crop sama dengan Python', () {
    final m = landmarkCropTransform(pts);
    final want = (g['affine'] as List).cast<num>();
    final got = [m.a, m.b, m.c, m.d, m.e, m.f];
    for (var i = 0; i < 6; i++) {
      expect(got[i], closeTo(want[i].toDouble(), 1e-6));
    }
  });

  test('crop bilinear sama dengan cv2.warpAffine', () {
    final crop = warpCrop(im, landmarkCropTransform(pts));
    final mean = [0.0, 0.0, 0.0];
    for (var i = 0; i < crop.length; i++) {
      mean[i % 3] += crop[i];
    }
    final want = (g['crop_mean'] as List).cast<num>();
    for (var c = 0; c < 3; c++) {
      expect(mean[c] / (crop.length / 3), closeTo(want[c].toDouble(), 0.002));
    }
    for (final s in g['samples'] as List) {
      final (u, v) = ((s as List)[0] as int, s[1] as int);
      for (var c = 0; c < 3; c++) {
        // Decoder JPEG (paket image vs libjpeg cv2) berbeda beberapa level per piksel.
        expect(crop[(v * 256 + u) * 3 + c], closeTo((s[2 + c] as num).toDouble(), 4 / 255));
      }
    }
  });

  test('keluaran model dipetakan balik ke koordinat foto', () {
    final m = landmarkCropTransform(pts);
    // Titik crop (128, 128) = pusat kotak; (0, 0) = sudut kiri atas kotak.
    final out = Float32List(1434)..fillRange(0, 1434, 128);
    final back = mapLandmarks(out, m);
    expect(back.length, 468);
    expect(back[0].$1, closeTo(m.a * 128 + m.b * 128 + m.c, 1e-9));
  });

  test('masker kulit sama dengan Python (pointPolygonTest)', () {
    final mask = FaceMask(pts);
    final grid = g['grid'] as List;
    final want = (g['skin'] as List).cast<bool>();
    var diff = 0;
    for (var i = 0; i < grid.length; i++) {
      final p = grid[i] as List;
      if (mask.isSkin((p[0] as num).toDouble(), (p[1] as num).toDouble()) != want[i]) diff++;
    }
    expect(diff, lessThanOrEqualTo(grid.length ~/ 100)); // hanya titik tepat di tepi poligon
    // Pipi kulit, mata & bibir bukan (wajah fixture menoleh, pipi kanan yang menghadap kamera).
    double mx(List<int> ids) => ids.map((i) => pts[i].$1).reduce((a, b) => a + b) / ids.length;
    double my(List<int> ids) => ids.map((i) => pts[i].$2).reduce((a, b) => a + b) / ids.length;
    expect(mask.isSkin(mx([280, 425]), my([280, 425])), isTrue);
    expect(mask.isSkin(pts[159].$1, pts[159].$2), isFalse); // kelopak mata
    expect(mask.isSkin(pts[13].$1, pts[13].$2), isFalse); // bibir
  });

  test('pemindaian dengan masker: patch tidak mengenai mata/alis/bibir', () {
    final cfg = jsonDecode(File('assets/ml/ml_config.json').readAsStringSync()) as Map<String, dynamic>;
    final scan = (cfg['scan'] as Map).cast<String, dynamic>();
    ViewResult run(bool masked) => processRgb(
      im,
      points: pts,
      faces: 1,
      roiCfg: (cfg['roi'] as Map).cast<String, dynamic>(),
      scanCfg: {...scan, 'feature_mask': masked},
      inputSize: 224,
    );
    final plain = run(false), masked = run(true);
    expect(masked.tiles, isNotEmpty);
    expect(masked.tiles.length, lessThan(plain.tiles.length));
  });
}
