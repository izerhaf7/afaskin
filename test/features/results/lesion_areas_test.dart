import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/lesion_areas.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lesi dari foto samping harus punya area sendiri, bukan ditempel di posisi
/// foto depan. Sebelum perbaikan, repositori menulis kunci 'view' sedangkan
/// model membaca 'view_index', sehingga semua lesi terbaca sebagai foto depan.
ConditionSpot _spot(
  double x,
  double y, {
  int view = 0,
  SkinConditionLabel label = SkinConditionLabel.acne,
  double size = 0.15,
}) => ConditionSpot(
  x: x,
  y: y,
  size: size,
  label: label,
  region: FaceRegion.leftCheek,
  viewIndex: view,
);

SkinCondition _cond(List<ConditionSpot> spots,
        [SkinConditionLabel label = SkinConditionLabel.acne]) =>
    SkinCondition(
      label: label,
      probability: 0.8,
      regions: const [FaceRegion.leftCheek],
      spots: spots,
    );

void main() {
  group('buildLesionAreas per foto', () {
    test('lesi foto samping tidak masuk area foto depan', () {
      final areas = buildLesionAreas([
        _cond([_spot(0.4, 0.5), _spot(0.5, 0.5, view: 1)]),
      ]);
      expect(areas.where((a) => a.viewIndex == 0).length, 1);
      expect(areas.where((a) => a.viewIndex == 1).length, 1);
      final samping = areas.firstWhere((a) => a.viewIndex == 1);
      expect(samping.spots.single.viewIndex, 1);
    });

    test('setiap foto samping mendapat area sendiri', () {
      final areas = buildLesionAreas([
        _cond([
          _spot(0.3, 0.4),
          _spot(0.3, 0.4, view: 1),
          _spot(0.3, 0.4, view: 2),
        ]),
      ]);
      expect(areas.where((a) => a.viewIndex == 1), isNotEmpty);
      expect(areas.where((a) => a.viewIndex == 2), isNotEmpty);
    });

    test('id berbeda antar view sehingga kartu tidak tertukar', () {
      final areas = buildLesionAreas([
        _cond([_spot(0.3, 0.4), _spot(0.3, 0.4, view: 1)]),
      ]);
      expect(areas.map((a) => a.id).toSet().length, areas.length);
    });
  });

  group('ukuran kotak', () {
    test('dua lesi berdekatan digabung menjadi satu area', () {
      final areas = buildLesionAreas([
        _cond([_spot(0.50, 0.50), _spot(0.52, 0.51)]),
      ]);
      expect(areas.length, 1);
      expect(areas.single.jumlah, 2);
    });

    test('rantai lesi berjauhan tidak melebar menutupi separuh wajah', () {
      // A-B dekat, B-C dekat, A-C jauh: tanpa batas, ketiganya jadi satu kotak
      // raksasa.
      final areas = buildLesionAreas([
        _cond([_spot(0.20, 0.5), _spot(0.28, 0.5), _spot(0.36, 0.5)]),
      ]);
      for (final a in areas) {
        expect(a.bounds.width, lessThanOrEqualTo(batasArea));
        expect(a.bounds.height, lessThanOrEqualTo(batasArea));
      }
    });

    test('satu lesi selalu lebih kecil dari sisi petak', () {
      final areas = buildLesionAreas([
        _cond([_spot(0.5, 0.5)]),
      ]);
      expect(areas.single.bounds.width, lessThan(0.15));
    });
  });
}
