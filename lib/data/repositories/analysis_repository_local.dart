import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:afaskin/core/config/env.dart';
import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/ml/face_mesh.dart';
import 'package:afaskin/ml/fusion.dart';
import 'package:afaskin/ml/ml_engine.dart';
import 'package:afaskin/ml/ml_texts.dart';
import 'package:afaskin/ml/profile_store.dart';
import 'package:afaskin/ml/vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Semua analisis berjalan di HP: ML Kit Face Mesh -> quality gate & ROI ->
/// CNN tipe kulit + CNN kondisi kulit (TFLite) -> late fusion dengan kuesioner
/// -> rekomendasi dari katalog bawaan. Tidak ada server dan tidak butuh internet.
class AnalysisRepositoryLocal implements AnalysisRepository {
  AnalysisRepositoryLocal({
    required Future<MlEngine> engine,
    required this.profiles,
    required AssetBundle bundle,
    FaceMeshService? faceMesh,
  }) : _engine = engine,
       _bundle = bundle,
       _faceMesh = faceMesh ?? FaceMeshService();

  final Future<MlEngine> _engine;
  final ProfileStore profiles;
  final AssetBundle _bundle;
  final FaceMeshService _faceMesh;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Failure {
      rethrow;
    } on Object catch (e, st) {
      debugPrint('Local analysis error: $e\n$st');
      // Sebutkan sebabnya: "coba lagi" saja tidak memberi tahu apa yang salah.
      throw ServerFailure(
        message: '${AppStrings.errorLocalAnalysis} ${localFailureCause(e)}',
      );
    }
  }


  @override
  Future<HealthStatus> health() => _guard(() async {
    final e = await _engine;
    return HealthStatus(
      status: 'ok',
      modelVersion: '${e.config['version']} | tipe kulit ${e.skinCfg['arch']} | kondisi ${e.conditionModel} | offline',
    );
  });

  @override
  Future<Questionnaire> getQuestionnaire() async => Questionnaire.fromJson(
    jsonDecode(await _bundle.loadString('assets/mock/questionnaire.json')) as Map<String, dynamic>,
  );

  @override
  Future<AnalysisResult> analyze({
    required Uint8List imageJpeg,
    required AnalyzePayload payload,
    List<Uint8List> sideImagesJpeg = const [],
    void Function(AnalysisStage stage)? onStage,
  }) => _guard(() async {
    final e = await _engine;
    onStage?.call(AnalysisStage.quality);
    final sw = Stopwatch()..start();

    final debug = <String, Object?>{};
    // Foto depan: wajib lolos quality gate.
    final ViewOutput front;
    try {
      final mesh = await _faceMesh.detect(imageJpeg);
      debug['front'] = {'faces': mesh.faces, 'points_mlkit': _pts(mesh.points)};
      front = await e.runView(jpeg: imageJpeg, points: mesh.points, faces: mesh.faces, side: false);
      (debug['front']! as Map)['points'] = _pts(front.points);
    } on QualityRejection catch (q) {
      throw QualityRejected(
        reasons: q.reasons,
        serverMessage: '${q.reasons.map((r) => MlTexts.qualityMessage[r] ?? r).join('. ')}.',
      );
    }
    onStage?.call(AnalysisStage.regions);
    final views = <String, String>{'front': 'ok'};
    final tiles = [...front.tileProbs];
    final regions = [...front.tileRegions];
    final rects = [...front.tileRects];
    final tileView = [for (var i = 0; i < front.tileProbs.length; i++) 0];
    final timing = <String, Map<String, int>>{'front': front.millis};
    // Foto samping disimpan bersama ROI-nya supaya sorotan area bisa memotong
    // dari foto samping, bukan hanya foto depan.
    final sideViews = <Map<String, Object>>[];

    // Foto samping (opsional): gagal quality gate -> diabaikan saja.
    for (final (i, side) in sideImagesJpeg.take(2).indexed) {
      final name = 'side_${i + 1}';
      try {
        final mesh = await _faceMesh.detect(side);
        debug[name] = {'faces': mesh.faces, 'points_mlkit': _pts(mesh.points)};
        final v = await e.runView(jpeg: side, points: mesh.points, faces: mesh.faces, side: true);
        (debug[name]! as Map)['points'] = _pts(v.points);
        (debug[name]! as Map)['tiles'] = v.tileProbs;
        (debug[name]! as Map)['regions'] = v.tileRegions;
        tiles.addAll(v.tileProbs);
        regions.addAll(v.tileRegions);
        rects.addAll(v.tileRects);
        tileView.addAll([for (var i = 0; i < v.tileProbs.length; i++) sideViews.length + 1]);
        sideViews.add({'jpeg': side, 'rois': v.rois});
        views[name] = 'ok';
        timing[name] = v.millis;
      } on QualityRejection catch (q) {
        views[name] = 'ignored: ${q.reasons.join(',')}';
      }
    }

    onStage?.call(AnalysisStage.condition);
    final condClasses = (e.condCfg['classes'] as List).cast<String>();
    final scan = e.scanCfg;
    final agg = aggregateTiles(
      tiles,
      regions,
      condClasses,
      topK: scan['top_k'] as int,
      mode: (scan['aggregation'] as String?) ?? 'top_k',
    );
    final gateConf = ((scan['gate_conf'] as num?) ?? 0.6).toDouble();
    final evidence = visualEvidence(tiles, condClasses, conf: gateConf);
    final q = payload.questionnaire;
    final answers = <String, int?>{for (var i = 1; i <= 7; i++) 'Q$i': q['q$i']};
    answers['Q1'] ??= 3;
    answers['Q3'] ??= 1;
    final prof = predictProfile(
      pSkinCnn: front.pSkin!,
      pCondCnn: agg.probs,
      answers: answers,
      skinCfg: e.skinCfg,
      condCfg: e.condCfg,
      condModelCfg: e.condModelCfg,
    );

    final skin = prof.pSkin.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    final minP = (scan['min_condition_p'] as num).toDouble();
    // Tampil hanya kalau (1) probabilitas akhir cukup dan (2) model citra
    // sendiri melihat kondisi itu di cukup banyak patch. Pengecualian: kelas yang
    // Model v2 sudah bisa melihat bekas jerawat dari foto (AUC 0,926 pada 158
    // gambar berlabel), jadi jalur `questionnaire_only` untuk Scars dihapus:
    // setiap kondisi kini wajib punya bukti visual dari model.
    // Bukti visual: rata-rata k patch terkuat untuk kelas ini.
    //
    // Ambang "jumlah patch di atas X" yang lama membuang lesi selfie: lesi di
    // selfie hanya terlihat di 4-5 patch dari 26, dan patch-patch itu pun
    // keyakinannya rendah karena lesinya kecil. Diukur pada 947 wajah uji:
    // aturan lama (min 3 patch >= 0,35) menemukan kondisi pada 57,9% wajah
    // berlesi; rata-rata top-4 dengan ambang 0,38 menemukan 79,1%, dan wajah
    // bersih yang tetap kosong hanya turun 95,0% -> 88,4%.
    final topK = (scan['gate_top_k'] as int?) ?? 4;
    final topA = ((scan['gate_top_conf'] as num?) ?? 0.38).toDouble();
    bool visualOk(String cls) {
      final ci = condClasses.indexOf(cls);
      return ci >= 0 && topKMean(tiles, ci, topK) >= topA;
    }

    final conds = [
      for (final c in prof.pCond.entries)
        if (c.key != 'Clear' && c.value >= minP && visualOk(c.key)) c,
    ];
    mergeSortDesc(conds, (c) => c.value);

    // Lokasi lesi: patch yang probabilitasnya untuk kondisi ini melampaui
    // ambang bukti visual. Kotak yang saling menumpuk digabung supaya lesi
    // tidak tampil sebagai tumpukan kotak yang warnanya jadi tidak jelas.
    final spotsByCond = <String, List<Map<String, Object>>>{};
    for (var i = 0; i < tiles.length && i < rects.length; i++) {
      final probs = tiles[i];
      for (final c in conds) {
        final ci = condClasses.indexOf(c.key);
        if (ci < 0 || ci >= probs.length || probs[ci] < gateConf) continue;
        final r = rects[i];
        (spotsByCond[c.key] ??= []).add({
          'x': r[0] + r[2] / 2,
          'y': r[1] + r[3] / 2,
          'size': r[2],
          // Nama enum di JSON berhuruf kecil ('acne'), sedangkan c.key
          // berhuruf besar ('Acne'). Tanpa toLowerCase, spot dibaca kembali
          // sebagai `unknown` sehingga warnanya jatuh ke warna cadangan.
          'label': c.key.toLowerCase(),
          'region': regions[i],
          'view': tileView[i],
        });
      }
    }
    // Patch bertumpuk (stride separuh patch) menghasilkan kotak yang saling
    // menimpa; gabungkan yang pusatnya lebih dekat dari 0,6 sisi patch.
    for (final entry in spotsByCond.entries) {
      spotsByCond[entry.key] = gabungBertumpuk(entry.value);
    }
    final createdAt = DateTime.now();
    final id = _uuid();
    await profiles.save(id, prof, createdAt);
    debugPrint(
      'AFASkin analisis lokal: ${sw.elapsedMilliseconds} ms, '
      'model kondisi ${e.conditionModel}, ${tiles.length} patch, views=$views, waktu=$timing',
    );
    debugPrint(
      'AFASkin CNN: skin=${front.pSkin} | kondisi (agregat)=${agg.probs.map((v) => v.toStringAsFixed(3)).toList()} '
      '| bukti visual=${{for (final e in evidence.entries) if (e.value.count > 0) e.key: e.value.count}} '
      '| fusion=${prof.toJson()} | tampil=${conds.map((c) => c.key).toList()}',
    );
    if (Env.mlDebug) {
      (debug['front']! as Map)
        ..['tiles'] = front.tileProbs
        ..['regions'] = front.tileRegions
        ..['rois'] = front.rois
        ..['p_skin_cnn'] = front.pSkin;
      debug
        ..['aggregated'] = agg.probs
        ..['answers'] = answers
        ..['profile'] = prof.toJson()
        ..['condition_model'] = e.conditionModel;
      await _writeDebug(id, imageJpeg, sideImagesJpeg, debug);
    }

    return AnalysisResult.fromJson({
      'analysis_id': id,
      'created_at': createdAt.toIso8601String(),
      'quality': {'passed': true, 'sharpness': front.sharpness, 'brightness': front.brightness},
      'skin_type': {'label': skin, 'confidence': prof.pSkin[skin], 'probs': prof.pSkin},
      'conditions': [
        for (final c in conds.take(e.scanCfg['max_conditions'] as int))
          {
            'label': c.key.toLowerCase(),
            'probability': c.value,
            'regions': agg.where[c.key],
            'spots': spotsByCond[c.key] ?? const <Map<String, Object>>[],
            'description': MlTexts.condition[c.key.toLowerCase()]?.$2,
          },
      ],
      'rois': front.rois,
      'fusion': {'alpha': e.condModelCfg['alpha']},
      'disclaimer': MlTexts.disclaimer,
    });
  });

  SkinProfile _profile(String analysisId) {
    final p = profiles.read(analysisId);
    if (p == null) throw const ServerFailure(statusCode: 404, message: 'Analisis tidak ditemukan.');
    return p;
  }

  @override
  Future<List<Product>> getRecommendations({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  }) => _guard(() async {
    final e = await _engine;
    final items = e.recommender.recommend(
      _profile(analysisId),
      category: category == null || category == ProductCategory.unknown ? null : category.name,
      maxPrice: maxPrice,
    );
    return [for (final m in items) Product.fromJson(m)];
  });

  @override
  Future<Product> getProduct(String id) => _guard(() async {
    final e = await _engine;
    final x = e.recommender.byId[id];
    if (x == null) throw const ServerFailure(statusCode: 404, message: 'Produk tidak ditemukan.');
    // Alasan & peringatan mengikuti analisis terbaru.
    final p = profiles.latest() ??
        const SkinProfile(pSkin: {'normal': 1}, pCond: {'Clear': 1}, sensitive: false);
    return Product.fromJson(e.recommender.item(x, e.recommender.scoreOf(id, p), p, detail: true));
  });
}

