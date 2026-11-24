import 'face_guidance.dart';

/// Menentukan kapan kamera memotret sendiri.
///
/// Wajah yang lewat di depan kamera bisa sesaat terlihat "siap", dan memotret
/// pada saat itu menghasilkan foto buram atau setengah terpotong. Karena itu
/// kondisi siap harus bertahan [hold] sebelum foto diambil: satu detik cukup
/// memastikan pengguna benar-benar berhenti bergerak, tanpa terasa menunggu.
///
/// Dipisahkan dari widget kamera supaya aturannya bisa diuji tanpa perangkat.
class CaptureHold {
  CaptureHold({this.hold = const Duration(milliseconds: 1000)});

  /// Lama kondisi siap harus bertahan sebelum foto diambil.
  final Duration hold;

  DateTime? _since;

  /// Apakah sudah waktunya memotret, diberi kondisi terbaru dan waktu deteksi.
  ///
  /// Mengembalikan true paling banyak sekali per tahanan: penanda dikosongkan
  /// setelah memicu, sehingga pemanggilan berikutnya menunggu tahanan baru.
  bool shouldCapture(GuidanceStatus status, DateTime now) {
    if (!status.isReady) {
      _since = null;
      return false;
    }
    final since = _since ??= now;
    if (now.difference(since) < hold) return false;
    _since = null;
    return true;
  }

  /// Lupakan tahanan berjalan (mis. saat berganti pose foto).
  void reset() => _since = null;

  /// Seberapa jauh tahanan sudah berjalan, untuk umpan balik cincin.
  double progress(DateTime now) {
    final since = _since;
    if (since == null || hold.inMilliseconds == 0) return 0;
    final p = now.difference(since).inMilliseconds / hold.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }
}
