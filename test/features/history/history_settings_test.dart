import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/config/app_info.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/history/history_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';

final _base = AnalysisResult.fromJson(
  jsonDecode(File('assets/mock/analyze_success.json').readAsStringSync())
      as Map<String, dynamic>,
);

AnalysisResult _entry(
  String id,
  DateTime at,
  double blackhead, {
  SkinType? type,
}) => _base.copyWith(
  analysisId: id,
  createdAt: at,
  skinType: _base.skinType.copyWith(label: type ?? SkinType.oily),
  conditions: [_base.conditions.first.copyWith(probability: blackhead)],
);

MemoryHistoryStore _history() => MemoryHistoryStore()
  ..items['c'] = _entry(
    'c',
    DateTime(2026, 10, 8, 9),
    0.83,
    type: SkinType.normal,
  )
  ..items['b'] = _entry('b', DateTime(2026, 10, 22, 9), 0.76)
  ..items['a'] = _entry('a', DateTime(2026, 11, 5, 9, 30), 0.71);

Future<({MemoryHistoryStore history, MemoryFlagStore flags})> _openTab(
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
    size: const Size(390, 1000),
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tab).last);
  await tester.pumpAndSettle();
  return (history: h, flags: stores.flags);
}

void main() {
  test('conditionTrend follows the latest main condition, oldest first', () {
    final items = _history().readAll();
    final t = conditionTrend(items)!;
    expect(t.label, SkinConditionLabel.blackhead);
    expect(t.points.map((p) => p.$2), [0.83, 0.76, 0.71]);
    expect(conditionTrend(items.take(1).toList()), isNull);
  });

  group('History', () {
    testWidgets('trend card and list, newest first', (tester) async {
      await _openTab(tester, 'Riwayat');
      expect(
        find.text('Turun 12% sejak 8 Okt. Alfa ikut senang!'),
        findsOneWidget,
      );
      final newY = tester
          .getTopLeft(find.text('5 Nov 2026 · Komedo hitam 71%'))
          .dy;
      final oldY = tester
          .getTopLeft(find.text('8 Okt 2026 · Komedo hitam 83%'))
          .dy;
      expect(newY, lessThan(oldY));
      expect(find.text('Berminyak · 78%'), findsNWidgets(2));
      expect(find.text('Normal · 78%'), findsOneWidget);
      expect(
        find.text('Riwayat hanya tersimpan di ponsel ini.'),
        findsOneWidget,
      );
    });

    testWidgets('swipe to delete, with undo', (tester) async {
      final s = await _openTab(tester, 'Riwayat');
      await tester.drag(
        find.text('8 Okt 2026 · Komedo hitam 83%'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(s.history.items.keys, isNot(contains('c')));
      expect(find.text('Riwayat dihapus.'), findsOneWidget);
      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();
      expect(s.history.items.keys, contains('c'));
    });

    testWidgets('opening an entry shows its stored result', (tester) async {
      await _openTab(tester, 'Riwayat');
      await tester.tap(find.text('8 Okt 2026 · Komedo hitam 83%'));
      await tester.pumpAndSettle();
      expect(find.text('Hasil analisis'), findsOneWidget);
      expect(find.text('Normal'), findsWidgets);
    });

    testWidgets('empty state with sleepy Alfa', (tester) async {
      await _openTab(tester, 'Riwayat', history: MemoryHistoryStore());
      expect(find.text('Belum ada riwayat'), findsOneWidget);
      expect(find.text('Mulai analisis'), findsOneWidget);
    });
  });

  group('Home', () {
    testWidgets('last result, reminder and re-analyze sheet', (tester) async {
      await _openTab(tester, 'Analisis');
      expect(find.text('Analisis ulang'), findsOneWidget);
      expect(find.textContaining('Terakhir 5 Nov 2026'), findsOneWidget);
      expect(find.text('Hasil terakhir'), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('Pengingat analisis berikutnya: 19 Nov 2026'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );

      await tapVisible(tester, find.text('Mulai analisis'));
      expect(find.text('Langsung ambil foto'), findsOneWidget);
      expect(find.text('Perbarui jawaban dulu'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('profile line, reminder toggle, budget sheet', (tester) async {
      final s = await _openTab(tester, 'Pengaturan');
      expect(find.text('Rani · 21 tahun · Perempuan'), findsOneWidget);
      expect(find.text('Semua harga'), findsOneWidget);

      await tapVisible(tester, find.text('Pengingat analisis ulang'));
      expect(s.flags.reminderOn, isFalse);

      await tapVisible(tester, find.text('Budget per produk'));
      await tapVisible(tester, find.text('Maks Rp100.000'));
      expect(s.flags.budgetFilterOn, isTrue);
      expect(find.text('Rp100.000'), findsOneWidget);
    });

    testWidgets('clear history asks first, counts entries', (tester) async {
      final s = await _openTab(tester, 'Pengaturan');
      await tapVisible(tester, find.text('Hapus semua riwayat'));
      expect(
        find.text(
          '3 hasil analisis akan dihapus dari ponsel ini dan tidak bisa '
          'dikembalikan.',
        ),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Batal'));
      expect(s.history.items, hasLength(3));

      await tapVisible(tester, find.text('Hapus semua riwayat'));
      await tapVisible(tester, find.text('Hapus'));
      expect(s.history.items, isEmpty);
    });

    testWidgets('clear all local data returns to onboarding', (tester) async {
      final s = await _openTab(tester, 'Pengaturan');
      await tapVisible(tester, find.text('Hapus semua data lokal'));
      expect(find.text('Hapus semua data lokal?'), findsOneWidget);
      await tapVisible(tester, find.text('Hapus'));
      expect(find.text('Kenali kulitmu dari satu foto'), findsOneWidget);
      expect(s.history.items, isEmpty);
    });

    testWidgets('consent review is read-only', (tester) async {
      await _openTab(tester, 'Pengaturan');
      await tapVisible(tester, find.text('Persetujuan & disclaimer'));
      expect(
        find.text('Kamu sudah menyetujui kedua poin ini.'),
        findsOneWidget,
      );
      expect(find.text('Afa Skin bukan alat medis'), findsOneWidget);
    });

    testWidgets('About shows version, team and dataset attribution', (
      tester,
    ) async {
      await _openTab(tester, 'Pengaturan', scale: 1.3);
      await tapVisible(tester, find.text('Tentang Afa Skin'));
      expect(find.text('Versi ${AppInfo.version}'), findsOneWidget);
      await waitFor(tester, find.text('Model: mock-2026.11'));
      await tester.dragUntilVisible(
        find.textContaining('CC BY 4.0'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      expect(find.textContaining('Roboflow Universe'), findsOneWidget);
      expect(find.textContaining('Kaggle'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
