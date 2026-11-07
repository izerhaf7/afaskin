import 'dart:math' as math;
import 'dart:typed_data';

import 'package:afaskin/ml/landmarks.dart';
import 'package:image/image.dart' as img;

/// Port `vision.py`: quality gate, ROI kulit, dan patch untuk model kondisi,
/// dihitung dari 468 titik Face Mesh (topologi sama dengan MediaPipe, sehingga
/// indeks landmark dari notebook 03 bisa dipakai apa adanya).
///
/// Murni (tanpa plugin), jadi bisa dijalankan di isolate latar belakang.
/// Semua operasi piksel bekerja langsung pada buffer RGB (jauh lebih cepat
/// daripada objek piksel paket `image`).

class QualityRejection implements Exception {
  const QualityRejection(this.reasons);
  final List<String> reasons;
  @override
  String toString() => 'QualityRejection($reasons)';
}

/// Hasil satu foto: crop wajah & patch dalam bentuk tensor float32 NHWC 0-255.
class ViewResult {
  ViewResult({
    required this.face,
    required this.rois,
    required this.tiles,
    required this.tileRegions,
    required this.sharpness,
    required this.brightness,
  });

  final Float32List face;
  final List<Map<String, Object>> rois;
  final List<Float32List> tiles;
  final List<String> tileRegions;
  final double sharpness;
  final double brightness;
}

/// Gambar RGB 8-bit dalam satu buffer (baris demi baris).
class RgbImage {
  RgbImage(this.px, this.w, this.h);

  factory RgbImage.from(img.Image im) =>
      RgbImage(im.convert(numChannels: 3).getBytes(order: img.ChannelOrder.rgb), im.width, im.height);

  final Uint8List px;
  final int w;
  final int h;

  double gray(int x, int y) {
    final i = (y * w + x) * 3;
    return (px[i] * 299 + px[i + 1] * 587 + px[i + 2] * 114) / 1000;
  }
}

const _apiRegion = {'forehead': 'forehead', 'nose': 'nose', 'chin': 'chin'};

/// Kotak persegi berpusat (cx, cy), digeser agar tetap di dalam gambar.
(int, int, int) cropBox(int w, int h, double cx, double cy, double side) {
  final s = math.min(math.max(side, 8), math.min(w, h).toDouble()).floor();
  final x0 = math.min(math.max(cx - s / 2, 0), (w - s).toDouble()).floor();
  final y0 = math.min(math.max(cy - s / 2, 0), (h - s).toDouble()).floor();
  return (x0, y0, s);
}

double _cubic(double x) {
  // Kernel bikubik a = -0.5 (sama dengan PIL BICUBIC).
  final ax = x.abs();
  if (ax <= 1) return (1.5 * ax - 2.5) * ax * ax + 1;
  if (ax < 2) return ((-0.5 * ax + 2.5) * ax - 4) * ax + 2;
  return 0;
}

