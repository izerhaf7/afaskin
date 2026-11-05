import 'dart:convert';
import 'dart:io';

import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';

final _base = AnalysisResult.fromJson(
  jsonDecode(File('assets/mock/analyze_success.json').readAsStringSync())
      as Map<String, dynamic>,
);

MemoryHistoryStore _history() => MemoryHistoryStore()
  ..items['old'] = _base.copyWith(
    analysisId: 'old',
    createdAt: DateTime(2026, 10, 1, 8, 5),
    skinType: _base.skinType.copyWith(label: SkinType.dry),
  )
  ..items['new'] = _base.copyWith(
    analysisId: 'new',
    createdAt: DateTime(2026, 11, 5, 9, 30),
  );

Future<MemoryHistoryStore> _openTab(
  WidgetTester tester,
  String tab, {
  MemoryHistoryStore? history,
  double scale = 1,
}) async {
  final stores = setupDoneStores();
  final h = history ?? _history();
  await pumpApp(
    tester,
    flags: stores.flags,
    user: stores.user,
    history: h,
    textScale: scale,
  );
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tab).last);
  await tester.pumpAndSettle();
  return h;
}

void main() {
  group('History', () {
    testWidgets('lists newest first with date, skin type, main condition', (
      tester,
    ) async {
      await _openTab(tester, 'Riwayat');
      final newY = tester.getTopLeft(find.text('5 Nov 2026, 09.30')).dy;
      final oldY = tester.getTopLeft(find.text('1 Okt 2026, 08.05')).dy;
      expect(newY, lessThan(oldY));
      expect(find.text('Berminyak · 78%'), findsOneWidget);
      expect(find.text('Kering · 78%'), findsOneWidget);
      expect(find.text('Komedo hitam (71%)'), findsNWidgets(2));
    });

    testWidgets('delete one with undo', (tester) async {
      final h = await _openTab(tester, 'Riwayat');
      await tester.tap(find.byTooltip('Hapus riwayat 5 Nov 2026, 09.30'));
      await tester.pumpAndSettle();
      expect(h.items.keys, ['old']);
      expect(find.text('Riwayat dihapus.'), findsOneWidget);

      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();
      expect(h.items.keys, containsAll(['old', 'new']));
    });

    testWidgets('swipe to delete', (tester) async {
      final h = await _openTab(tester, 'Riwayat');
      await tester.drag(find.text('1 Okt 2026, 08.05'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(h.items.keys, ['new']);
    });

    testWidgets('clear all asks first', (tester) async {
      final h = await _openTab(tester, 'Riwayat');
      await tester.tap(find.byTooltip('Hapus semua riwayat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(h.items, hasLength(2));

      await tester.tap(find.byTooltip('Hapus semua riwayat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(h.items, isEmpty);
      expect(find.text('Belum ada riwayat'), findsOneWidget);
    });

    testWidgets('opening an entry shows its stored result', (tester) async {
      await _openTab(tester, 'Riwayat');
      await tester.tap(find.text('1 Okt 2026, 08.05'));
      await tester.pumpAndSettle();
      expect(find.text('Hasil analisis'), findsOneWidget);
      expect(find.text('Kering'), findsWidgets);
    });
  });

  group('Settings', () {
    testWidgets('clear all local data returns to onboarding', (tester) async {
      final h = await _openTab(tester, 'Pengaturan');
      expect(find.textContaining('Sampai Rp150.000'), findsOneWidget);

      await tester.tap(find.text('Hapus semua data lokal'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus semua data lokal?'), findsOneWidget);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Kenali kulitmu'), findsOneWidget);
      expect(h.items, isEmpty);
    });

    testWidgets('About shows version, team and dataset attribution', (
      tester,
    ) async {
      await _openTab(tester, 'Pengaturan', scale: 1.3);
      await tapVisible(tester, find.text('Tentang'));
      expect(find.text('Tentang Afa Skin'), findsOneWidget);
      expect(find.text('Versi 0.1.0'), findsOneWidget);
      await waitFor(tester, find.text('Model: mock-2026.11'));
      await tester.dragUntilVisible(
        find.textContaining('CC BY 4.0'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      expect(find.textContaining('Roboflow Universe'), findsOneWidget);
      expect(find.textContaining('Kaggle'), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('Lisensi open source'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      expect(find.textContaining('Apache 2.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
