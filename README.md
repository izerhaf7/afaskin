# Afa Skin

Aplikasi Flutter: analisis kondisi kulit dari selfie + rekomendasi skincare
berbasis bahan aktif. Proyek Pembelajaran Mesin, Kelompok 3, Kelas A, TRK,
Sekolah Vokasi IPB.

**Status: Fase 0 (fondasi) selesai.** Berikutnya: Fase 1 (onboarding).

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
