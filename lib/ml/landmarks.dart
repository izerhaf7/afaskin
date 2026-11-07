import 'dart:math' as math;
import 'dart:typed_data';

import 'package:afaskin/ml/vision.dart';

/// Perhalus titik wajah & masker kulit.
///
/// ML Kit Face Mesh kadang meleset 10-20% lebar wajah (uji di HP, Nov 2026),
/// sehingga area pemindaian jatuh di alis, lubang hidung, atau janggut dan
/// model kondisi membacanya sebagai "Birthmark". Titik ML Kit dipakai sebagai
/// perkiraan awal, lalu model landmark MediaPipe (`face_landmarks.tflite`,
/// model yang sama dengan pipeline notebook 03) dijalankan pada crop wajah
/// yang diluruskan. Hasilnya cocok dengan MediaPipe dalam ~1% lebar wajah.

/// Transformasi affine crop -> gambar: x = a*u + b*v + c, y = d*u + e*v + f.
class Affine {
  const Affine(this.a, this.b, this.c, this.d, this.e, this.f);
  final double a, b, c, d, e, f;
  (double, double) apply(double u, double v) => (a * u + b * v + c, d * u + e * v + f);
}

/// Kotak crop berputar di sekitar [pts] (sudut dari garis sudut mata 33 -> 263),
/// sisi = sisi terpanjang kotak titik × [scale]. Sama dengan `refine.py`.
Affine landmarkCropTransform(List<(double, double)> pts, {double scale = 1.5, int size = 256}) {
  final p33 = pts[33], p263 = pts[263];
  final ang = math.atan2(p263.$2 - p33.$2, p263.$1 - p33.$1);
  var x0 = double.infinity, y0 = double.infinity, x1 = -double.infinity, y1 = -double.infinity;
  for (final p in pts) {
    x0 = math.min(x0, p.$1);
    y0 = math.min(y0, p.$2);
    x1 = math.max(x1, p.$1);
    y1 = math.max(y1, p.$2);
  }
  final cx0 = (x0 + x1) / 2, cy0 = (y0 + y1) / 2;
  final ca = math.cos(ang), sa = math.sin(ang);
  // Putar titik ke posisi tegak (sudut -ang) untuk mencari kotak tegaknya.
  var lx = double.infinity, ly = double.infinity, hx = -double.infinity, hy = -double.infinity;
  for (final p in pts) {
    final dx = p.$1 - cx0, dy = p.$2 - cy0;
    final rx = dx * ca + dy * sa, ry = -dx * sa + dy * ca;
    lx = math.min(lx, rx);
    ly = math.min(ly, ry);
    hx = math.max(hx, rx);
    hy = math.max(hy, ry);
  }
  final mx = (lx + hx) / 2, my = (ly + hy) / 2;
  final cx = cx0 + mx * ca - my * sa, cy = cy0 + mx * sa + my * ca;
  final k = math.max(hx - lx, hy - ly) * scale / size;
  final half = size / 2;
  return Affine(ca * k, -sa * k, cx - half * k * ca + half * k * sa, sa * k, ca * k, cy - half * k * sa - half * k * ca);
}

/// Crop [size]x[size] lewat [m] (bilinear, luar gambar = hitam), RGB 0-1.
/// Sama dengan `cv2.warpAffine(..., WARP_INVERSE_MAP | INTER_LINEAR)`.
Float32List warpCrop(RgbImage im, Affine m, {int size = 256}) {
  final out = Float32List(size * size * 3);
  var o = 0;
  double px(int x, int y, int c) =>
      (x < 0 || y < 0 || x >= im.w || y >= im.h) ? 0 : im.px[(y * im.w + x) * 3 + c].toDouble();
  for (var v = 0; v < size; v++) {
    for (var u = 0; u < size; u++) {
      final (x, y) = m.apply(u.toDouble(), v.toDouble());
      final xf = x.floor(), yf = y.floor();
      final fx = x - xf, fy = y - yf;
      for (var c = 0; c < 3; c++) {
        final top = px(xf, yf, c) * (1 - fx) + px(xf + 1, yf, c) * fx;
        final bot = px(xf, yf + 1, c) * (1 - fx) + px(xf + 1, yf + 1, c) * fx;
        out[o++] = (top * (1 - fy) + bot * fy) / 255;
      }
    }
  }
  return out;
}

/// Keluaran model (478 × xyz, koordinat piksel crop) -> 468 titik di gambar.
List<(double, double)> mapLandmarks(Float32List out, Affine m) => [
  for (var i = 0; i < 468; i++) m.apply(out[i * 3], out[i * 3 + 1]),
];

// ---------------------------------------------------------------- masker kulit

/// Kontur wajah MediaPipe (FACEMESH_FACE_OVAL, berurutan).
const faceOval = [
  10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 365, 379, 378, 400, 377, //
  152, 148, 176, 149, 150, 136, 172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109,
];

/// Area bukan kulit: (titik, pembesaran dari pusat). Mata+alis, bibir, hidung bawah.
const _excluded = <(List<int>, double)>[
  ([33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246, 46, 53, 52, 65, 55, 70, 63, 105, 66, 107], 0.25),
  ([263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466, 276, 283, 282, 295, 285, 300, 293, 334, 296, 336], 0.25),
  ([61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291, 409, 270, 269, 267, 0, 37, 39, 40, 185], 0.25),
  ([48, 64, 98, 97, 2, 326, 327, 294, 278, 219, 439, 240, 460, 75, 305], 0.15),
];

class FaceMask {
  FaceMask(List<(double, double)> pts)
    : oval = [for (final i in faceOval) pts[i]],
      holes = [for (final (ids, grow) in _excluded) _grownHull([for (final i in ids) pts[i]], grow)];

  final List<(double, double)> oval;
  final List<List<(double, double)>> holes;

  bool isSkin(double x, double y) => _inside(oval, x, y) && !holes.any((h) => _inside(h, x, y));

  /// Kotak (x0, y0, s) dianggap kulit kalau pusat & 4 titik dalamnya (20%/80%) kulit.
  bool boxIsSkin(int x0, int y0, int s) {
    for (final (fx, fy) in const [(.5, .5), (.2, .2), (.8, .2), (.2, .8), (.8, .8)]) {
      if (!isSkin(x0 + fx * s, y0 + fy * s)) return false;
    }
    return true;
  }
}

/// Ray casting (poligon boleh tidak cembung).
bool _inside(List<(double, double)> poly, double x, double y) {
  var c = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final (xi, yi) = poly[i];
    final (xj, yj) = poly[j];
    if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) c = !c;
  }
  return c;
}

/// Convex hull (monotone chain), diperbesar [grow] dari rata-rata titik.
List<(double, double)> _grownHull(List<(double, double)> p, double grow) {
  final s = [...p]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  double cross((double, double) o, (double, double) a, (double, double) b) =>
      (a.$1 - o.$1) * (b.$2 - o.$2) - (a.$2 - o.$2) * (b.$1 - o.$1);
  final lower = <(double, double)>[], upper = <(double, double)>[];
  for (final q in s) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in s.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  final hull = [...lower..removeLast(), ...upper..removeLast()];
  var mx = 0.0, my = 0.0;
  for (final q in p) {
    mx += q.$1;
    my += q.$2;
  }
  mx /= p.length;
  my /= p.length;
  return [for (final q in hull) (mx + (q.$1 - mx) * (1 + grow), my + (q.$2 - my) * (1 + grow))];
}
