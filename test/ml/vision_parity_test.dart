import 'dart:convert';
import 'dart:io';

import 'package:afaskin/ml/vision.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// `processView` (Dart) vs `vision.py` (Python, dipakai saat pengembangan) pada
/// foto dataset yang sama dengan titik wajah yang sama: ROI, jumlah & isi patch,
/// dan quality gate harus cocok. Foto dari dataset publik, bukan foto pengguna.
void main() {
  test('pemrosesan foto sama dengan pipeline Python', () {
    final cfg = jsonDecode(File('assets/ml/ml_config.json').readAsStringSync()) as Map<String, dynamic>;
    final g = jsonDecode(File('test/fixtures/vision_golden.json').readAsStringSync()) as Map<String, dynamic>;
    final im = img.decodeJpg(File('test/fixtures/vision_face.jpg').readAsBytesSync())!;
    final pts = [
      for (final p in g['points'] as List)
        (((p as List)[0] as num).toDouble(), (p[1] as num).toDouble()),
    ];

    // Parameter pemindaian versi Python lama (patch 15% lebar wajah, kulit >= 40%).
    // `hair_l_rel: 0` karena vision.py tidak punya filter rambut; uji ini mengukur
    // kesamaan ROI/patch dengan implementasi Python, bukan perilaku filter baru.
    final scan = {...(cfg['scan'] as Map).cast<String, dynamic>(), 'tile_rel': 0.15, 'skin_min': 0.4, 'feature_mask': false, 'glare_max': 1.0, 'hair_l_rel': 0};
    final v = processView(
      im,
      points: pts,
      faces: 1,
      roiCfg: (cfg['roi'] as Map).cast<String, dynamic>(),
      scanCfg: scan,
      inputSize: 224,
    );

    final want = (g['rois'] as List).cast<Map<String, dynamic>>();
    expect([for (final r in v.rois) r['name']], [for (final r in want) r['name']]);
    for (var i = 0; i < want.length; i++) {
      final a = v.rois[i]['bbox']! as List<double>;
      final b = (want[i]['bbox'] as List).cast<num>();
      for (var k = 0; k < 4; k++) {
        expect(a[k], closeTo(b[k].toDouble(), 0.002));
      }
    }
    // Jumlah patch boleh beda tipis (statistik kulit Dart memakai sampling).
    final wantTiles = (g['tile_means'] as List).length;
    expect(v.tiles.length, inInclusiveRange(wantTiles - 3, wantTiles + 3));
    expect(v.sharpness, closeTo((g['sharpness'] as num).toDouble(), (g['sharpness'] as num) * 0.15));
    expect(v.brightness, closeTo((g['brightness'] as num).toDouble(), 3));

    // Isi crop wajah: rata-rata RGB sama (resize area vs PIL antialias).
    final fm = (g['face_mean'] as List).cast<num>();
    final face = v.face;
    for (var c = 0; c < 3; c++) {
      var s = 0.0;
      for (var i = c; i < face.length; i += 3) {
        s += face[i];
      }
      expect(s / (face.length / 3), closeTo(fm[c].toDouble(), 2.5));
    }
  });
}