/// Potong kotak persegi (x0, y0, s) lalu ubah ke size x size.
/// Membesarkan: bikubik. Mengecilkan: rata-rata area (seperti PIL dengan
/// antialiasing). Hasil: float32 RGB 0-255 (atau abu-abu kalau [gray]).
Float32List sampleSquare(RgbImage im, int x0, int y0, int s, int size, {bool gray = false}) {
  final ch = gray ? 1 : 3;
  final out = Float32List(size * size * ch);
  final scale = s / size;
  var o = 0;
  if (scale > 1) {
    for (var y = 0; y < size; y++) {
      final sy0 = y0 + (y * scale).floor();
      final sy1 = math.max(sy0 + 1, y0 + ((y + 1) * scale).floor());
      for (var x = 0; x < size; x++) {
        final sx0 = x0 + (x * scale).floor();
        final sx1 = math.max(sx0 + 1, x0 + ((x + 1) * scale).floor());
        var r = 0.0, g = 0.0, b = 0.0;
        var n = 0;
        for (var yy = sy0; yy < sy1; yy++) {
          var i = (yy * im.w + sx0) * 3;
          for (var xx = sx0; xx < sx1; xx++) {
            r += im.px[i];
            g += im.px[i + 1];
            b += im.px[i + 2];
            i += 3;
            n++;
          }
        }
        if (gray) {
          out[o++] = (r * 299 + g * 587 + b * 114) / 1000 / n;
        } else {
          out[o++] = r / n;
          out[o++] = g / n;
          out[o++] = b / n;
        }
      }
    }
    return out;
  }
  // Bikubik: koordinat pusat piksel seperti PIL.
  final wx = List<List<double>>.generate(size, (_) => List<double>.filled(4, 0));
  final ix = List<int>.filled(size, 0);
  for (var x = 0; x < size; x++) {
    final c = (x + 0.5) * scale - 0.5;
    final f = c.floor();
    ix[x] = f;
    var sum = 0.0;
    for (var k = 0; k < 4; k++) {
      wx[x][k] = _cubic(c - (f - 1 + k));
      sum += wx[x][k];
    }
    for (var k = 0; k < 4; k++) {
      wx[x][k] /= sum;
    }
  }
  int clampX(int v) => x0 + v.clamp(0, s - 1);
  int clampY(int v) => y0 + v.clamp(0, s - 1);
  for (var y = 0; y < size; y++) {
    final c = (y + 0.5) * scale - 0.5;
    final fy = c.floor();
    final wy = [for (var k = 0; k < 4; k++) _cubic(c - (fy - 1 + k))];
    final wys = wy.reduce((a, b) => a + b);
    for (var x = 0; x < size; x++) {
      var r = 0.0, g = 0.0, b = 0.0;
      for (var ky = 0; ky < 4; ky++) {
        final row = clampY(fy - 1 + ky) * im.w;
        final wyk = wy[ky] / wys;
        for (var kx = 0; kx < 4; kx++) {
          final i = (row + clampX(ix[x] - 1 + kx)) * 3;
          final w = wyk * wx[x][kx];
          r += w * im.px[i];
          g += w * im.px[i + 1];
          b += w * im.px[i + 2];
        }
      }
      if (gray) {
        out[o++] = ((r * 299 + g * 587 + b * 114) / 1000).clamp(0, 255);
      } else {
        out[o++] = r.clamp(0, 255);
        out[o++] = g.clamp(0, 255);
        out[o++] = b.clamp(0, 255);
      }
    }
  }
  return out;
}

/// Variance of Laplacian pada versi abu-abu 256x256 (quality gate ketajaman).
double lapVar(RgbImage im, int x0, int y0, int s) {
  final a = sampleSquare(im, x0, y0, s, 256, gray: true);
  var sum = 0.0, sq = 0.0;
  var n = 0;
  for (var y = 1; y < 255; y++) {
    for (var x = 1; x < 255; x++) {
      final i = y * 256 + x;
      final l = a[i - 256] + a[i + 256] + a[i - 1] + a[i + 1] - 4 * a[i];
      sum += l;
      sq += l * l;
      n++;
    }
  }
  final mean = sum / n;
  return sq / n - mean * mean;
}

double meanGray(RgbImage im, int x0, int y0, int s, {int step = 2}) {
  var t = 0.0;
  var n = 0;
  for (var y = y0; y < y0 + s; y += step) {
    for (var x = x0; x < x0 + s; x += step) {
      t += im.gray(x, y);
      n++;
    }
  }
  return t / n;
}

/// Rata-rata semua kanal RGB seluruh foto (pengganti `arr.mean()` di Python).
double meanRgb(RgbImage im, {int step = 4}) {
  var t = 0.0;
  var n = 0;
  for (var y = 0; y < im.h; y += step) {
    for (var x = 0; x < im.w; x += step) {
      final i = (y * im.w + x) * 3;
      t += im.px[i] + im.px[i + 1] + im.px[i + 2];
      n += 3;
    }
  }
  return t / n;
}

/// Proporsi piksel kulit (YCbCr), piksel hampir hitam, dan piksel kilap
/// (min RGB > [glareLevel]) di sebuah kotak.
(double skin, double dark, double glare) skinStats(RgbImage im, int x0, int y0, int s, {int glareLevel = 215}) {
  final step = math.max(1, s ~/ 48);
  var dark = 0, skin = 0, glare = 0, n = 0;
  for (var y = y0; y < y0 + s; y += step) {
    var i = (y * im.w + x0) * 3;
    for (var x = x0; x < x0 + s; x += step) {
      final r = im.px[i].toDouble(), g = im.px[i + 1].toDouble(), b = im.px[i + 2].toDouble();
      if (math.max(r, math.max(g, b)) < 12) dark++;
      if (math.min(r, math.min(g, b)) > glareLevel) glare++;
      final cb = 128 - 0.168736 * r - 0.331264 * g + 0.5 * b;
      final cr = 128 + 0.5 * r - 0.418688 * g - 0.081312 * b;
      if (cr >= 133 && cr <= 173 && cb >= 77 && cb <= 127) skin++;
      n++;
      i += 3 * step;
    }
  }
  return (skin / n, dark / n, glare / n);
}

