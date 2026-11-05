# Afa Skin

Aplikasi Flutter yang menganalisis kondisi kulit wajah dari foto selfie dan
merekomendasikan skincare berdasarkan kecocokan bahan aktif. Proyek mata
kuliah Pembelajaran Mesin, Kelompok 3, Kelas A, Teknologi Rekayasa Komputer,
Sekolah Vokasi IPB.

**Status:** Fase 0–5 selesai di sisi aplikasi. Yang tersisa butuh dunia
nyata: backend FastAPI asli, uji di HP Android fisik, dan build APK di mesin
yang punya Android SDK (atau lewat GitHub Actions, lihat di bawah).

Inferensi ML berjalan **di server**. Aplikasi memandu pengambilan foto,
mengirim foto + profil + kuesioner, lalu menampilkan hasil dan rekomendasi.

## Menjalankan

Butuh Flutter 3.47 (Dart 3.13).

```bash
flutter pub get
flutter run                                         # mode mock (default)
flutter run --dart-define=MOCK_SCENARIO=quality_fail
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

| `--dart-define` | Default | Arti |
|---|---|---|
| `USE_MOCK` | `true` | Baca respons dari `assets/mock/` |
| `API_BASE_URL` | `http://10.0.2.2:8000` | Root backend (tanpa `/api/v1`). `10.0.2.2` = laptop dilihat dari emulator |
| `MOCK_SCENARIO` | `success` | `quality_fail` → `/analyze` mengembalikan 422 |

Setelah mengubah model / provider: `dart run build_runner build`.
Di build debug, style guide ada di Pengaturan → Buka style guide.

## Cek & test

```bash
flutter analyze
flutter test
```

Uji kontrak ke backend yang sedang berjalan (asli atau mock server):

```bash
AFASKIN_API=http://127.0.0.1:8000 flutter test test/integration
```

## Mock server (sebelum backend asli siap)

`tools/mock_server` adalah FastAPI kecil yang menyajikan kontrak yang sama
dari `assets/mock/`, tanpa model. Berguna untuk uji di HP dengan
`USE_MOCK=false`.

```bash
cd tools/mock_server
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

HP dan laptop harus di Wi-Fi yang sama; jalankan app dengan
`API_BASE_URL=http://<IP-laptop>:8000` (build debug mengizinkan HTTP).

## Build APK release

Build release **wajib HTTPS** untuk `API_BASE_URL` (kalau tidak, app
menolak memakai server). Untuk demo tanpa server, pakai mode mock.

```bash
flutter build apk --release --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.contoh.id
flutter build apk --release --dart-define=USE_MOCK=true   # demo offline
```

Penandatanganan: buat `android/key.properties` (lihat komentar di
`android/app/build.gradle.kts`). Tanpa file itu, release memakai debug key
(cukup untuk demo, tidak untuk Play Store). Jangan commit keystore.

**GitHub Actions** (`.github/workflows/android.yml`) menjalankan analyze,
test, dan build APK release di setiap push, lalu mengunggah APK sebagai
artifact. Isi variabel repository `API_BASE_URL` agar APK memakai backend
asli; tanpa itu APK berjalan dalam mode mock.

## Checklist uji di HP fisik

- [ ] Onboarding → persetujuan → profil → kuesioner berjalan, bisa dilanjut setelah app ditutup.
- [ ] Izin kamera: layar penjelasan muncul dulu; tolak permanen → tombol ke pengaturan HP.
- [ ] Panduan kamera: pesan berganti sesuai posisi/cahaya; shutter aktif hanya saat "Pas!". Setel ambang di `GuidanceConfig` bila perlu.
- [ ] Preview kamera terasa lancar (target ≥ 24 fps).
- [ ] Foto dari galeri bisa dianalisis.
- [ ] Foto gelap/buram ditolak server → alasan tampil → kembali ke kamera.
- [ ] Mode pesawat saat analisis → pesan jaringan + "Coba lagi".
- [ ] Hasil, peta wajah, rekomendasi + filter, detail produk + peringatan konflik.
- [ ] Riwayat tersimpan tanpa foto; hapus satu/semua; hapus semua data → kembali ke onboarding.
- [ ] Ukuran teks sistem 130%: tidak ada teks terpotong.

## Struktur

```
lib/
  app.dart, main.dart
  core/
    config/      env.dart (--dart-define), app_info.dart (versi, anggota)
    theme/       SATU-SATUNYA tempat warna & font ditulis
    l10n/        semua string UI (Bahasa Indonesia)
    network/     dio client, retry GET, mapping error -> Failure
    router/      go_router + penjaga urutan setup
    session/     status onboarding/persetujuan/profil/kuesioner
    widgets/     AfaButton, AfaCard, AfaChip, QuatrefoilShape, state views
  data/
    models/      freezed, sesuai kontrak API
    repositories/ interface + mock + api (dipilih lewat USE_MOCK)
    local/       SharedPreferences (flag) + Hive (profil, riwayat)
  features/
    splash, onboarding, consent, profile, questionnaire,
    capture (kamera + ML Kit + kompresi), analysis (menganalisis, hasil,
    peta wajah), recommendation, history, settings, about, style_guide
assets/  brand/  fonts/  mock/
tools/mock_server/   FastAPI mock sesuai kontrak
```

## Catatan

- **Material dipisah dari SDK** di Flutter 3.47: import pakai
  `package:material_ui/material_ui.dart`, bukan `package:flutter/material.dart`.
- **Font Etna belum ada.** Sementara dipakai League Spartan Bold (OFL) di
  `assets/fonts/etna/`. Taruh file Etna di folder itu, ganti satu baris path
  di `pubspec.yaml`, lalu perbarui atribusi di `AppStrings.attributions`.
- **Isi nama anggota kelompok** di `lib/core/config/app_info.dart`.
- Logo SVG asli berisi seluruh brand board (106 KB). `assets/brand/` berisi
  versi yang dipangkas ke wordmark (5 KB) + varian latar gelap.
- Package di luar daftar brief: `image_picker` (pilih dari galeri) dan
  `permission_handler` (status ditolak permanen + buka pengaturan HP).
- Privasi: foto hanya di memori; file temp kamera/galeri langsung dihapus;
  EXIF dihapus sebelum upload; riwayat hanya menyimpan JSON hasil.
- iOS belum diuji. Saat build iOS, tambahkan makro `PERMISSION_CAMERA=1` di
  `ios/Podfile` sesuai dokumentasi permission_handler.
- Lint: `very_good_analysis`; `unnecessary_type_name_in_constructor`
  dimatikan agar model tetap memakai gaya freezed klasik.
