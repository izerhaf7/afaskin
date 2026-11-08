import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:afaskin/ml/landmarks.dart';
import 'package:afaskin/ml/recommender.dart';
import 'package:afaskin/ml/vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:image/image.dart' as img;

/// Hasil pemrosesan satu foto oleh worker.
class ViewOutput {
  ViewOutput({
    required this.pSkin,
    required this.tileProbs,
    required this.tileRegions,
    required this.rois,
    required this.sharpness,
    required this.brightness,
    required this.millis,
    this.points,
  });

  /// Probabilitas tipe kulit (hanya untuk foto depan).
  final List<double>? pSkin;
  final List<List<double>> tileProbs;
  final List<String> tileRegions;
  final List<Map<String, Object>> rois;
  final double sharpness, brightness;

  /// Waktu per tahap (ms): decode, landmark, preprocess, skin, condition.
  final Map<String, int> millis;

  /// Titik wajah yang dipakai (setelah diperhalus model landmark).
  final List<(double, double)>? points;
}

/// Semua model & data ML yang dibundel di `assets/ml/` (lihat `src/export_tflite.py`).
///
/// Inferensi berjalan di isolate terpisah yang memegang dua interpreter TFLite,
/// jadi UI tidak tersendat dan aplikasi tidak butuh server atau internet.
class MlEngine {
  MlEngine._(this.config, this.recommender, this.conditionModel, this._port, this._isolate);

  final Map<String, dynamic> config;
  final Recommender recommender;

  /// Arsitektur model kondisi yang dipakai (MobileNetV2 / ResNet50).
  final String conditionModel;
  final SendPort _port;
  final Isolate _isolate;
  int _nextId = 0;
  final _pending = <int, Completer<Map<Object?, Object?>>>{};
  StreamSubscription<Object?>? _sub;

  Map<String, dynamic> get skinCfg => (config['skin_type'] as Map).cast<String, dynamic>();
  Map<String, dynamic> get condCfg => (config['condition'] as Map).cast<String, dynamic>();
  Map<String, dynamic> get condModelCfg =>
      ((condCfg['models'] as Map)[conditionModel] as Map).cast<String, dynamic>();
  Map<String, dynamic> get scanCfg => (config['scan'] as Map).cast<String, dynamic>();

  static Future<MlEngine> load(AssetBundle bundle, {String? conditionModel}) async {
    final cfg = jsonDecode(await bundle.loadString('assets/ml/ml_config.json')) as Map<String, dynamic>;
    final catalog = (jsonDecode(await bundle.loadString('assets/ml/catalog.json')) as List)
        .map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
        .toList();
    final cond = (cfg['condition'] as Map).cast<String, dynamic>();
    final arch = (conditionModel == null || conditionModel.isEmpty)
        ? cond['default_model'] as String
        : conditionModel;
    final condFile = ((cond['models'] as Map)[arch] as Map)['model'] as String;
    final skinFile = (cfg['skin_type'] as Map)['model'] as String;
    final faceCfg = (cfg['face'] as Map?)?.cast<String, dynamic>() ?? const {};
    final lmFile = faceCfg['landmark_model'] as String?;
    Future<TransferableTypedData> asset(String f) async =>
        TransferableTypedData.fromList([(await bundle.load('assets/ml/$f')).buffer.asUint8List()]);

    final rx = ReceivePort();
    final isolate = await Isolate.spawn(_workerMain, [
      rx.sendPort,
      await asset(skinFile),
      await asset(condFile),
      if (lmFile != null) await asset(lmFile) else null,
      jsonEncode({
        'roi': cfg['roi'],
        'scan': cfg['scan'],
        'face': faceCfg,
        'size': cond['input_size'],
        'threads': (cond['threads'] as int?) ?? 4,
      }),
    ], debugName: 'afaskin-ml');
    final stream = rx.asBroadcastStream();
    final port = await stream.first as SendPort;
    final engine = MlEngine._(
      cfg,
      Recommender(products: catalog, cfg: (cfg['recommender'] as Map).cast<String, dynamic>()),
      arch,
      port,
      isolate,
    );
    engine._sub = stream.listen((msg) {
      final m = msg! as Map<Object?, Object?>;
      engine._pending.remove(m['id'])?.complete(m);
    });
    return engine;
  }

