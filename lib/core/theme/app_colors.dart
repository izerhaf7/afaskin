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

  // Tahap 2 design tokens.

  /// Secondary text. 6.2:1 on white, 5.3:1 on mist: fine for body text.
  static const Color inkMuted = Color(0xFF56636F);

  /// Pressed state of ink buttons.
  static const Color inkPressed = Color(0xFF1D2935);

  /// Disabled button fill; label uses [disabledForeground].
  static const Color disabledFill = Color(0xFFD5DCE2);

  /// Disabled label (exempt from WCAG contrast as an inactive control).
  static const Color disabledForeground = inkMuted;

  /// Match badge / matched ingredient background ([positive] text: 5.0:1).
  static const Color positiveTint = Color(0xFFE0EDE8);

  /// Conflict banner background ([danger] text: 4.7:1, ink body: 9.4:1).
  static const Color dangerTint = Color(0xFFF6E4E1);

  /// Pressed state on mist surfaces.
  static const Color mistPressed = Color(0xFFD3E4DF);

  /// Second stripe of the product-photo placeholder pattern.
  static const Color mistStripe = Color(0xFFD7E7E3);

  /// Scrim behind bottom sheets.
  static const Color sheetScrim = Color(0x730E141B);
}

/// Colors of Alfa, the axolotl mascot (from the design's Mascot component).
abstract final class AlfaPalette {
  static const Color gillDark = Color(0xFF5E7B74);
  static const Color gillMid = Color(0xFF6A8780);
  static const Color gillLight = Color(0xFF8EAAA3);
  static const Color gillPale = Color(0xFFA9C2BB);
  static const Color body = Color(0xFFB9D0CA);
  static const Color bodyLight = Color(0xFFD6E7E2);
  static const Color belly = Color(0xFFF4F1EA);
  static const Color headLight = Color(0xFFEAF4F1);
  static const Color headShade = Color(0xFFBFD5CF);
  static const Color blush = Color(0xFFEBB7AB);
}
