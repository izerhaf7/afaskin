/// Teks hasil analisis & rekomendasi (Bahasa Indonesia), dipakai engine ML lokal.
abstract final class MlTexts {
  /// label API -> (nama singkat, deskripsi)
  ///
  /// Deskripsi harus menyebut apa yang membedakan tiap lesi, bukan kalimat umum
  /// "peradangan folikel rambut" untuk semuanya. Pengguna melihat kotak berbeda
  /// warna dengan nama berbeda; kalau penjelasannya sama, aplikasi terbaca
  /// sebagai satu teks tempelan.
  static const Map<String, (String, String)> condition = {
    'acne': (
      'jerawat',
      'Peradangan pori yang tersumbat sebum dan sel kulit mati, biasanya '
          'berbintik merah dan terasa nyeri bila disentuh.',
    ),
    'birthmark': (
      'tanda lahir',
      'Tanda lahir atau tahi lalat. Bukan masalah skincare; periksakan ke '
          'dokter bila bentuk atau warnanya berubah.',
    ),
    'blackhead': (
      'komedo hitam',
      'Pori tersumbat yang permukaannya terbuka, sehingga sebum teroksidasi '
          'udara dan berwarna gelap. Tidak meradang.',
    ),
    'cysts': (
      'jerawat kistik',
      'Benjolan besar dan dalam di bawah permukaan kulit, berisi nanah dan '
          'sering nyeri. Sebaiknya ditangani dokter kulit.',
    ),
    'milium': (
      'milia',
      'Bintik putih keras berisi keratin yang terperangkap di bawah kulit, '
          'bukan nanah. Sering muncul di sekitar mata dan pipi.',
    ),
    'papular': (
      'papula',
      'Benjolan kecil kemerahan tanpa nanah, tanda pori meradang tetapi belum '
          'membentuk pustula.',
    ),
    'purulent': (
      'pustula',
      'Jerawat berisi nanah dengan ujung putih kekuningan, tanda infeksi '
          'bakteri di dalam pori. Jangan dipencet.',
    ),
    'scars': (
      'bekas jerawat',
      'Noda gelap atau tekstur tidak rata yang tertinggal setelah jerawat '
          'sembuh. Bukan lesi aktif, jadi tidak nyeri.',
    ),
    'whitehead': (
      'komedo putih',
      'Pori tersumbat yang tertutup lapisan kulit tipis, sehingga tampak '
          'sebagai bintik putih tanpa lubang terbuka.',
    ),
    'clear': ('kulit bersih', 'Tidak terlihat masalah kulit yang menonjol.'),
  };

  /// Variasi penjelasan jerawat menurut area tempat lesinya paling banyak.
  ///
  /// Satu kalimat untuk semua jerawat membuat aplikasi terbaca mengulang teks
  /// tempelan, padahal jerawat di dagu, hidung, dan pipi punya pemicu berbeda
  /// dan pengguna membacanya sebagai tiga temuan berbeda. Kunci mengikuti nama
  /// area di `AppStrings.region`: dahi, pipi kiri, pipi kanan, hidung, dagu.
  static const Map<String, String> acneByRegion = {
    'dahi':
        'Jerawat di dahi paling sering dipicu sebum berlebih dan sisa produk '
            'rambut yang menempel. Jaga garis rambut tetap bersih.',
    'hidung':
        'Jerawat di hidung umumnya komedo dan pori tersumbat, karena pori di '
            'area ini paling besar dan paling banyak memproduksi minyak.',
    'dagu':
        'Jerawat di dagu sering dikaitkan perubahan hormon dan biasanya muncul '
            'berkelompok menjelang siklus bulanan.',
    'pipi kiri':
        'Jerawat di pipi kiri bisa berasal dari sarung bantal, tangan, atau '
            'ponsel yang menempel. Rutin ganti sarung bantal membantu.',
    'pipi kanan':
        'Jerawat di pipi kanan bisa berasal dari sarung bantal, tangan, atau '
            'ponsel yang menempel. Rutin ganti sarung bantal membantu.',
  };

  /// Penjelasan jerawat yang menyesuaikan area lesi terbanyak.
  ///
  /// [regions] adalah daftar area berurutan dari yang paling sering muncul.
  /// Kalau area belum diketahui, kalimat umum di [condition] yang dipakai.
  static String acneDescription(List<String> regions) {
    for (final r in regions) {
      final t = acneByRegion[r];
      if (t != null) return t;
    }
    return condition['acne']!.$2;
  }

  /// Nama area API (`left_cheek`) -> label tampilan (`pipi kiri`).
  ///
  /// [acneByRegion] memakai huruf kecil supaya cocok dengan kunci peta; teks
  /// yang tampil ke pengguna tetap berhuruf besar di `AppStrings.region`.
  static String regionLabelOf(String api) => switch (api) {
    'forehead' => 'dahi',
    'left_cheek' => 'pipi kiri',
    'right_cheek' => 'pipi kanan',
    'nose' => 'hidung',
    'chin' => 'dagu',
    _ => 'area lain',
  };

  static const Map<String, String> skin = {
    'oily': 'kulit berminyak',
    'dry': 'kulit kering',
    'normal': 'kulit normal',
    'sensitive': 'kulit sensitif',
  };

  static const Map<String, String> active = {
    'Niacinamide':
        'Membantu mengontrol minyak, meredakan kemerahan, dan menyamarkan noda',
    'Salicylic Acid': 'BHA larut minyak yang membersihkan pori dari dalam',
    'Benzoyl Peroxide': 'Antibakteri untuk bakteri penyebab jerawat',
    'Azelaic Acid': 'Antibakteri dan anti-inflamasi, sekaligus memudarkan noda',
    'Retinol': 'Mempercepat pergantian sel dan mencegah pori tersumbat',
    'AHA': 'Eksfoliasi permukaan kulit agar tekstur lebih halus',
    'Vitamin C': 'Antioksidan yang memudarkan noda gelap',
    'Alpha Arbutin': 'Mencerahkan noda bekas jerawat',
    'Hyaluronic Acid': 'Humektan yang menarik air ke kulit',
    'Ceramide': 'Memperbaiki dan menjaga skin barrier',
    'Glycerin': 'Humektan yang menjaga kelembapan',
    'Squalane': 'Emolien ringan yang melembutkan kulit',
    'Panthenol': 'Menenangkan dan melembapkan',
    'Centella Asiatica': 'Menenangkan kulit yang meradang',
    'Zinc': 'Membantu mengontrol minyak',
    'Tea Tree': 'Antibakteri alami (bukti masih terbatas)',
    'Sunscreen Filter': 'Melindungi dari sinar UV agar noda tidak makin gelap',
  };

  static const Map<String, String> qualityMessage = {
    'no_face': 'Wajah tidak terdeteksi',
    'multiple_faces': 'Terdeteksi lebih dari satu wajah',
    'face_too_small': 'Wajah terlalu jauh dari kamera',
    'blurry': 'Foto kurang tajam',
    'too_dark': 'Foto terlalu gelap',
    'too_bright': 'Foto terlalu terang',
    'face_covered': 'Area kulit wajah tertutup (rambut, tangan, atau masker)',
  };

  static const String disclaimer =
      'Hasil ini bukan diagnosis medis. Model AFASkin bisa salah; konsultasikan '
      'ke dokter kulit untuk jerawat parah, kista, atau perubahan tahi lalat.';
}