/// Seluruh pemrosesan satu foto. [points]: 468 titik (x, y) piksel, atau null
/// kalau detektor tidak menemukan wajah. [faces]: jumlah wajah terdeteksi.
ViewResult processView(
  img.Image decoded, {
  required List<(double, double)>? points,
  required int faces,
  required Map<String, dynamic> roiCfg,
  required Map<String, dynamic> scanCfg,
  required int inputSize,
  bool side = false,
}) => processRgb(
  RgbImage.from(decoded),
  points: points,
  faces: faces,
  roiCfg: roiCfg,
  scanCfg: scanCfg,
  inputSize: inputSize,
  side: side,
);

/// Sama dengan [processView], untuk gambar yang sudah berupa [RgbImage].
ViewResult processRgb(
  RgbImage im, {
  required List<(double, double)>? points,
  required int faces,
  required Map<String, dynamic> roiCfg,
  required Map<String, dynamic> scanCfg,
  required int inputSize,
  bool side = false,
}) {
  final w = im.w, h = im.h;
  final br = (roiCfg['brightness_range'] as List).map((e) => (e as num).toDouble()).toList();
  final dark = br[0], bright = br[1];
  if (points == null || faces == 0) {
    final g = meanRgb(im);
    throw QualityRejection(['no_face', if (g < dark) 'too_dark' else if (g > bright) 'too_bright']);
  }
  if (faces > 1) throw const QualityRejection(['multiple_faces']);

  (double, double) pt(int i) => points[i];
  (double, double) mean(List<int> ids) {
    var x = 0.0, y = 0.0;
    for (final i in ids) {
      x += pt(i).$1;
      y += pt(i).$2;
    }
    return (x / ids.length, y / ids.length);
  }

  final fwIdx = (roiCfg['face_width_landmarks'] as List).cast<int>();
  final a = pt(fwIdx[0]), b = pt(fwIdx[1]);
  final fw = math.sqrt(math.pow(a.$1 - b.$1, 2) + math.pow(a.$2 - b.$2, 2));
  var x0 = double.infinity, y0 = double.infinity, x1 = -double.infinity, y1 = -double.infinity;
  for (final p in points) {
    x0 = math.min(x0, p.$1);
    y0 = math.min(y0, p.$2);
    x1 = math.max(x1, p.$1);
    y1 = math.max(y1, p.$2);
  }
  final (fx, fy, fs) = cropBox(w, h, (x0 + x1) / 2, (y0 + y1) / 2, math.max(x1 - x0, y1 - y0) * 1.15);
  final sharp = lapVar(im, fx, fy, fs);
  final light = meanGray(im, fx, fy, fs);

  final reasons = <String>[
    if (fw < (roiCfg['min_face_px'] as num)) 'face_too_small',
    if (sharp < (roiCfg['blur_min'] as num)) 'blurry',
    if (light < dark) 'too_dark',
    if (light > bright) 'too_bright',
  ];
  if (reasons.isNotEmpty) throw QualityRejection(reasons);

  final roiDef = (roiCfg['roi'] as Map).cast<String, dynamic>();
  final centers = {
    for (final e in roiDef.entries)
      e.key: mean(((e.value as Map)['landmarks'] as List).cast<int>()),
  };
  final cheeks = ['cheek_left', 'cheek_right']..sort((p, q) => centers[p]!.$1.compareTo(centers[q]!.$1));
  final names = {..._apiRegion, cheeks[0]: 'left_cheek', cheeks[1]: 'right_cheek'};
  String? skip;
  if (side) {
    // Sisi yang menghadap kamera: jarak hidung ke tepi wajah yang lebih panjang.
    final nose = pt(1);
    final nearEdge = (nose.$1 - a.$1).abs() > (nose.$1 - b.$1).abs() ? a : b;
    final near = ['cheek_left', 'cheek_right'].reduce(
      (p, q) => (centers[p]!.$1 - nearEdge.$1).abs() <= (centers[q]!.$1 - nearEdge.$1).abs() ? p : q,
    );
    skip = near == 'cheek_left' ? 'cheek_right' : 'cheek_left';
  }

  final areaRel = (scanCfg['area_rel'] as Map).cast<String, num>();
  final tileRel = (scanCfg['tile_rel'] as num).toDouble();
  final stride = (scanCfg['stride'] as num).toDouble();
  final skinMin = ((scanCfg['skin_min'] as num?) ?? 0.4).toDouble();
  final mask = (scanCfg['feature_mask'] as bool? ?? false) ? FaceMask(points) : null;
  final glareLevel = (scanCfg['glare_level'] as num?)?.toInt() ?? 215;
  final glareMax = ((scanCfg['glare_max'] as num?) ?? 1.0).toDouble();
  // Patch yang jauh lebih gelap dari median wajah = rambut/bayangan, bukan kulit.
  // Rambut di dahi lolos uji warna kulit (YCbCr) tapi selalu dibaca model sebagai
  // "Clear", sehingga menenggelamkan lesi asli. 0 = filter mati.
  final hairRel = ((scanCfg['hair_l_rel'] as num?) ?? 0).toDouble();
  final rois = <Map<String, Object>>[];
  final candidates = <({int x, int y, int s, String region})>[];
  var valid = 0;
  for (final e in roiDef.entries) {
    if (e.key == skip) continue;
    final region = names[e.key]!;
    final (cx, cy) = centers[e.key]!;
    final rel = ((e.value as Map)['size_rel_face_width'] as num).toDouble();
    final (bx, by, bs) = cropBox(w, h, cx, cy, rel * fw);
    rois.add({
      'name': region,
      'bbox': [bx / w, by / h, bs / w, bs / h].map((v) => (v * 10000).roundToDouble() / 10000).toList(),
    });
    final (rs, rd, _) = skinStats(im, bx, by, bs);
    if (rd < 0.1 && rs >= 0.4) valid++;
    // Sliding window di area ini (model kondisi dilatih dengan patch satu lesi).
    final area = areaRel[region]!.toDouble() * fw, t = tileRel * fw;
    final n = math.max(1, ((area - t) / (t * stride)).truncate() + 1);
    for (var iy = 0; iy < n; iy++) {
      for (var ix = 0; ix < n; ix++) {
        final dy = (iy - (n - 1) / 2) * t * stride, dx = (ix - (n - 1) / 2) * t * stride;
        final (tx, ty, ts) = cropBox(w, h, cx + dx, cy + dy, t);
        if (mask != null && !mask.boxIsSkin(tx, ty, ts)) continue;
        final (ps, pd, pg) = skinStats(im, tx, ty, ts, glareLevel: glareLevel);
        // Buang patch berisi rambut/alis/mata/bibir (bukan kulit), area hitam, dan kilap minyak.
        if (pd < 0.1 && ps >= skinMin && pg <= glareMax) {
          candidates.add((x: tx, y: ty, s: ts, region: region));
        }
      }
    }
  }
  // Median kecerahan seluruh kandidat patch, lalu buang yang jauh lebih gelap (rambut).
  var kept = candidates;
  if (hairRel > 0 && candidates.length > 4) {
    final lum = [
      for (final c in candidates)
        meanGray(im, c.x, c.y, c.s),
    ]..sort();
    final med = lum[lum.length ~/ 2];
    final thr = med * hairRel;
    kept = [for (var i = 0; i < candidates.length; i++) if (lum[i] >= thr) candidates[i]];
  }
  final tiles = [for (final c in kept) sampleSquare(im, c.x, c.y, c.s, inputSize)];
  final tileRegions = [for (final c in kept) c.region];
  final minValid = (roiCfg['min_valid_roi'] as int) - (side ? 1 : 0);
  if (valid < minValid || tiles.isEmpty) throw const QualityRejection(['face_covered']);

  return ViewResult(
    face: sampleSquare(im, fx, fy, fs, inputSize),
    rois: rois,
    tiles: tiles,
    tileRegions: tileRegions,
    sharpness: (sharp * 10).roundToDouble() / 10,
    brightness: (light * 10).roundToDouble() / 10,
  );
}
