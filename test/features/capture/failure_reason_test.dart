import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pengguna perlu tahu KENAPA analisisnya gagal, bukan hanya "coba lagi".
void main() {
  test('kegagalan model menyebut sebabnya', () {
    expect(
      localFailureCause(StateError('no_face')),
      'wajah tidak terdeteksi di foto.',
    );
    expect(
      localFailureCause(StateError('tensor rusak')),
      contains('model menolak foto'),
    );
    expect(
      localFailureCause(const PhotoDecodeException()),
      'foto tidak bisa dibaca.',
    );
  });

  test('galat tak terduga tetap menyebut jenisnya', () {
    expect(localFailureCause(ArgumentError('x')), contains('ArgumentError'));
  });

  test('setiap kode alasan quality gate punya terjemahan', () {
    // Kode yang benar-benar dilempar vision.dart.
    const thrown = [
      'no_face',
      'too_dark',
      'too_bright',
      'multiple_faces',
      'face_too_small',
      'blurry',
      'face_covered',
    ];
    for (final code in thrown) {
      expect(
        AppStrings.qualityReasons.containsKey(code),
        isTrue,
        reason: 'kode "$code" akan tampil mentah ke pengguna',
      );
    }
  });
}
