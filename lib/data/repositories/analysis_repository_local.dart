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
    final timing = <String, Map<String, int>>{'front': front.millis};

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
    final evidence = visualEvidence(tiles, condClasses, conf: ((scan['gate_conf'] as num?) ?? 0.6).toDouble());
    final gateFrac = ((scan['gate_frac'] as num?) ?? 0).toDouble();
    final gateMin = (scan['gate_min_patches'] as int?) ?? 0;
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
    bool visualOk(String cls) =>
        evidence[cls]!.count >= gateMin && evidence[cls]!.frac >= gateFrac;

    final conds = [
      for (final c in prof.pCond.entries)
        if (c.key != 'Clear' && c.value >= minP && visualOk(c.key)) c,
    ];
    mergeSortDesc(conds, (c) => c.value);
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
