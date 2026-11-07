/// Teks hasil analisis & rekomendasi (Bahasa Indonesia), dipakai engine ML lokal.
abstract final class MlTexts {
  /// label API -> (nama singkat, deskripsi)
  static const Map<String, (String, String)> condition = {
    'acne': ('jerawat', 'Jerawat ringan akibat peradangan pada folikel rambut.'),
    'birthmark': (
      'tanda lahir',
      'Tanda lahir atau tahi lalat. Bukan masalah skincare; periksakan ke '
          'dokter bila bentuk atau warnanya berubah.',
    ),
    'blackhead': ('komedo hitam', 'Komedo terbuka akibat pori tersumbat sebum.'),
    'cysts': (
      'jerawat kistik',
      'Jerawat besar yang dalam dan nyeri. Sebaiknya ditangani dokter kulit.',
    ),
    'milium': (
      'milia',
      'Benjolan putih kecil berisi keratin, sering muncul di sekitar mata dan pipi.',
    ),
    'papular': (
      'papula',
      'Benjolan kecil kemerahan tanpa nanah, tanda pori meradang.',
    ),
    'purulent': (
      'pustula',
      'Jerawat bernanah akibat infeksi bakteri di pori. Jangan dipencet.',
    ),
    'scars': (
      'bekas jerawat',
      'Noda gelap atau tekstur tidak rata yang tertinggal setelah jerawat sembuh.',
    ),
    'whitehead': (
      'komedo putih',
      'Komedo tertutup: sumbatan pori yang tertutup lapisan kulit tipis.',
    ),
    'clear': ('kulit bersih', 'Tidak terlihat masalah kulit yang menonjol.'),
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
