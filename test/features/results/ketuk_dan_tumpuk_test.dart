import 'dart:math' as math;
import 'dart:ui' show Rect, Offset;

import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/lesion_areas.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dua keluhan yang dikunci di sini:
///
/// 1. Sebagian kotak tidak bisa ditekan. `hitTestArea` menganggap ketukan hanya
///    kena bila titiknya **di dalam** kotak, padahal kotak di peta bisa sangat
///    kecil (sisi lesi ~0,04 lebar foto). Jari manusia lebih lebar dari itu,
///    sehingga ketukan yang tepat di atas lesi sering meleset ke luar kotak dan
///    tidak menyorot apa pun.
/// 2. Kotak masih menumpuk. `buildLesionAreas` memakai jarak 0,05 dengan
///    penggabungan transitif, lalu bila kelompoknya melebar melebihi 0,30 tiap
///    deteksi dipisah menjadi kotaknya sendiri — dan kotak-kotak pecahan itu
///    saling menimpa karena berasal dari deteksi yang memang berdekatan.
ConditionSpot _spot(double x, double y, {double size = 0.074, int view = 0}) =>
    ConditionSpot(
      x: x,
      y: y,
      size: size,
      label: SkinConditionLabel.acne,
      region: FaceRegion.rightCheek,
      viewIndex: view,
    );

LesionArea _area(String id, Rect bounds) => LesionArea(
      id: id,
      label: SkinConditionLabel.acne,
      viewIndex: 0,
      spots: [_spot(bounds.center.dx, bounds.center.dy)],
      bounds: bounds,
    );

double _tumpang(Rect a, Rect b) {
  final i = a.intersect(b);
  if (i.width <= 0 || i.height <= 0) return 0;
  return i.width * i.height /
      math.min(a.width * a.height, b.width * b.height);
}

void main() {
  group('ketukan kotak kecil tetap terasa', () {
    test('ketukan tepat di pusat kotak kecil menyorot kotak itu', () {
      final areas = [_area('a', Rect.fromCenter(center: const Offset(0.5, 0.5), width: 0.04, height: 0.04))];
      expect(hitTestArea(areas, const Offset(0.5, 0.5))?.id, 'a');
    });

    test('ketukan sedikit di luar kotak kecil masih menyorotnya', () {
      // 0,02 di luar tepi kotak: jari manusia biasa meleset sejauh ini.
      final areas = [_area('a', Rect.fromCenter(center: const Offset(0.5, 0.5), width: 0.04, height: 0.04))];
      expect(hitTestArea(areas, const Offset(0.54, 0.5))?.id, 'a');
      expect(hitTestArea(areas, const Offset(0.5, 0.545))?.id, 'a');
    });

    test('kotak kecil menang atas kotak besar yang menutupinya', () {
      final areas = [
        _area('besar', Rect.fromCenter(center: const Offset(0.5, 0.5), width: 0.30, height: 0.30)),
        _area('kecil', Rect.fromCenter(center: const Offset(0.52, 0.52), width: 0.04, height: 0.04)),
      ];
      // Mengetuk tepat di pusat kotak kecil harus memilih yang kecil.
      expect(hitTestArea(areas, const Offset(0.52, 0.52))?.id, 'kecil');
    });

    test('ketukan jauh tidak menyorot apa pun', () {
      final areas = [_area('a', Rect.fromCenter(center: const Offset(0.2, 0.2), width: 0.04, height: 0.04))];
      expect(hitTestArea(areas, const Offset(0.8, 0.8)), isNull);
    });
  });

  group('kotak di peta tidak menumpuk', () {
    List<LesionArea> areasDari(List<ConditionSpot> spots) => buildLesionAreas([
          SkinCondition(
            label: SkinConditionLabel.acne,
            probability: 0.8,
            regions: const [],
            spots: spots,
          ),
        ]);

    test('deretan lesi berdekatan tidak menghasilkan kotak bertumpuk', () {
      final spots = [
        for (var i = 0; i < 14; i++) _spot(0.20 + i * 0.045, 0.50),
      ];
      final areas = areasDari(spots);
      for (var i = 0; i < areas.length; i++) {
        for (var j = i + 1; j < areas.length; j++) {
          expect(_tumpang(areas[i].bounds, areas[j].bounds), lessThan(0.45),
              reason: 'area $i dan $j bertumpuk '
                  '${_tumpang(areas[i].bounds, areas[j].bounds).toStringAsFixed(2)}');
        }
      }
    });

    test('bidang lesi 2 dimensi tidak menghasilkan kotak bertumpuk', () {
      final spots = [
        for (var iy = 0; iy < 5; iy++)
          for (var ix = 0; ix < 5; ix++) _spot(0.3 + ix * 0.05, 0.4 + iy * 0.05),
      ];
      final areas = areasDari(spots);
      expect(areas, isNotEmpty);
      for (var i = 0; i < areas.length; i++) {
        for (var j = i + 1; j < areas.length; j++) {
          expect(_tumpang(areas[i].bounds, areas[j].bounds), lessThan(0.45));
        }
      }
    });

    test('setiap kotak tetap bisa ditekan di pusatnya', () {
      final spots = [
        for (var iy = 0; iy < 4; iy++)
          for (var ix = 0; ix < 4; ix++) _spot(0.25 + ix * 0.05, 0.45 + iy * 0.05),
      ];
      final areas = areasDari(spots);
      for (final a in areas) {
        expect(hitTestArea(areas, a.bounds.center)?.id, a.id,
            reason: 'kotak ${a.id} tidak bisa ditekan di pusatnya sendiri');
      }
    });

    test('lesi berjauhan tetap kotak terpisah', () {
      final areas = areasDari([_spot(0.25, 0.30), _spot(0.75, 0.70)]);
      expect(areas, hasLength(2));
    });

    test('jumlah kotak tidak melebihi jumlah deteksi', () {
      final spots = [
        for (var i = 0; i < 20; i++) _spot(0.2 + (i % 5) * 0.06, 0.3 + (i ~/ 5) * 0.06),
      ];
      expect(areasDari(spots).length, lessThanOrEqualTo(spots.length));
    });
  });
}
