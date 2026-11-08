import 'dart:ui';

import 'package:afaskin/features/capture/crop_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CropView', () {
    test('zoom 1 pada gambar landscape: crop persegi di tengah', () {
      // Gambar 800x400 di jendela 320: cover memakai skala 320/400 = 0,8,
      // sehingga lebar tergambar 640 dan yang terlihat adalah 320/0,8 = 400 px
      // di tengah secara horizontal.
      final view = CropView(
        imageWidth: 800,
        imageHeight: 400,
        viewport: 320,
      );
      final r = view.visibleRect;
      expect(r.width, closeTo(400, 0.5));
      expect(r.height, closeTo(400, 0.5));
      expect(r.left, closeTo(200, 0.5));
      expect(r.top, closeTo(0, 0.5));
    });

    test('zoom 1 pada gambar portrait: crop persegi di tengah', () {
      final view = CropView(
        imageWidth: 400,
        imageHeight: 800,
        viewport: 320,
      );
      final r = view.visibleRect;
      expect(r.width, closeTo(400, 0.5));
      expect(r.height, closeTo(400, 0.5));
      expect(r.top, closeTo(200, 0.5));
    });

    test('zoom 2 mempersempit area yang terlihat', () {
      final base = CropView(imageWidth: 800, imageHeight: 400, viewport: 320);
      final zoomed = base.copyWith(zoom: 2);
      expect(zoomed.visibleRect.width, closeTo(base.visibleRect.width / 2, 0.5));
      expect(zoomed.visibleRect.height, closeTo(base.visibleRect.height / 2, 0.5));
    });

    test('pan digeser ke kanan: crop ikut bergeser ke kanan', () {
      final base = CropView(imageWidth: 800, imageHeight: 400, viewport: 320);
      final panned = base.copyWith(pan: const Offset(-80, 0));
      expect(panned.visibleRect.left, greaterThan(base.visibleRect.left));
      // Tetap di dalam batas gambar.
      expect(panned.visibleRect.right, lessThanOrEqualTo(800.5));
    });

    test('pan selalu dibatasi: tidak ada ruang kosong di jendela', () {
      const viewport = 320.0;
      final view = CropView(
        imageWidth: 800,
        imageHeight: 400,
        viewport: viewport,
      );
      for (final p in const [
        Offset(-9999, 0),
        Offset(9999, 0),
        Offset(0, -9999),
        Offset(0, 9999),
      ]) {
        final clamped = view.clampPan(p);
        final tl = view.copyWith(pan: clamped).topLeft;
        expect(tl.dx, lessThanOrEqualTo(0.01));
        expect(tl.dy, lessThanOrEqualTo(0.01));
        expect(tl.dx + view.drawnSize.dx, greaterThanOrEqualTo(viewport - 0.01));
        expect(tl.dy + view.drawnSize.dy, greaterThanOrEqualTo(viewport - 0.01));
      }
    });

    test('gambar sangat tipis tetap menghasilkan crop valid', () {
      final view = CropView(
        imageWidth: 1000,
        imageHeight: 120,
        viewport: 320,
      );
      final r = view.visibleRect;
      expect(r.width, greaterThan(1));
      expect(r.height, greaterThan(1));
      expect(r.right, lessThanOrEqualTo(1000.5));
      expect(r.bottom, lessThanOrEqualTo(120.5));
    });
  });
}
