import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('AfaButton taps, disables, and blocks taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(AfaButton(label: 'Lanjut', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Lanjut'));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.pumpWidget(
      _wrap(const AfaButton(label: 'Lanjut', onPressed: null)),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );

    await tester.pumpWidget(
      _wrap(AfaButton(label: 'Lanjut', loading: true, onPressed: () => taps++)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
  });

  testWidgets('AfaButton.secondary renders an OutlinedButton', (tester) async {
    await tester.pumpWidget(
      _wrap(AfaButton.secondary(label: 'Galeri', onPressed: () {})),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('AfaCard reports selection to semantics and taps', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        AfaCard(
          selected: true,
          onTap: () => tapped = true,
          child: const Text('3'),
        ),
      ),
    );
    await tester.tap(find.text('3'));
    expect(tapped, isTrue);
    expect(
      tester.getSemantics(find.byType(AfaCard)),
      isSemantics(
        isButton: true,
        isSelected: true,
        hasTapAction: true,
        label: '3',
      ),
    );
  });

  testWidgets('interactive AfaChip has a 48dp touch target', (tester) async {
    await tester.pumpWidget(_wrap(AfaChip(label: 'Serum', onTap: () {})));
    final size = tester.getSize(find.byType(InkWell));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });

  test('QuatrefoilPath fills the requested rect', () {
    final b = QuatrefoilPath.inRect(const Rect.fromLTWH(10, 20, 100, 100))
        .getBounds();
    expect(b.left, closeTo(10, 0.5));
    expect(b.top, closeTo(20, 0.5));
    expect(b.width, closeTo(100, 0.5));
    expect(b.height, closeTo(100, 0.5));
    // The "waist" between lobes is indented: the middle of the top edge is
    // outside the shape, the center is inside.
    final p = QuatrefoilPath.inRect(const Rect.fromLTWH(0, 0, 100, 100));
    expect(p.contains(const Offset(50, 2)), isFalse);
    expect(p.contains(const Offset(50, 50)), isTrue);
  });

  testWidgets('QuatrefoilLoader is static when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _wrap(const QuatrefoilLoader()),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });
}
