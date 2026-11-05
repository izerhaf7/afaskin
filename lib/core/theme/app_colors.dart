import 'package:material_ui/material_ui.dart';

/// "Copal" palette. The only place in the app where hex colors are written.
///
/// Contrast rules (WCAG 2.1, see `test/core/theme/contrast_test.dart`):
/// - [ink] on [white]/[mist]: any text.
/// - [white] on [ink]: any text, including primary button labels.
/// - [sage] on [white]: only text >= 24sp, icons and borders.
/// - [sage] on [mist]: decoration only, never text.
/// - [white] on [sage]: only icons or text >= 24sp, never button labels.
/// - [danger]/[caution]/[positive] on [white]/[mist]: status text.
abstract final class AppColors {
  // Brand.
  static const Color mist = Color(0xFFE3F0ED);
  static const Color sage = Color(0xFF7B9891);
  static const Color ink = Color(0xFF2B3B4B);
  static const Color white = Color(0xFFFFFFFF);

  // Derived.
  static const Color outline = Color(0xFFC8D1D9);
  static const Color danger = Color(0xFFA8483B);
  static const Color caution = Color(0xFF8A5A12);
  static const Color positive = Color(0xFF3E6B5E);

  /// Light sage wash for selected chips/cards. Ink text on it stays > 8:1.
  static final Color sageTint = Color.alphaBlend(
    sage.withValues(alpha: 0.20),
    white,
  );

  /// 10% tint of a status color over white. The status color itself keeps
  /// >= 4.9:1 on this background, so it is safe for status text.
  static Color statusTint(Color status) =>
      Color.alphaBlend(status.withValues(alpha: 0.10), white);

  /// Shadow color: ink at ~7% opacity.
  static final Color shadow = ink.withValues(alpha: 0.07);

  /// Scrim behind sheets/dialogs.
  static final Color scrim = ink.withValues(alpha: 0.40);

  /// Disabled foreground (text/icon) on disabled [outline] fill.
  static final Color disabledForeground = ink.withValues(alpha: 0.60);
}
