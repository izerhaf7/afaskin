import 'dart:convert';
import 'dart:io';

import 'package:afaskin/ml/fusion.dart';
import 'package:afaskin/ml/recommender.dart';
import 'package:flutter_test/flutter_test.dart';

/// Port Dart harus memberi hasil yang sama dengan backend Python lama
/// (`test/fixtures/ml_golden.json` dibuat dari `afaskin_fusion.py` dan
/// `recommender.py` sebelum backend dihapus).
void main() {
  final cfg = jsonDecode(File('assets/ml/ml_config.json').readAsStringSync()) as Map<String, dynamic>;
  final catalog = [
    for (final e in jsonDecode(File('assets/ml/catalog.json').readAsStringSync()) as List)
      CatalogProduct.fromJson(e as Map<String, dynamic>),
  ];
  final cases = jsonDecode(File('test/fixtures/ml_golden.json').readAsStringSync()) as List;
  final skinCfg = (cfg['skin_type'] as Map).cast<String, dynamic>();
  final condCfg = (cfg['condition'] as Map).cast<String, dynamic>();
  // Golden dibuat dengan konfigurasi fusion ResNet50 (model kondisi di backend).
  final condModelCfg = ((condCfg['models'] as Map)['ResNet50'] as Map).cast<String, dynamic>();
  final classes = (condCfg['classes'] as List).cast<String>();
  final reco = Recommender(products: catalog, cfg: (cfg['recommender'] as Map).cast<String, dynamic>());

  for (final (i, raw) in cases.indexed) {
    final c = raw as Map<String, dynamic>;
    final tiles = [
      for (final r in c['tiles'] as List) [for (final v in r as List) (v as num).toDouble()],
    ];

    test('kasus $i: agregasi patch sama dengan Python', () {
      final agg = aggregateTiles(tiles, (c['tile_regions'] as List).cast<String>(), classes);
      final want = (c['aggregated'] as List).cast<num>();
      for (var j = 0; j < want.length; j++) {
        expect(agg.probs[j], closeTo(want[j].toDouble(), 1e-9));
      }
      expect(agg.where, {
        for (final e in (c['where'] as Map).entries) e.key: (e.value as List).cast<String>(),
      });
    });

    final answers = (c['answers'] as Map).map((k, v) => MapEntry(k as String, v as int?));
    final want = SkinProfile.fromJson((c['profile'] as Map).cast<String, dynamic>());
    final prof = predictProfile(
      pSkinCnn: (c['p_skin_cnn'] as List).map((e) => (e as num).toDouble()).toList(),
      pCondCnn: (c['aggregated'] as List).map((e) => (e as num).toDouble()).toList(),
      answers: answers,
      skinCfg: skinCfg,
      condCfg: condCfg,
      condModelCfg: condModelCfg,
    );

    test('kasus $i: fusion sama dengan Python', () {
      for (final k in want.pSkin.keys) {
        expect(prof.pSkin[k], closeTo(want.pSkin[k]!, 1.01e-4));
      }
      for (final k in want.pCond.keys) {
        expect(prof.pCond[k], closeTo(want.pCond[k]!, 1.01e-4));
      }
      expect(prof.sensitive, want.sensitive);
    });

    test('kasus $i: filter keamanan & rekomendasi sama dengan Python', () {
      // Pakai profil Python persis supaya pembulatan fusion tidak memengaruhi urutan.
      expect(reco.avoidSet(want).toList()..sort(), (c['avoid'] as List).cast<String>());
      final got = reco.recommend(want);
      final exp = (c['recommend'] as List).cast<Map<String, dynamic>>();
      expect([for (final g in got) g['id']], [for (final e in exp) e['id']]);
      for (var j = 0; j < exp.length; j++) {
        expect(got[j]['match_score'] as double, closeTo((exp[j]['match_score'] as num).toDouble(), 1.01e-3));
        expect(got[j]['matched_ingredients'], (exp[j]['matched'] as List).cast<String>());
        expect((got[j]['reasons'] as List).length, exp[j]['reasons']);
        expect((got[j]['warnings'] as List).length, exp[j]['warnings']);
      }
      final serum = reco.recommend(want, category: 'serum', maxPrice: 400000);
      expect([for (final g in serum) g['id']], (c['recommend_serum_400k'] as List).cast<String>());
    });
  }

  test('bukti visual: ambang keyakinan 0.5 menghitung patch yang mendukung kelas', () {
    final p = [
      [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3], // Acne yakin
      [0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5], // Acne tepat di ambang
      [0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9], // Clear
      [0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6], // di bawah ambang
    ];
    final ev = visualEvidence(p, classes);
    expect(ev['Acne']!.count, 2);
    expect(ev['Acne']!.frac, closeTo(2 / 4, 1e-9));
    // Clear menang di baris 3 (0,9) dan baris 4 (0,6); baris 2 seri 0,5 dan argmax
    // jatuh ke Acne karena perbandingan memakai ">" (yang pertama menang).
    expect(ev['Clear']!.count, 2);
    expect(ev['Birthmark']!.count, 0);
    // Ambang bisa dinaikkan lewat parameter (dipakai ml_config gate_conf).
    expect(visualEvidence(p, classes, conf: 0.6)['Acne']!.count, 1);
  });

  test('agregasi mean: wajah dengan mayoritas patch bersih tetap bersih', () {
    final p = [
      for (var i = 0; i < 18; i++) [0.02, 0.01, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.96],
      [0.0, 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1], // satu patch rambut -> "Birthmark"
      [0.0, 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1],
    ];
    final regions = List.filled(p.length, 'forehead');
    final mean = aggregateTiles(p, regions, classes, mode: 'mean').probs;
    final top = aggregateTiles(p, regions, classes).probs;
    expect(mean.last, greaterThan(0.8));          // Clear dominan
    expect(top[1], greaterThan(mean[1] * 3));      // top-k membesar-besarkan 2 patch
  });

  test('fusion: kuesioner tipe kulit sesuai rumus notebook 05', () {
    final p = questionnaireSkin({'Q1': 5, 'Q4': 5, 'Q5': 1}, skinCfg);
    expect(p.reduce((a, b) => a + b), closeTo(1, 1e-9));
    expect(p.last, greaterThan(0.9)); // oily
  });
}
