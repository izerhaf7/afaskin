import 'dart:typed_data';
import 'dart:ui';

import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/features/capture/photo_adjust_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// PNG 1x1 valid: halaman men-decode ukuran dari byte, jadi harus gambar asli.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB4, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('menampilkan panduan, tombol, dan mengembalikan hasil crop', (
    tester,
  ) async {
    Rect? cropped;
    int? usedTarget;
    Uint8List? returned;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              returned = await Navigator.of(context).push<Uint8List>(
                MaterialPageRoute<Uint8List>(
                  builder: (_) => PhotoAdjustPage(
                    bytes: _png,
                    decodeSize: (_) async => const Size(400, 600),
                    onCrop: (raw, rect, {int target = 1200}) async {
                      cropped = rect;
                      usedTarget = target;
                      return Uint8List.fromList([7, 7, 7]);
                    },
                  ),
                ),
              );
            },
            child: const Text('buka'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    // Judul, penjelasan, dan kedua tombol ada.
    expect(find.text('Atur posisi'), findsOneWidget);
    expect(find.textContaining('Geser dan cubit'), findsOneWidget);
    expect(find.text('Gunakan foto ini'), findsOneWidget);
    expect(find.text('Kembalikan'), findsOneWidget);

    await tester.tap(find.text('Gunakan foto ini'));
    await tester.pumpAndSettle();

    expect(returned, isNotNull);
    expect(returned, [7, 7, 7]);
    // Crop persegi: lebar dan tinggi sama, dan tidak keluar dari gambar.
    expect(cropped, isNotNull);
    expect(cropped!.width, closeTo(cropped!.height, 1.0));
    expect(cropped!.left, greaterThanOrEqualTo(0));
    expect(cropped!.top, greaterThanOrEqualTo(0));
    expect(cropped!.right, lessThanOrEqualTo(400.5));
    expect(cropped!.bottom, lessThanOrEqualTo(600.5));
    // Foto 400x600 di jendela persegi: crop 400x400 di tengah vertikal.
    expect(cropped!.width, closeTo(400, 1.0));
    expect(cropped!.top, closeTo(100, 1.0));
    expect(usedTarget, 400);
  });

  testWidgets('gambar gagal dibaca: pesan muncul, tombol gunakan nonaktif', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PhotoAdjustPage(
          bytes: _png,
          decodeSize: (_) async => throw const FormatException('rusak'),
          onCrop: (raw, rect, {int target = 1200}) async => raw,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foto tidak bisa dibaca. Coba foto lain.'), findsOneWidget);
    // onPressed null = tombol nonaktif, jadi tidak bisa menekan apa pun.
    final button = tester.widget<AfaButton>(
      find.ancestor(
        of: find.text('Gunakan foto ini'),
        matching: find.byType(AfaButton),
      ).first,
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('crop gagal: pesan kesalahan tampil, tidak menutup halaman', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PhotoAdjustPage(
          bytes: _png,
          decodeSize: (_) async => const Size(300, 300),
          onCrop: (raw, rect, {int target = 1200}) async =>
              throw const FormatException('gagal'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gunakan foto ini'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memotong foto. Coba pilih foto lain.'), findsOneWidget);
    expect(find.text('Gunakan foto ini'), findsOneWidget);
  });
}
