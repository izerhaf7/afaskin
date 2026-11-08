import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

/// Model tampilan gambar di jendela crop persegi.
///
/// Gambar selalu menutupi jendela penuh (`BoxFit.cover`) pada zoom 1, lalu
/// pengguna bisa memperbesar ([zoom] >= 1) dan menggeser ([pan]). Semua nilai
/// dalam piksel jendela, kecuali disebut lain.
class CropView {
  const CropView({
    required this.imageWidth,
    required this.imageHeight,
    required this.viewport,
    this.zoom = 1,
    this.pan = Offset.zero,
  });

  final double imageWidth;
  final double imageHeight;

  /// Sisi jendela crop (persegi).
  final double viewport;

  /// 1 = pas menutupi jendela, 2 = dua kali lebih besar.
  final double zoom;

  /// Pergeseran gambar dari posisi tengah, dalam piksel jendela.
  final Offset pan;

  /// Skala yang membuat gambar menutupi jendela.
  double get coverScale => math.max(viewport / imageWidth, viewport / imageHeight);

  /// Skala efektif (cover x zoom).
  double get scale => coverScale * zoom;

  /// Ukuran gambar setelah diskalakan.
  Offset get drawnSize => Offset(imageWidth * scale, imageHeight * scale);

  /// Pojok kiri-atas gambar di koordinat jendela.
  Offset get topLeft => Offset(
    (viewport - drawnSize.dx) / 2 + pan.dx,
    (viewport - drawnSize.dy) / 2 + pan.dy,
  );

  /// Batasi [pan] supaya gambar tidak pernah menyisakan ruang kosong.
  Offset clampPan(Offset p) {
    final dx = drawnSize.dx, dy = drawnSize.dy;
    final baseX = (viewport - dx) / 2, baseY = (viewport - dy) / 2;
    // Bila gambar lebih kecil dari jendela (tidak terjadi saat zoom >= 1),
    // cukup dikunci ke tengah.
    final minX = math.min(0.0, viewport - dx), minY = math.min(0.0, viewport - dy);
    return Offset(
      (baseX + p.dx).clamp(minX, 0.0) - baseX,
      (baseY + p.dy).clamp(minY, 0.0) - baseY,
    );
  }

  /// Bagian gambar yang terlihat, dalam piksel gambar asli.
  Rect get visibleRect {
    final tl = topLeft;
    final x0 = (-tl.dx / scale).clamp(0.0, imageWidth);
    final y0 = (-tl.dy / scale).clamp(0.0, imageHeight);
    final x1 = ((viewport - tl.dx) / scale).clamp(0.0, imageWidth);
    final y1 = ((viewport - tl.dy) / scale).clamp(0.0, imageHeight);
    final w = math.min(x1 - x0, imageWidth), h = math.min(y1 - y0, imageHeight);
    if (w <= 1 || h <= 1) return Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    return Rect.fromLTWH(x0, y0, w, h);
  }

  CropView copyWith({double? zoom, Offset? pan}) => CropView(
    imageWidth: imageWidth,
    imageHeight: imageHeight,
    viewport: viewport,
    zoom: zoom ?? this.zoom,
    pan: pan ?? this.pan,
  );
}

/// Zoom minimum: gambar harus selalu menutupi jendela.
const double kMinCropZoom = 1;
const double kMaxCropZoom = 4;
