import 'package:afaskin/features/capture/capture_hold.dart';
import 'package:afaskin/features/capture/face_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aturan tangkap otomatis: foto hanya diambil setelah kondisi "siap" bertahan,
/// bukan begitu wajah sesaat terlihat pas. Tanpa tahanan, wajah yang lewat atau
/// masih bergerak ikut terpotret dan hasilnya buram.
void main() {
  final t0 = DateTime(2026, 1, 1, 12);

  test('foto tidak diambil saat wajah baru saja terlihat siap', () {
    final hold = CaptureHold();
    expect(hold.shouldCapture(GuidanceStatus.ready, t0), isFalse);
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(milliseconds: 900))),
      isFalse,
      reason: 'belum satu detik, pengguna masih mungkin bergerak',
    );
  });

  test('foto diambil tepat setelah kondisi siap bertahan satu detik', () {
    final hold = CaptureHold();
    hold.shouldCapture(GuidanceStatus.ready, t0);
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('hanya sekali per tahanan, tidak memotret berulang', () {
    final hold = CaptureHold();
    hold.shouldCapture(GuidanceStatus.ready, t0);
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(seconds: 2))),
      isTrue,
    );
    // Pemanggilan berikutnya harus menunggu tahanan baru.
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(seconds: 3))),
      isFalse,
    );
  });

  test('kondisi tidak siap mengosongkan tahanan', () {
    final hold = CaptureHold();
    hold.shouldCapture(GuidanceStatus.ready, t0);
    hold.shouldCapture(GuidanceStatus.tooFar, t0.add(const Duration(milliseconds: 800)));
    // Siap lagi: hitungan mulai dari nol, bukan menyambung tahanan lama.
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(milliseconds: 900))),
      isFalse,
    );
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(milliseconds: 1900))),
      isTrue,
    );
  });

  test('wajah goyang tidak pernah memicu foto', () {
    final hold = CaptureHold();
    // Siap 0,4 detik, goyang, siap 0,4 detik lagi, berulang: tidak pernah cukup.
    var t = t0;
    for (var i = 0; i < 5; i++) {
      expect(hold.shouldCapture(GuidanceStatus.ready, t), isFalse);
      expect(
        hold.shouldCapture(GuidanceStatus.ready, t.add(const Duration(milliseconds: 400))),
        isFalse,
      );
      hold.shouldCapture(GuidanceStatus.notFrontal, t.add(const Duration(milliseconds: 500)));
      t = t.add(const Duration(milliseconds: 600));
    }
  });

  test('progress menunjukkan seberapa dekat ke pemotretan', () {
    final hold = CaptureHold(hold: const Duration(milliseconds: 1000));
    expect(hold.progress(t0), 0);
    hold.shouldCapture(GuidanceStatus.ready, t0);
    expect(hold.progress(t0.add(const Duration(milliseconds: 500))), closeTo(0.5, 1e-9));
    expect(hold.progress(t0.add(const Duration(seconds: 2))), 1.0);
  });

  test('reset membatalkan tahanan berjalan', () {
    final hold = CaptureHold();
    hold.shouldCapture(GuidanceStatus.ready, t0);
    hold.reset();
    expect(
      hold.shouldCapture(GuidanceStatus.ready, t0.add(const Duration(seconds: 2))),
      isFalse,
    );
  });
}