  /// Proses satu foto. [points] = 468 titik Face Mesh (null kalau tidak ada wajah).
  /// Melempar [QualityRejection] kalau foto gagal quality gate.
  Future<ViewOutput> runView({
    required Uint8List jpeg,
    required List<(double, double)>? points,
    required int faces,
    required bool side,
  }) async {
    final id = _nextId++;
    final c = Completer<Map<Object?, Object?>>();
    _pending[id] = c;
    _port.send({
      'id': id,
      'jpeg': TransferableTypedData.fromList([jpeg]),
      'points': points == null ? null : Float64List.fromList([for (final p in points) ...[p.$1, p.$2]]),
      'faces': faces,
      'side': side,
    });
    final r = await c.future;
    if (r['error'] != null) throw StateError(r['error']! as String);
    if (r['reasons'] != null) throw QualityRejection((r['reasons']! as List).cast<String>());
    final n = r['n']! as int;
    final probs = (r['probs']! as TransferableTypedData).materialize().asFloat32List();
    final pts = r['points'] as Float64List?;
    final k = n == 0 ? 0 : probs.length ~/ n;
    return ViewOutput(
      pSkin: (r['skin'] as List?)?.cast<double>(),
      tileProbs: [for (var i = 0; i < n; i++) probs.sublist(i * k, (i + 1) * k).map((e) => e.toDouble()).toList()],
      tileRegions: (r['regions']! as List).cast<String>(),
      rois: [for (final m in r['rois']! as List) (m as Map).cast<String, Object>()],
      sharpness: r['sharp']! as double,
      brightness: r['light']! as double,
      millis: (r['ms']! as Map).cast<String, int>(),
      points: pts == null ? null : [for (var i = 0; i < pts.length; i += 2) (pts[i], pts[i + 1])],
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _isolate.kill();
  }
}

// ---------------------------------------------------------------- worker isolate

Future<void> _workerMain(List<Object?> args) async {
  final main = args[0]! as SendPort;
  final cfg0 = jsonDecode(args[4]! as String) as Map<String, dynamic>;
  final threads = (cfg0['threads'] as int?) ?? 4;
  Interpreter make(TransferableTypedData t) => Interpreter.fromBuffer(
    t.materialize().asUint8List(),
    options: InterpreterOptions()
      ..addDelegate(
        XNNPackDelegate(options: XNNPackDelegateOptions(numThreads: threads)),
      ),
  );
  final skin = make(args[1]! as TransferableTypedData);
  final cond = make(args[2]! as TransferableTypedData);
  final lm = args[3] == null ? null : make(args[3]! as TransferableTypedData);
  final cfg = jsonDecode(args[4]! as String) as Map<String, dynamic>;
  final faceCfg = (cfg['face'] as Map).cast<String, dynamic>();
  final size = cfg['size'] as int;
  final rx = ReceivePort();
  main.send(rx.sendPort);

  await for (final msg in rx) {
    final m = msg as Map<Object?, Object?>;
    final id = m['id'];
    try {
      final sw = Stopwatch()..start();
      final decoded = img.decodeJpg((m['jpeg']! as TransferableTypedData).materialize().asUint8List());
      if (decoded == null) throw StateError('Foto tidak bisa dibaca');
      final rgb = RgbImage.from(decoded);
      final tDecode = sw.elapsedMilliseconds;
      final flat = m['points'] as Float64List?;
      var points = flat == null ? null : [for (var i = 0; i < flat.length; i += 2) (flat[i], flat[i + 1])];
      if (points != null && lm != null) {
        points = _refine(
          lm,
          rgb,
          points,
          iters: (faceCfg['refine_iters'] as int?) ?? 2,
          scale: ((faceCfg['refine_scale'] as num?) ?? 1.5).toDouble(),
        );
      }
      final tLandmark = sw.elapsedMilliseconds;
      final side = m['side']! as bool;
      final ViewResult v;
      try {
        v = processRgb(
          rgb,
          points: points,
          faces: m['faces']! as int,
          roiCfg: (cfg['roi'] as Map).cast<String, dynamic>(),
          scanCfg: (cfg['scan'] as Map).cast<String, dynamic>(),
          inputSize: size,
          side: side,
        );
      } on QualityRejection catch (q) {
        main.send({'id': id, 'reasons': q.reasons});
        continue;
      }
      final tPre = sw.elapsedMilliseconds;
      final pSkin = side ? null : _run(skin, [v.face], size).toList();
      final tSkin = sw.elapsedMilliseconds;
      final probs = _run(cond, v.tiles, size);
      final tCond = sw.elapsedMilliseconds;
      main.send({
        'id': id,
        'skin': pSkin,
        'n': v.tiles.length,
        'probs': TransferableTypedData.fromList([probs]),
        'regions': v.tileRegions,
        'rois': v.rois,
        'points': points == null ? null : Float64List.fromList([for (final p in points) ...[p.$1, p.$2]]),
        'sharp': v.sharpness,
        'light': v.brightness,
        'ms': {
          'decode': tDecode,
          'landmark': tLandmark - tDecode,
          'preprocess': tPre - tLandmark,
          'skin': tSkin - tPre,
          'condition': tCond - tSkin,
          'patches': v.tiles.length,
        },
      });
    } on Object catch (e, st) {
      debugPrint('ML worker error: $e\n$st');
      main.send({'id': id, 'error': '$e'});
    }
  }
}

/// Perhalus titik ML Kit dengan model landmark MediaPipe (lihat `landmarks.dart`).
/// Kalau model ragu ada wajah di crop (skor < 0.5), titik terakhir yang dipakai.
List<(double, double)> _refine(
  Interpreter it,
  RgbImage im,
  List<(double, double)> start, {
  required int iters,
  required double scale,
}) {
  if (!it.isAllocated) it.allocateTensors();
  final outs = it.getOutputTensors();
  final lmIdx = outs.indexWhere((t) => t.shape.last == 1434);
  final scoreIdx = outs.indexWhere((t) => t.shape.length == 4 && t.shape.last == 1);
  var pts = start;
  for (var k = 0; k < iters; k++) {
    final m = landmarkCropTransform(pts, scale: scale);
    it.getInputTensor(0).setTo(warpCrop(im, m));
    it.invoke();
    if (scoreIdx >= 0) {
      final s = Float32List(1);
      it.getOutputTensor(scoreIdx).copyTo(s);
      if (1 / (1 + math.exp(-s[0])) < 0.5) break;
    }
    final y = Float32List(1434);
    it.getOutputTensor(lmIdx).copyTo(y);
    pts = mapLandmarks(y, m);
  }
  return pts;
}

/// Inferensi batch (dipecah per 16 patch supaya memori tetap kecil).
Float32List _run(Interpreter it, List<Float32List> inputs, int size) {
  final per = size * size * 3;
  final outs = <double>[];
  var classes = 0;
  for (var start = 0; start < inputs.length; start += 16) {
    final chunk = inputs.sublist(start, start + 16 > inputs.length ? inputs.length : start + 16);
    if (!it.isAllocated || it.getInputTensor(0).shape.first != chunk.length) {
      it
        ..resizeInputTensor(0, [chunk.length, size, size, 3])
        ..allocateTensors();
    }
    final x = Float32List(chunk.length * per);
    for (var i = 0; i < chunk.length; i++) {
      x.setAll(i * per, chunk[i]);
    }
    it.getInputTensor(0).setTo(x);
    it.invoke();
    final outT = it.getOutputTensor(0);
    classes = outT.shape.last;
    final y = Float32List(chunk.length * classes);
    outT.copyTo(y);
    outs.addAll(y);
  }
  return Float32List.fromList(outs);
}
