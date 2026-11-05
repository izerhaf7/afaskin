import 'package:afaskin/data/models/enums.dart';

/// All user-facing strings (Bahasa Indonesia) in one place, so they can be
/// moved to ARB files later without hunting through widgets.
abstract final class AppStrings {
  static const String appName = 'Afa Skin';
  static const String tagline = 'Kenali kulitmu, temukan skincare yang cocok.';

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

  // Style guide (debug only).
  static const String openStyleGuide = 'Buka style guide';
  static const String styleGuideTitle = 'Style guide';

  // Onboarding.
  static const String skip = 'Lewati';
  static const String start = 'Mulai';
  static const String onboarding1Title = 'Kenali kulitmu';
  static const String onboarding1Body =
      'Afa Skin membaca kondisi kulit wajahmu dari satu foto selfie, '
      'lalu mencarikan skincare dengan bahan aktif yang cocok.';
  static const String onboarding2Title = 'Cara kerjanya';
  static const List<(String, String)> onboarding2Steps = [
    ('Foto', 'Ambil selfie dengan panduan posisi dan cahaya.'),
    ('Analisis', 'Tipe kulit dan kondisi kulit dibaca per area wajah.'),
    ('Rekomendasi', 'Produk dipilih berdasarkan kecocokan bahan aktif.'),
  ];
  static const String onboarding3Title = 'Tips foto yang baik';
  static const List<String> onboarding3Tips = [
    'Cari cahaya alami yang merata, hindari lampu dari belakang.',
    'Bersihkan wajah dari makeup.',
    'Rapikan rambut agar dahi terlihat.',
    'Hadapkan wajah lurus ke kamera.',
  ];
  static String onboardingPageLabel(int page, int total) =>
      'Halaman $page dari $total';

  // Consent.
  static const String consentTitle = 'Sebelum mulai';
  static const String consentIntro =
      'Baca dan setujui dua hal berikut untuk memakai Afa Skin.';
  static const String consentMedicalTitle = 'Bukan diagnosis medis';
  static const String consentMedicalBody =
      'Afa Skin memberi perkiraan berbasis model pembelajaran mesin, bukan '
      'diagnosis dokter. Untuk kondisi serius, misalnya kista atau jerawat '
      'meradang parah, periksakan ke dokter spesialis kulit.';
  static const String consentMedicalCheck =
      'Saya mengerti hasil Afa Skin bukan diagnosis medis.';
  static const String consentPhotoTitle = 'Privasi foto';
  static const String consentPhotoBody =
      'Foto hanya dipakai untuk analisis dan tidak disimpan di server. '
      'Di perangkatmu, foto dihapus setelah terkirim, dan riwayat hanya '
      'menyimpan hasil analisis tanpa foto.';
  static const String consentPhotoCheck =
      'Saya setuju foto saya dikirim ke server untuk dianalisis.';
  static const String consentAccept = 'Setuju dan lanjut';

  // Profile.
  static const String profileTitle = 'Profil kamu';
  static const String profileIntro =
      'Dipakai untuk menyesuaikan analisis dan rekomendasi produk.';
  static const String profileEditTitle = 'Edit profil';
  static const String ageLabel = 'Umur';
  static const String ageHint = 'Contoh: 21';
  static const String ageSuffix = 'tahun';
  static const String ageError = 'Masukkan umur antara 12 dan 100 tahun.';
  static const String genderLabel = 'Gender';
  static const String genderFemale = 'Perempuan';
  static const String genderMale = 'Laki-laki';
  static const String genderOther = 'Lainnya';
  static const String genderError = 'Pilih salah satu.';
  static const String budgetLabel = 'Budget maksimum per produk';
  static const String budgetError = 'Pilih rentang budget.';
  static String budgetUpTo(String amount) => 'Sampai $amount';
  static const String profileSaved = 'Profil disimpan.';

  // Questionnaire.
  static const String questionnaireTitle = 'Kuesioner kulit';
  static String questionProgress(int current, int total) =>
      'Pertanyaan $current dari $total';
  static const String finish = 'Selesai';
  static const String questionnaireEmpty = 'Belum ada pertanyaan tersedia.';
  static const String questionnaireSaved = 'Jawaban kuesioner disimpan.';
  static String likertOption(int value, String? label) =>
      label == null ? '$value' : '$value, $label';

  // Main tabs.
  static const String tabAnalysis = 'Analisis';
  static const String tabHistory = 'Riwayat';
  static const String tabSettings = 'Pengaturan';

