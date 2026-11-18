import 'package:afaskin/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Warna kotak lesi harus berbeda per kondisi.
///
/// `SkinConditionLabel.name` menghasilkan huruf kecil ('acne'), sedangkan kunci
/// [AppColors.conditionColors] berhuruf besar ('Acne'). Dulu pencariannya gagal
/// dan semua kotak jatuh ke warna cadangan, sehingga peta wajah tampak
/// satu warna padahal kondisinya berbeda.
void main() {
  test('warna kondisi cocok untuk nama enum huruf kecil', () {
    expect(AppColors.conditionColor('acne'), AppColors.conditionColors['Acne']);
    expect(AppColors.conditionColor('scars'), AppColors.conditionColors['Scars']);
    expect(AppColors.conditionColor('blackhead'),
        AppColors.conditionColors['Blackhead']);
  });

  test('warna kondisi tetap cocok untuk nama berhuruf besar', () {
    expect(AppColors.conditionColor('Acne'), AppColors.conditionColors['Acne']);
    expect(AppColors.conditionColor('Whitehead'),
        AppColors.conditionColors['Whitehead']);
  });

  test('setiap kondisi punya warna berbeda, bukan warna cadangan', () {
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
    final warna = <int>{};
    for (final n in nama) {
      final c = AppColors.conditionColor(n);
      expect(c, isNot(AppColors.caution), reason: '$n jatuh ke warna cadangan');
      warna.add(c.toARGB32());
    }
    expect(warna.length, nama.length, reason: 'warna antar kondisi harus unik');
  });

  test('kondisi tak dikenal memakai warna cadangan', () {
    expect(AppColors.conditionColor('unknown'), AppColors.caution);
    expect(AppColors.conditionColor(''), AppColors.caution);
  });
}
