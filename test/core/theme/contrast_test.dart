import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/core/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG 2.1 contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Contrast table (brief section 3.3)', () {
    test('body-text pairs >= 4.5:1', () {
      expect(contrast(AppColors.ink, AppColors.white), greaterThan(11.4));
      expect(contrast(AppColors.ink, AppColors.mist), greaterThan(9.7));
      expect(contrast(AppColors.white, AppColors.ink), greaterThan(11.4));
      for (final status in [
        AppColors.danger,
        AppColors.caution,
        AppColors.positive,
      ]) {
        expect(contrast(status, AppColors.white), greaterThanOrEqualTo(4.9));
        expect(contrast(status, AppColors.mist), greaterThanOrEqualTo(4.9));
        expect(
          contrast(status, AppColors.statusTint(status)),
          greaterThanOrEqualTo(4.5),
          reason: 'status chip text on its own tint',
        );
      }
      expect(contrast(AppColors.ink, AppColors.sageTint), greaterThan(4.5));
      expect(contrast(AppColors.ink, AppColors.outline), greaterThan(4.5));
    });

    test('sage is only large-text / decorative', () {
      final sageWhite = contrast(AppColors.sage, AppColors.white);
      expect(sageWhite, inInclusiveRange(3.0, 4.5));
      expect(contrast(AppColors.sage, AppColors.mist), lessThan(3.0));
    });
  });

  group('Theme follows the rules', () {
    final theme = AppTheme.light;

    test('primary button = ink background + white label', () {
      final style = theme.filledButtonTheme.style!;
      expect(style.backgroundColor!.resolve({}), AppColors.ink);
      expect(style.foregroundColor!.resolve({}), AppColors.white);
    });

    test('secondary button = sage border + ink label', () {
      final style = theme.outlinedButtonTheme.style!;
      expect(style.side!.resolve({})!.color, AppColors.sage);
      expect(style.foregroundColor!.resolve({}), AppColors.ink);
    });

    test('no text style uses sage', () {
      final t = theme.textTheme;
      for (final s in [
        t.displayLarge,
        t.headlineMedium,
        t.titleLarge,
        t.titleMedium,
        t.labelLarge,
        t.bodyLarge,
        t.bodyMedium,
        t.bodySmall,
      ]) {
        expect(s!.color, isNot(AppColors.sage));
      }
    });

    test('Belleza is never bold; Etna/Belleza assigned per role', () {
      final t = theme.textTheme;
      for (final s in [t.bodyLarge, t.bodyMedium, t.bodySmall]) {
        expect(s!.fontFamily, AppTypography.body);
        expect(s.fontWeight, FontWeight.w400);
      }
      for (final s in [t.displayLarge, t.headlineMedium, t.labelLarge]) {
        expect(s!.fontFamily, AppTypography.display);
      }
      expect(t.bodyMedium!.fontSize, 14);
      expect(t.displayLarge!.fontSize, 32);
    });

    test('scheme is built from tokens', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.ink);
      expect(theme.colorScheme.onSurfaceVariant, AppColors.ink);
      expect(theme.scaffoldBackgroundColor, AppColors.mist);
    });
  });
}
