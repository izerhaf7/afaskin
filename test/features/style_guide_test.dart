import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/features/style_guide/style_guide_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('style guide renders on a small phone at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: const StyleGuidePage(),
        ),
      );
      await tester.pump();

      // Scroll through the whole page; any overflow throws and fails the test.
      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 12; i++) {
        await tester.drag(list, const Offset(0, -400));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