  // Analysis home.
  static const String greeting = 'Halo!';
  static const String homeTitle = 'Siap cek kulitmu?';
  static const String homeBody =
      'Ambil satu foto selfie. Analisis butuh beberapa detik.';
  static const String startAnalysis = 'Mulai analisis';
  static const String comingSoon = 'Segera hadir';
  static const String comingSoonBody =
      'Fitur ini sedang dibangun dan akan tersedia di versi berikutnya.';

  // History (placeholder until Phase 4).
  static const String historyEmptyTitle = 'Belum ada riwayat';
  static const String historyEmptyBody =
      'Hasil analisis akan tersimpan di sini, tanpa foto.';

  // Settings.
  static const String settingsEditProfile = 'Edit profil';
  static const String settingsRedoQuestionnaire = 'Ulangi kuesioner';
  static const String settingsClearData = 'Hapus semua data lokal';
  static const String settingsAbout = 'Tentang';

  // Capture: camera guidance.
  static const String captureTitle = 'Ambil foto';
  static const String guideNoFace = 'Arahkan wajah ke kamera';
  static const String guideMultipleFaces = 'Pastikan hanya ada satu wajah';
  static const String guideTooDark = 'Cari tempat lebih terang';
  static const String guideTooBright =
      'Cahaya terlalu silau, cari tempat lebih teduh';
  static const String guideTooFar = 'Dekatkan wajah';
  static const String guideTooClose = 'Jauhkan sedikit wajahmu';
  static const String guideOffCenter = 'Posisikan wajah di dalam oval';
  static const String guideNotFrontal = 'Hadapkan wajah lurus';
  static const String guideReady = 'Pas! Tahan sebentar, lalu ambil foto';
  static const String shutter = 'Ambil foto';
  static const String shutterDisabledHint =
      'Tombol aktif setelah posisi wajah dan cahaya pas';
  static const String pickFromGallery = 'Pilih dari galeri';
  static const String processingPhoto = 'Menyiapkan foto...';
  static const String cameraUnavailable =
      'Kamera tidak tersedia. Kamu masih bisa memilih foto dari galeri.';
  static const String photoReadError =
      'Foto tidak bisa dibaca. Coba foto lain.';

  // Capture: permission.
  static const String permissionTitle = 'Izinkan akses kamera';
  static const String permissionBody =
      'Afa Skin memakai kamera depan untuk memandu posisi wajah dan '
      'mengambil satu foto selfie. Foto tidak disimpan di server.';
  static const String permissionAllow = 'Izinkan kamera';
  static const String permissionDeniedTitle = 'Akses kamera ditolak';
  static const String permissionDeniedBody =
      'Akses kamera dimatikan untuk Afa Skin. Aktifkan lewat pengaturan HP, '
      'atau pilih foto dari galeri.';
  static const String openSettings = 'Buka pengaturan HP';

  // Analyzing.
  static const List<String> analyzingSteps = [
    'Memeriksa kualitas foto...',
    'Mendeteksi area wajah...',
    'Menganalisis kondisi kulit...',
    'Mencocokkan dengan jawaban kuesioner...',
    'Menyusun rekomendasi...',
  ];
  static const String analyzingTitle = 'Menganalisis';
  static const String qualityRejectedTitle = 'Foto perlu diambil ulang';
  static const String retakePhoto = 'Ambil ulang foto';

  // Result.
  static const String resultTitle = 'Hasil analisis';
  static const String skinTypeHeading = 'Tipe kulit';
  static const String confidence = 'keyakinan';
  static const String conditionsHeading = 'Kondisi terdeteksi';
  static const String conditionsEmpty =
      'Tidak ada kondisi kulit yang menonjol terdeteksi.';
  static const String faceMapHeading = 'Peta wajah';
  static const String faceMapHint =
      'Ketuk kondisi untuk melihat areanya di wajah.';
  static const String dermatologistTitle = 'Pertimbangkan ke dokter kulit';
  static const String dermatologistBody =
      'Terdeteksi tanda yang sebaiknya diperiksa langsung oleh dokter '
      'spesialis kulit, terutama jika terasa sakit atau meradang.';
  static const String seeRecommendations = 'Lihat rekomendasi produk';
  static String fusionNote(double alpha) =>
      'Hasil menggabungkan foto (${(alpha * 100).round()}%) dan jawaban '
      'kuesioner (${((1 - alpha) * 100).round()}%).';
  static String percentOf(String label, String pct) => '$label, $pct';

