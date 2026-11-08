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
    'face_covered': 'Area kulit wajah tertutup rambut, tangan, atau masker',
  };

  // Style guide (debug only).
  static const String openStyleGuide = 'Buka style guide';
  static const String styleGuideTitle = 'Style guide';

  // Onboarding (Tahap 2).
  static const String skip = 'Lewati';
  static const String start = 'Mulai';
  static const String onboarding1Title = 'Kenali kulitmu dari satu foto';
  static const String onboarding1Body =
      'Afa Skin membaca kondisi kulit wajah dari foto selfie, lalu mencarikan '
      'skincare yang bahan aktifnya cocok untukmu.';
  static const String onboarding2Title = 'Tiga langkah, kurang dari semenit';
  static const String onboarding2Body =
      'Jawab beberapa pertanyaan singkat, ambil foto, lalu lihat produk yang '
      'paling sesuai dengan kondisi kulitmu.';
  static const List<(String, String)> onboarding2Steps = [
    ('1. Foto', 'Selfie wajah tanpa makeup'),
    ('2. Analisis', 'Tipe kulit dan kondisi per area wajah'),
    ('3. Rekomendasi', 'Produk dengan bahan aktif yang cocok'),
  ];
  static const String onboarding3Title = 'Foto yang baik, hasil yang akurat';
  static const String onboarding3Body =
      'Kamera akan memandumu secara langsung. Ikuti petunjuk di layar sampai '
      'tombol foto aktif.';
  static const List<String> onboarding3Tips = [
    'Cahaya dari depan, misalnya menghadap jendela',
    'Wajah bersih, tanpa makeup',
    'Lepas kacamata, rapikan rambut dari dahi',
    'Pegang ponsel sejajar mata',
  ];
  static String onboardingPageLabel(int page, int total) =>
      'Halaman $page dari $total';

  // Consent.
  static const String consentTitle = 'Sebelum mulai';
  static const String consentIntro =
      'Baca dan centang kedua poin di bawah untuk melanjutkan.';
  static const String consentMedicalTitle = 'Afa Skin bukan alat medis';
  static const String consentMedicalBody =
      'Hasil analisis hanya perkiraan dan bukan diagnosis. Untuk masalah kulit '
      'serius, konsultasikan ke dokter kulit.';
  static const String consentPhotoTitle = 'Foto tidak disimpan di server';
  static const String consentPhotoBody =
      'Foto diproses lalu langsung dihapus. Riwayat hasil hanya tersimpan di '
      'ponsel ini.';
  static const String consentAlfa =
      'Tenang, Alfa jaga privasimu. Fotomu tidak disimpan.';
  static const String consentAccept = 'Setuju dan lanjut';
  static const String consentReviewTitle = 'Persetujuan & disclaimer';
  static const String consentAccepted = 'Kamu sudah menyetujui kedua poin ini.';

  // Profile (Alfa asks one thing at a time).
  static const String askName =
      'Kenalan dulu dong, Alfa mau tau nih nama kamu?';
  static const String nameHint = 'Nama panggilanmu';
  static const String nameNote = 'Nama panggilan juga boleh, kok.';
  static String askAge(String name) => 'Salam kenal, $name! Umur kamu berapa?';
  static const String askAgeTooYoung =
      'Waduh, sepertinya umurnya belum cukup nih.';
  static const String ageHint = 'Contoh: 23';
  static const String ageSuffix = 'tahun';
  static const String ageTooYoung = 'Afa Skin untuk pengguna 17 tahun ke atas.';
  static const String ageNote =
      'Umur membantu Alfa memilih bahan aktif yang sesuai.';
  static String askGenderAfterResult(String name) =>
      'Hasilnya sudah keluar! Biar rekomendasinya makin pas, gender kamu '
      'apa, $name?';
  static const String askGender = 'Oke! Kalau gender kamu?';
  static const String genderFemale = 'Perempuan';
  static const String genderMale = 'Laki-laki';
  static const String genderUnspecified = 'Tidak ingin menyebut';
  static const String askBudget =
      'Terakhir nih! Budget per produk kira-kira berapa?';
  static const String budgetHint = '150.000';
  static const String budgetNote =
      'Produk di atas budget tetap bisa kamu lihat nanti.';
  static const String currency = 'Rp';
  static const String toQuestionnaire = 'Lanjut ke kuesioner';
  static const String profileSaved = 'Profil disimpan.';
  static const String profileCompleted =
      'Makasih! Rekomendasi sudah disesuaikan.';
  static const String you = 'kamu';
  static String stepCount(int current, int total) => '$current/$total';

  // Questionnaire.
  static const String questionnaireTitle = 'Kuesioner kulit';
  static String quizLeadFirst(String name, int count) =>
      'Makasih, $name! Sekarang $count pertanyaan singkat, ya.';
  static const String quizLeadLast = 'Pertanyaan terakhir!';
  static const String takeFacePhoto = 'Ambil foto wajah';
  static const String finish = 'Simpan';
  static const String questionnaireEmpty = 'Belum ada pertanyaan tersedia.';
  static const String questionnaireSaved = 'Jawaban kuesioner disimpan.';
  static String likertOption(int value, String? label) =>
      label == null ? '$value' : '$value, $label';
  static String questionProgress(int current, int total) =>
      'Pertanyaan $current dari $total';

  // Main tabs.
  static const String tabAnalysis = 'Analisis';
  static const String tabHistory = 'Riwayat';
  static const String tabSettings = 'Pengaturan';

  // Home (Beranda).
  static String greeting(int hour, String? name) {
    final part = hour < 11
        ? 'pagi'
        : hour < 15
        ? 'siang'
        : hour < 18
        ? 'sore'
        : 'malam';
    final n = (name ?? '').trim();
    return n.isEmpty ? 'Selamat $part' : 'Selamat $part, $n';
  }

  static const String homeTitle = 'Bagaimana kulitmu hari ini?';
  static const String reanalyzeTitle = 'Analisis ulang';
  static String reanalyzeBody(String date) =>
      'Terakhir $date. Ulangi tiap 2 minggu untuk melihat perubahan kulitmu.';
  static const String firstAnalysisTitle = 'Analisis pertama';
  static const String firstAnalysisBody =
      'Ambil satu selfie, Alfa bantu baca kondisi kulitmu.';
  static const String startAnalysis = 'Mulai analisis';
  static const String lastResult = 'Hasil terakhir';
  static const String seeFullResult = 'Lihat hasil lengkap';
  static const String recommendationsTitle = 'Rekomendasi produk';
  static String recoLine(int count, String? budget) => budget == null
      ? '$count produk untuk kulitmu'
      : '$count produk sesuai budget $budget';
  static String nextReminder(String date) =>
      'Pengingat analisis berikutnya: $date';
  static const String openProfile = 'Profil';

  // Re-analyze sheet.
  static String reanalyzeSheetBody(String? date) => date == null
      ? 'Jawaban kuesioner terakhirmu akan dipakai lagi. Perbarui jika '
            'rutinitas atau kondisi kulitmu berubah.'
      : 'Jawaban kuesioner terakhirmu ($date) akan dipakai lagi. Perbarui '
            'jika rutinitas atau kondisi kulitmu berubah.';
  static const String reanalyzeTip =
      'Foto di tempat dan jam yang sama seperti sebelumnya agar hasilnya bisa '
      'dibandingkan.';
  static const String photoNow = 'Langsung ambil foto';
  static const String updateAnswersFirst = 'Perbarui jawaban dulu';

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
  static const String guideTurnHead = 'Tolehkan kepala ke samping (±30°)';
  static const String guideTurnOtherSide = 'Sekarang toleh ke sisi sebaliknya';
  static const String guideTurnLess = 'Kurangi tolehan, cukup ±30°';

  // Capture: three views (front required, two side views optional).
  static const String captureStepFront = 'Foto 1 dari 3 · Tampak depan';
  static const String captureStepSide1 = 'Foto 2 dari 3 · Tampak samping';
  static const String captureStepSide2 = 'Foto 3 dari 3 · Sisi lainnya';
  static const String captureSideHint =
      'Foto samping membantu membaca pipi dan rahang. Boleh dilewati.';
  static const String frontPhotoSaved =
      'Foto depan tersimpan. Sekarang tolehkan kepala ke samping.';
  static const String sidePhotoSaved =
      'Foto samping tersimpan. Sekarang toleh ke sisi lainnya.';
  static const String skipSidePhotos = 'Lewati, analisis sekarang';
  static const String shutter = 'Ambil foto';
  static const String shutterDisabledHint =
      'Tombol aktif setelah posisi wajah dan cahaya pas';
  static const String pickFromGallery = 'Pilih dari galeri';
  static const String processingPhoto = 'Menyiapkan foto...';
  static const String cameraUnavailable =
      'Kamera tidak tersedia. Kamu masih bisa memilih foto dari galeri.';
  static const String photoReadError =
      'Foto tidak bisa dibaca. Coba foto lain.';

  /// Awalan pesan saat model gagal dijalankan; sebabnya ditambahkan di belakang.
  static const String errorLocalAnalysis =
      'Analisis gagal di perangkat, karena';

  // Capture: atur posisi foto dari galeri.
  static const String adjustTitle = 'Atur posisi';
  static const String adjustBody =
      'Geser dan cubit foto supaya wajah pas di dalam kotak. Bagian di luar '
      'kotak tidak ikut dianalisis.';
  static const String adjustUse = 'Gunakan foto ini';
  static const String adjustReset = 'Kembalikan';
  static const String adjustCropError =
      'Gagal memotong foto. Coba pilih foto lain.';

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
  static const String analyzingTitle = 'Alfa lagi membaca kulitmu';
  static const List<String> analyzingSteps = [
    'Memeriksa kualitas foto',
    'Mendeteksi area wajah',
    'Menganalisis kondisi kulit',
    'Mencocokkan bahan aktif',
  ];
  static const String analyzingFooter =
      'Foto akan dihapus setelah analisis selesai';
  static const String netErrorTitle = 'Koneksi terputus';
  static const String netErrorBody =
      'Analisis belum selesai karena internet tidak tersambung. Periksa '
      'koneksimu, lalu coba lagi.';
  static const String serverErrorTitle = 'Analisis belum berhasil';
  static const String backToHome = 'Kembali ke beranda';
  static const String qualityRejectedTitle = 'Foto perlu diambil ulang';
  static const String retakePhoto = 'Ambil ulang foto';
  static const String savedToHistory = 'Hasil baru tersimpan di Riwayat.';

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
  static const String closeupHeading = 'Sorotan area';
  static const String closeupHint =
      'Potongan foto pada area yang terdeteksi, diperbesar. Ketuk untuk '
      'menyorot kondisi terkait.';
  static const String closeupNoPhoto =
      'Sorotan foto hanya tersedia untuk analisis terbaru.';
  static const String ingredientsNeededHeading = 'Kandungan yang dibutuhkan';
  static const String ingredientsHint =
      'Kandungan aktif yang membantu tiap kondisi, beserta manfaatnya.';
  static const String ingredientsBasic =
      'Tidak ada kondisi khusus yang perlu ditangani. Perawatan dasar ini '
      'cukup untuk menjaga kulitmu.';
  static const String ingredientAvoid = 'Sebaiknya dihindari';
  static const String recommendationHeading = 'Rekomendasi produk';
  static const String recommendationHint =
      'Dipilih dari katalog produk lokal berdasarkan kondisi kulitmu.';
  static const String viewAllProducts = 'Lihat semua produk';
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

  /// Label area untuk pengguna. `leftCheek`/`rightCheek` mengikuti sisi gambar:
  /// kotak di kiri layar disebut "Pipi kiri". Ini yang diharapkan pengguna saat
  /// melihat hasilnya, karena foto selfie tampil seperti di cermin.
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
  static String analysisOf(String date) => 'Analisis $date';
  static const String recoTitle = 'Rekomendasi untukmu';
  static const String detail = 'Detail';
  static const String completeProfileTitle = 'Lengkapi profilmu, yuk';
  static const String completeProfileBody =
      'Gender dan budget bikin rekomendasi Alfa makin pas.';
  static const String completeProfileCta = 'Lengkapi · 2 pertanyaan';
  static const String allCategories = 'Semua';
  static const String anyPrice = 'Semua harga';
  static String maxPrice(String amount) => 'Maks $amount';
  static String productCount(int n) => '$n produk';
  static String matchScore(String pct) => '$pct cocok';
  static const String hasConflict = 'Ada konflik bahan';
  static const String recoEmptyTitle = 'Belum ada yang pas di budget ini';
  static const String recoEmptyBody =
      'Matikan filter budget atau pilih kategori lain.';
  static const String scoreNote =
      'Skor kecocokan dihitung dari bahan aktif terhadap hasil analisis. '
      'Afa Skin tidak menerima bayaran dari brand.';
  static const String productPhoto = 'foto produk';
  static const String noAnalysisYet =
      'Belum ada hasil analisis. Mulai analisis dulu, ya.';

  // Budget sheet.
  static const String budgetSheetTitle = 'Budget per produk';
  static const String budgetSheetBody = 'Bisa diubah kapan saja.';

  // Product detail.
  static const String whyRecommended = 'Kenapa direkomendasikan';
  static const String ingredientsHeading = 'Komposisi';
  static const String goodForYou = 'Cocok untukmu';
  static const String conflictHeading = 'Hati-hati konflik bahan aktif';
  static const String fictionalNote =
      'Produk dan brand fiktif untuk keperluan desain.';
  static const String openStore = 'Lihat di toko';
  static const String openingStore = 'Membuka toko mitra di browser.';
  static const String storeUnavailable = 'Tautan toko belum tersedia.';
  static const String savedToFavorites = 'Disimpan ke favorit';
  static const String removedFromFavorites = 'Dihapus dari favorit';
  static const String productImage = 'Foto produk';

  // History.
  static const String historyTitle = 'Riwayat';
  static String trendDown(int points, String since) =>
      'Turun $points% sejak $since. Alfa ikut senang!';
  static String trendUp(int points, String since) =>
      'Naik $points% sejak $since. Yuk cek rekomendasinya.';
  static String trendFlat(String since) => 'Stabil sejak $since.';
  static const String historyLocalNote =
      'Riwayat hanya tersimpan di ponsel ini.';
  static const String historyEmptyTitle = 'Belum ada riwayat';
  static const String historyEmptyBody =
      'Setiap hasil analisis akan tersimpan di sini, jadi kamu bisa memantau '
      'perubahan kulitmu.';
  static const String historyNotFound = 'Riwayat tidak ditemukan.';
  static const String noMainCondition = 'Tanpa kondisi menonjol';
  static const String delete = 'Hapus';
  static const String deleted = 'Riwayat dihapus.';
  static const String undo = 'Urungkan';
  static String deleteEntry(String date) => 'Hapus riwayat $date';

  // Settings.
  static const String settingsTitle = 'Pengaturan';
  static const String skinProfile = 'Profil kulit';
  static const String incomplete = 'belum lengkap';
  static const String change = 'Ubah';
  static const String preferences = 'Preferensi';
  static const String reminder = 'Pengingat analisis ulang';
  static const String settingsRedoQuestionnaire = 'Ulangi kuesioner';
  static const String reminderEvery = 'Setiap 2 minggu';
  static const String language = 'Bahasa';
  static const String languageValue = 'Indonesia';
  static const String moreLanguagesSoon = 'Bahasa lain menyusul.';
  static const String privacyData = 'Privasi & data';
  static const String photoNotStored = 'Foto tidak disimpan';
  static const String photoNotStoredBody = 'Foto dihapus setelah dianalisis';
  static const String clearHistory = 'Hapus semua riwayat';
  static const String clearHistoryTitle = 'Hapus semua riwayat?';
  static String clearHistoryBody(int n) =>
      '$n hasil analisis akan dihapus dari ponsel ini dan tidak bisa '
      'dikembalikan.';
  static const String historyAlreadyEmpty = 'Riwayat sudah kosong.';
  static const String clearAllData = 'Hapus semua data lokal';
  static const String clearAllDataTitle = 'Hapus semua data lokal?';
  static const String clearAllDataBody =
      'Profil, jawaban kuesioner, favorit, riwayat, dan persetujuan akan '
      'dihapus dari perangkat ini. Kamu akan memulai dari awal.';
  static const String others = 'Lainnya';
  static const String aboutApp = 'Tentang Afa Skin';
  static String appVersion(String v) => 'Afa Skin versi $v';

  // About.
  static const String aboutTitle = 'Tentang Afa Skin';
  static const String version = 'Versi';
  static const String teamHeading = 'Tim';
  static const String membersHeading = 'Anggota kelompok';
  static const String attributionHeading = 'Atribusi & lisensi';
  static const List<(String, String)> attributions = [
    (
      'Dataset kondisi kulit',
      'Acne Detection, Roboflow Universe (SKIN CARE). Lisensi CC BY 4.0.',
    ),
    (
      'Dataset tipe kulit',
      'Dry, Oily, and Normal Skin Types, Kaggle (Shakya Dissanayake).',
    ),
    ('MediaPipe Face Mesh', 'Google. Lisensi Apache 2.0.'),
    (
      'Google ML Kit Face Detection',
      'Google. Dipakai di perangkat hanya untuk panduan posisi wajah.',
    ),
    ('Font Belleza', 'Font Diner / Google Fonts. SIL Open Font License 1.1.'),
    (
      'Font judul',
      'League Spartan (SIL Open Font License 1.1), sementara menggantikan '
          'Etna sampai file font Etna tersedia.',
    ),
  ];
  static const String openSourceLicenses = 'Lisensi open source';
  static String modelVersion(String v) => 'Model: $v';
  static const String serverUnreachable = 'Server analisis tidak terjangkau';
  static const String disclaimerShort =
      'Afa Skin bukan alat diagnosis medis. Untuk kondisi serius, '
      'periksakan ke dokter spesialis kulit.';
}
