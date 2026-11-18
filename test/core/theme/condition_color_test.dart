import 'dart:math' as math;

import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/data/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Warna kotak lesi harus bisa dibedakan per kondisi. Sebelumnya `Birthmark`
/// dan `Blackhead` hanya berbeda 9,7 delta-E (nyaris sama di peta kecil), dan
/// `Acne`/`Purulent` 10,1 — pengguna tidak bisa memakai warna sebagai petunjuk.
///
/// Jarak diukur di ruang CIELAB karena mata tidak melihat jarak RGB secara
/// linear; ambang 15 delta-E adalah batas umum "terlihat beda".
double _dE(Color a, Color b) {
  double lin(double u) =>
      u <= 0.04045 ? u / 12.92 : math.pow((u + 0.055) / 1.055, 2.4).toDouble();

  List<double> lab(Color c) {
    final r = lin(c.r), g = lin(c.g), bl = lin(c.b);
    final x = (r * 0.4124 + g * 0.3576 + bl * 0.1805) / 0.95047;
    final y = r * 0.2126 + g * 0.7152 + bl * 0.0722;
    final z = (r * 0.0193 + g * 0.1192 + bl * 0.9505) / 1.08883;
    double f(double t) =>
        t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
    final fx = f(x), fy = f(y), fz = f(z);
    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }

  final p = lab(a), q = lab(b);
  var s = 0.0;
  for (var i = 0; i < 3; i++) {
    s += (p[i] - q[i]) * (p[i] - q[i]);
  }
  return math.sqrt(s);
}

void main() {
  test('setiap kondisi lesi punya warna sendiri', () {
    final lesi = [
      for (final c in SkinConditionLabel.values)
        if (c != SkinConditionLabel.unknown) c,
    ];
    expect(lesi.length, 9);
    for (final c in lesi) {
      expect(
        AppColors.conditionColors.containsKey(
          c.name[0].toUpperCase() + c.name.substring(1),
        ),
        isTrue,
        reason: '${c.name} belum punya warna',
      );
    }
  });

  test('semua pasangan warna terbedakan (>= 15 delta-E)', () {
    final warna = {
      for (final e in AppColors.conditionColors.entries)
        e.key: AppColors.conditionColor(e.key.toLowerCase()),
    };
    final kunci = warna.keys.toList();
    final terlaluMirip = <String>[];
    for (var i = 0; i < kunci.length; i++) {
      for (var j = i + 1; j < kunci.length; j++) {
        final d = _dE(warna[kunci[i]]!, warna[kunci[j]]!);
        if (d < 15) {
          terlaluMirip.add('${kunci[i]}/${kunci[j]} = ${d.toStringAsFixed(1)}');
        }
      }
    }
    expect(terlaluMirip, isEmpty, reason: 'pasangan sulit dibedakan: $terlaluMirip');
  });

  test('nama huruf kecil dan besar menghasilkan warna yang sama', () {
    // Spot disimpan dengan nama enum huruf kecil ('acne'), sedangkan kunci
    // conditionColors berhuruf besar ('Acne'). Kalau pencocokannya putus,
    // semua kotak jatuh ke warna cadangan dan tampak seragam.
    for (final e in AppColors.conditionColors.entries) {
      expect(
        AppColors.conditionColor(e.key.toLowerCase()),
        AppColors.conditionColor(e.key),
        reason: '${e.key} tidak cocok saat huruf kecil',
      );
      expect(AppColors.conditionColor(e.key.toLowerCase()), e.value);
    }
  });
}
