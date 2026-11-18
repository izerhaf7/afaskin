import 'dart:convert';

import 'package:afaskin/data/models/enums.dart';
import 'package:afaskin/data/models/analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Spot lesi disimpan ke JSON lalu dibaca kembali oleh layar hasil.
///
/// Nama enum kondisi di JSON berhuruf kecil ('acne'), sedangkan kunci
/// probabilitas dari model berhuruf besar ('Acne'). Dulu repository menulis
/// 'Acne', sehingga pembacaan kembali menghasilkan `unknown` dan semua kotak
/// lesi tampil dengan warna cadangan yang sama.
void main() {
  Map<String, dynamic> spotJson(String label) => {
    'x': 0.5,
    'y': 0.4,
    'size': 0.15,
    'label': label,
    'region': 'forehead',
    'viewIndex': 0,
  };

  test('label huruf kecil terbaca sebagai kondisi yang benar', () {
    final spot = ConditionSpot.fromJson(spotJson('acne'));
    expect(spot.label, SkinConditionLabel.acne);
    expect(spot.label, isNot(SkinConditionLabel.unknown));
  });

  test('label huruf besar jatuh ke unknown (bukti bug lama)', () {
    final spot = ConditionSpot.fromJson(spotJson('Acne'));
    expect(spot.label, SkinConditionLabel.unknown);
  });

  test('semua kondisi bertahan pada simpan-baca ulang', () {
    const nama = [
      'acne',
      'birthmark',
      'blackhead',
      'cysts',
      'milium',
      'papular',
      'purulent',
      'scars',
      'whitehead',
    ];
    for (final n in nama) {
      final asli = ConditionSpot.fromJson(spotJson(n));
      final bolak = ConditionSpot.fromJson(
        jsonDecode(jsonEncode(asli.toJson())) as Map<String, dynamic>,
      );
      expect(bolak.label, asli.label, reason: '$n berubah setelah simpan-baca');
      expect(bolak.label, isNot(SkinConditionLabel.unknown), reason: n);
    }
  });

  test('toLowerCase pada kunci model menghasilkan label yang valid', () {
    // Meniru yang ditulis repository: c.key dari model berhuruf besar.
    for (final key in ['Acne', 'Scars', 'Blackhead', 'Whitehead']) {
      final spot = ConditionSpot.fromJson(spotJson(key.toLowerCase()));
      expect(spot.label, isNot(SkinConditionLabel.unknown), reason: key);
    }
  });
}
