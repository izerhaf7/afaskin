import 'package:afaskin/ml/ml_texts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Variasi penjelasan jerawat harus mengikuti area lesi, bukan satu kalimat
/// umum untuk semua wajah. Kalau tes ini gagal, aplikasi kembali mengulang
/// teks yang sama di setiap analisis.
void main() {
  test('jerawat di dagu menyebut hormon, di hidung menyebut pori', () {
    final dagu = MlTexts.acneDescription(['dagu']);
    final hidung = MlTexts.acneDescription(['hidung']);
    final pipi = MlTexts.acneDescription(['pipi kiri']);
    final dahi = MlTexts.acneDescription(['dahi']);

    expect(dagu, contains('hormon'));
    expect(hidung, contains('pori'));
    expect(pipi, contains('sarung bantal'));
    expect(dahi, contains('rambut'));

    // Keempatnya harus berbeda satu sama lain.
    expect({dagu, hidung, pipi, dahi}.length, 4);
  });

  test('area pertama yang dikenali dipakai', () {
    // Urutan dari yang paling sering muncul: hidung menang atas dagu.
    expect(MlTexts.acneDescription(['hidung', 'dagu']), contains('pori'));
  });

  test('area tak dikenal jatuh ke kalimat umum, bukan kosong', () {
    final t = MlTexts.acneDescription(['area lain']);
    expect(t, isNotEmpty);
    expect(t, contains('pori'));
  });

  test('setiap area API punya label yang bisa dipakai teks', () {
    // Label area dari API harus cocok dengan kunci acneByRegion, kalau tidak
    // variasi teks tidak pernah terpakai.
    for (final api in [
      'forehead',
      'left_cheek',
      'right_cheek',
      'nose',
      'chin',
    ]) {
      final label = MlTexts.regionLabelOf(api);
      expect(label, isNotEmpty);
      expect(
        MlTexts.acneByRegion.containsKey(label),
        isTrue,
        reason: 'area "$api" -> "$label" tidak ada di acneByRegion',
      );
    }
  });
}