  static String skinType(SkinType t) => switch (t) {
    SkinType.oily => 'Berminyak',
    SkinType.dry => 'Kering',
    SkinType.normal => 'Normal',
    SkinType.unknown => 'Tidak diketahui',
  };

  static String skinTypeKey(String key) => switch (key) {
    'oily' => skinType(SkinType.oily),
    'dry' => skinType(SkinType.dry),
    'normal' => skinType(SkinType.normal),
    _ => key,
  };

  static String condition(SkinConditionLabel c) => switch (c) {
    SkinConditionLabel.acne => 'Jerawat',
    SkinConditionLabel.birthmark => 'Tanda lahir',
    SkinConditionLabel.blackhead => 'Komedo hitam',
    SkinConditionLabel.cysts => 'Jerawat kista',
    SkinConditionLabel.milium => 'Milia',
    SkinConditionLabel.papular => 'Papula',
    SkinConditionLabel.purulent => 'Jerawat bernanah',
    SkinConditionLabel.scars => 'Bekas jerawat',
    SkinConditionLabel.whitehead => 'Komedo putih',
    SkinConditionLabel.unknown => 'Kondisi lain',
  };

  /// Fallback descriptions when the API sends none.
  static String conditionDescription(SkinConditionLabel c) => switch (c) {
    SkinConditionLabel.acne =>
      'Peradangan pada pori akibat sebum, sel kulit mati, dan bakteri.',
    SkinConditionLabel.birthmark =>
      'Area kulit dengan warna berbeda sejak lahir. Umumnya tidak berbahaya.',
    SkinConditionLabel.blackhead =>
      'Komedo terbuka: pori tersumbat sebum yang teroksidasi menjadi gelap.',
    SkinConditionLabel.cysts => 'Benjolan besar di bawah kulit yang bisa nyeri. Sebaiknya ke dokter kulit.',
    SkinConditionLabel.milium =>
      'Bintik putih kecil keras akibat keratin yang terperangkap.',
    SkinConditionLabel.papular =>
      'Benjolan kecil kemerahan tanpa nanah, tanda pori meradang.',
    SkinConditionLabel.purulent =>
      'Jerawat berisi nanah. Jangan dipencet; pertimbangkan ke dokter kulit.',
    SkinConditionLabel.scars =>
      'Bekas jerawat berupa cekungan atau noda gelap.',
    SkinConditionLabel.whitehead =>
      'Komedo tertutup: sumbatan pori di bawah lapisan kulit tipis.',
    SkinConditionLabel.unknown => '',
  };

  static String region(FaceRegion r) => switch (r) {
    FaceRegion.forehead => 'Dahi',
    FaceRegion.leftCheek => 'Pipi kiri',
    FaceRegion.rightCheek => 'Pipi kanan',
    FaceRegion.nose => 'Hidung',
    FaceRegion.chin => 'Dagu',
    FaceRegion.unknown => 'Area lain',
  };

  static String category(ProductCategory c) => switch (c) {
    ProductCategory.cleanser => 'Cleanser',
    ProductCategory.toner => 'Toner',
    ProductCategory.serum => 'Serum',
    ProductCategory.moisturizer => 'Moisturizer',
    ProductCategory.sunscreen => 'Sunscreen',
    ProductCategory.unknown => 'Lainnya',
  };

  // Recommendations.
  static const String recommendationsTitle = 'Rekomendasi produk';
  static const String allCategories = 'Semua';
  static const String anyPrice = 'Semua harga';
  static const String budgetFilter = 'Budget';
  static String matchScore(String pct) => '$pct cocok';
  static const String hasWarning = 'Ada peringatan bahan';
  static const String recommendationsEmpty =
      'Tidak ada produk untuk filter ini.';
  static const String recommendationsEmptyBody =
      'Coba kategori lain atau naikkan budget.';
  static const String resetFilters = 'Atur ulang filter';

  // Product detail.
  static const String whyRecommended = 'Kenapa direkomendasikan';
  static const String matchedIngredients = 'Bahan aktif yang cocok';
  static const String ingredientsHeading = 'Komposisi';
  static const String ingredientsLegend =
      'Bahan yang disorot hijau relevan dengan kondisi kulitmu.';
  static const String conflictHeading = 'Peringatan konflik bahan aktif';
  static const String source = 'Sumber';
  static const String productImage = 'Foto produk';
}
