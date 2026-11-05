# Afa Skin

Aplikasi Flutter: analisis kondisi kulit dari selfie + rekomendasi skincare
berbasis bahan aktif. Proyek Pembelajaran Mesin, Kelompok 3, Kelas A, TRK,
Sekolah Vokasi IPB.

**Status: Fase 2 (kamera) selesai.** Berikutnya: Fase 3 (hasil & rekomendasi).

Alur: splash → onboarding (3 halaman) → persetujuan → profil → kuesioner →
bottom nav (Analisis, Riwayat, Pengaturan). Router menjaga urutan setup,
jadi persetujuan tidak bisa dilewati. Flag disimpan di SharedPreferences,
profil & jawaban kuesioner di Hive (box `user`).

## Menjalankan

```bash
flutter pub get
flutter run                                   # mode mock (default)
flutter run --dart-define=MOCK_SCENARIO=quality_fail
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.example.com
```

Setelah mengubah model / provider: `dart run build_runner build`.
Di build debug, style guide bisa dibuka dari halaman awal (`/dev/style-guide`).

## Struktur

```
lib/
  app.dart, main.dart
  core/
    config/env.dart        # --dart-define: API_BASE_URL, USE_MOCK, MOCK_SCENARIO
    theme/                 # SATU-SATUNYA tempat warna & font ditulis
    l10n/app_strings.dart  # semua string UI (Bahasa Indonesia)
    network/               # dio client, retry, mapping error -> Failure
    router/                # go_router
    widgets/               # AfaButton, AfaCard, AfaChip, QuatrefoilShape, AfaLogo
  data/
    models/                # freezed, sesuai kontrak API
    repositories/          # interface + mock + api, dipilih lewat Riverpod
  features/
    dev/, style_guide/     # placeholder Fase 0 + style guide (debug only)
assets/
  brand/   fonts/   mock/
```

## Kamera (Fase 2)

- Kamera depan + oval panduan. ML Kit (tiap 3 frame) hanya untuk panduan:
  wajah terdeteksi, di dalam oval, jarak pas, yaw/pitch ±15°, cukup terang
  (rata-rata luma frame). Tombol shutter aktif hanya jika semua terpenuhi.
  Ambang batas ada di `GuidanceConfig` (`lib/features/capture/face_guidance.dart`)
  dan perlu disetel di HP asli.
- Sebelum upload: orientasi EXIF diterapkan, semua metadata dihapus, sisi
  terpanjang ≤ 1080 px, JPEG q85. Foto hanya di memori; file temp kamera &
  galeri langsung dihapus.
- Izin: layar penjelasan dulu, baru dialog sistem; jika ditolak permanen,
  tombol ke pengaturan HP. Pilih dari galeri selalu tersedia.
- Package tambahan di luar daftar brief: `image_picker` (galeri) dan
  `permission_handler` (status ditolak permanen + buka pengaturan HP).
- iOS: tambahkan makro `PERMISSION_CAMERA=1` di `ios/Podfile` sesuai
  dokumentasi permission_handler saat build iOS.

## Catatan

- **Material dipisah dari SDK** di Flutter 3.47: import pakai
  `package:material_ui/material_ui.dart`, bukan `package:flutter/material.dart`.
- **Font Etna belum ada.** Sementara dipakai League Spartan Bold (OFL) di
  `assets/fonts/etna/`. Taruh file Etna di folder itu, lalu ganti satu baris
  path di `pubspec.yaml`.
- Logo SVG asli berisi seluruh brand board (106 KB). `assets/brand/` berisi
  versi yang sudah dipangkas ke wordmark saja (5 KB) + varian latar gelap.
- Lint: `very_good_analysis`. `unnecessary_type_name_in_constructor` dimatikan
  agar model tetap memakai gaya freezed klasik.