/// ML_DEBUG saja: simpan bahan diagnosis ke folder aplikasi (bisa ditarik lewat adb).
Future<void> _writeDebug(String id, Uint8List front, List<Uint8List> sides, Map<String, Object?> data) async {
  try {
    final base = await getExternalStorageDirectory();
    if (base == null) return;
    final dir = Directory('${base.path}/ml_debug/$id')..createSync(recursive: true);
    File('${dir.path}/front.jpg').writeAsBytesSync(front);
    for (final (i, s) in sides.indexed) {
      File('${dir.path}/side_${i + 1}.jpg').writeAsBytesSync(s);
    }
    File('${dir.path}/debug.json').writeAsStringSync(jsonEncode(data));
    debugPrint('AFASkin ML_DEBUG: ${dir.path}');
  } on Object catch (e) {
    debugPrint('AFASkin ML_DEBUG gagal: $e');
  }
}

List<List<double>>? _pts(List<(double, double)>? p) => p?.map((q) => [q.$1, q.$2]).toList();

String _uuid() {
  final r = math.Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// Gabungkan kotak lesi yang pusatnya berdekatan menjadi satu kotak yang
/// menutupi keduanya.
///
/// Patch dipotong dengan stride separuh sisi patch, jadi satu lesi biasanya
/// menghasilkan beberapa patch yang lolos ambang. Tanpa penggabungan, peta
/// wajah menampilkan tumpukan kotak yang saling menimpa: garisnya menebal dan
/// warna kondisi sulit dibedakan.
List<Map<String, Object>> gabungBertumpuk(List<Map<String, Object>> spots) {
  if (spots.length < 2) return spots;
  final sisa = List<Map<String, Object>>.from(spots);
  final hasil = <Map<String, Object>>[];

  while (sisa.isNotEmpty) {
    final awal = sisa.removeAt(0);
    var x1 = awal['x']! as double;
    var y1 = awal['y']! as double;
    var x2 = x1;
    var y2 = y1;
    var size = awal['size']! as double;

    // Ulangi sampai tidak ada kotak lain yang menyentuh kotak yang sedang
    // membesar, supaya rangkaian kotak berderet ikut menyatu.
    var berubah = true;
    while (berubah) {
      berubah = false;
      for (var j = sisa.length - 1; j >= 0; j--) {
        final px = sisa[j]['x']! as double;
        final py = sisa[j]['y']! as double;
        // Kotak digambar selebar `size`, jadi dua kotak baru tampak
        // terpisah kalau jarak pusatnya minimal satu sisi kotak.
        final batas = size * 0.95;
        final dx = px < x1 ? x1 - px : (px > x2 ? px - x2 : 0.0);
        final dy = py < y1 ? y1 - py : (py > y2 ? py - y2 : 0.0);
        if (dx >= batas || dy >= batas) continue;
        x1 = math.min(x1, px);
        y1 = math.min(y1, py);
        x2 = math.max(x2, px);
        y2 = math.max(y2, py);
        size = math.max(size, sisa[j]['size']! as double);
        sisa.removeAt(j);
        berubah = true;
      }
    }

    hasil.add({
      'x': (x1 + x2) / 2,
      'y': (y1 + y2) / 2,
      'size': size,
      'label': awal['label']!,
      'region': awal['region']!,
      'view': awal['view']!,
    });
  }
  return hasil;
}

/// Sebab kegagalan analisis lokal dalam bahasa yang bisa dibaca pengguna.
///
/// Dipisah dari kelas supaya bisa diuji tanpa menjalankan model: pengguna perlu
/// tahu kenapa analisisnya gagal, bukan hanya "coba lagi".
String localFailureCause(Object error) => switch (error) {
  StateError(:final message) when message.contains('no_face') =>
    'wajah tidak terdeteksi di foto.',
  StateError(:final message) => 'model menolak foto ($message).',
  PhotoDecodeException() => 'foto tidak bisa dibaca.',
  _ => 'terjadi kesalahan saat menjalankan model (${error.runtimeType}).',
};
