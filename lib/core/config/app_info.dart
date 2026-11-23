/// Static app information for the About page.
abstract final class AppInfo {
  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.1.0';

  static const String course = 'Pembelajaran Mesin';
  static const String team =
      'Kelompok 3 · Kelas A · Teknologi Rekayasa Komputer, Sekolah Vokasi IPB';

  static const List<(String, String)> members = [
    ('Alessy Milandra Fahrezi', 'J0404241016'),
    ('Alya Shalika', 'J0404241121'),
    ('Fauzan Aziz', 'J0404241129'),
  ];

  /// Satu baris ringkas di bagian atas kartu status model.
  static const String modelSummary =
      '3 model berjalan on-device · TensorFlow Lite · tanpa server';

  /// Tabel ringkas: tugas, model, dan hasil uji. Angka dari split uji, bukan
  /// perkiraan. Kondisi kulit dari
  /// `outputs/condition_v31/hardneg/ft_repaired/metrik_relabel.json` (n=23.282),
  /// tipe kulit dari `outputs/fusion/test_deployed.csv` (n=133), rekomendasi
  /// dari `outputs/recommender_local/recommender_info.json`.
  static const List<(String, String, String)> modelTable = [
    ('Klasifikasi tipe kulit', 'ResNet50 + kuesioner', '83,6% akurasi'),
    ('Klasifikasi kondisi kulit', 'ResNet50 latih ulang', '83,2% akurasi'),
    ('Rekomendasi produk', 'Random Forest + Linear SVM', 'P@10 0,63'),
  ];

  /// Label kolom tabel status model.
  static const String tableTaskHeader = 'Tugas';
  static const String tableModelHeader = 'Model';
  static const String tableMetricHeader = 'Hasil uji';

  /// Penjelasan deteksi wajah, ditampilkan di bawah tabel.
  static const String faceDetectionTitle = 'Deteksi wajah';

  static const String faceDetectionBody =
      'Google ML Kit Face Mesh membaca 468 titik wajah untuk menentukan posisi '
      'dahi, pipi, hidung dan dagu. Bila Face Mesh menolak foto, aplikasi '
      'memotong wajah dengan margin 55 persen, memperbesar potongan ke rasio '
      'potret 3 banding 4 berukuran 480 kali 640 piksel, lalu mendeteksi ulang '
      'memakai Face Detector. Langkah kedua ini perlu karena wajah yang jelas '
      'terlihat sering ditolak bukan karena wajahnya tidak ada, melainkan '
      'karena pembingkaiannya dianggap tidak lazim. Seluruh proses berjalan di '
      'perangkat, foto tidak pernah dikirim ke server.';

  /// Catatan singkat di bawah tabel.
  static const String modelFooter =
      'Angka adalah hasil evaluasi pada data uji, bukan perkiraan. Keyakinan '
      'yang tampil ke pengguna sudah dikalibrasi, dengan ECE 0,021 dan Brier '
      '0,050. Nilainya dibatasi 1 sampai 99 persen karena model tidak pernah '
      'benar-benar pasti.';
}
