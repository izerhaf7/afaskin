/// All user-facing strings (Bahasa Indonesia) in one place, so they can be
/// moved to ARB files later without hunting through widgets.
abstract final class AppStrings {
  static const String appName = 'Afa Skin';
  static const String tagline =
      'Kenali kulitmu, temukan skincare yang cocok.';

  // Generic actions.
  static const String next = 'Lanjut';
  static const String back = 'Kembali';
  static const String retry = 'Coba lagi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String loading = 'Memuat...';

  // Errors (domain failures).
  static const String errorNetwork =
      'Tidak bisa terhubung ke server. Periksa koneksi internetmu, lalu coba lagi.';
  static const String errorTimeout =
      'Server terlalu lama merespons. Coba lagi sebentar lagi.';
  static const String errorServer =
      'Terjadi kendala di server. Coba lagi beberapa saat lagi.';
  static const String errorUnknown = 'Terjadi kesalahan. Coba lagi.';
  static const String errorQualityDefault =
      'Foto belum memenuhi syarat kualitas. Silakan ambil ulang.';

  /// Human text for quality-gate reason codes returned by the API.
  static const Map<String, String> qualityReasons = {
    'too_dark': 'Foto terlalu gelap',
    'too_bright': 'Foto terlalu terang',
    'blurry': 'Foto kurang tajam',
    'no_face': 'Wajah tidak terdeteksi',
    'multiple_faces': 'Terdeteksi lebih dari satu wajah',
    'face_too_small': 'Wajah terlalu jauh dari kamera',
    'not_frontal': 'Wajah tidak menghadap lurus ke kamera',
  };

  // Dev home (Phase 0 placeholder).
  static const String devHomeBody =
      'Fondasi aplikasi siap. Layar onboarding menyusul di Fase 1.';
  static const String openStyleGuide = 'Buka style guide';

  // Style guide (debug only).
  static const String styleGuideTitle = 'Style guide';
}
