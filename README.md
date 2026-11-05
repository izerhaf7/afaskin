# Afa Skin

Aplikasi Flutter: analisis kondisi kulit dari selfie + rekomendasi skincare.

**Status: Fase 0 (fondasi) — belum selesai (WIP).**

Sudah ada: proyek Flutter 3.47 (Android minSdk 24), package, design system
(`lib/core/theme/`), string UI, lapisan network (dio + error mapping), model
freezed, aset brand (logo dipangkas + varian gelap), font, file mock JSON.

Belum: repository interface + mock, komponen (`AfaButton`, `AfaCard`,
`QuatrefoilShape`, `AfaChip`), router, halaman style guide, `main.dart`, test.

Catatan: file font Etna belum ada, sementara dipakai League Spartan Bold (OFL)
di `assets/fonts/etna/`. Ganti path di `pubspec.yaml` jika file Etna tersedia.

```bash
flutter pub get
dart run build_runner build
```
