import 'package:material_ui/material_ui.dart';

import 'package:afaskin/core/theme/app_colors.dart';

/// Type scale. The only place in the app where font families are named.
///
/// - Etna: headings, big numbers, button labels.
/// - Belleza: body text. It ships a single Regular weight, so every Belleza
///   style is pinned to [FontWeight.w400]. Never make it bold (Flutter would
///   synthesize an ugly faux bold); emphasize with Ink color or switch to Etna.
abstract final class AppTypography {
  static const String display = 'Etna';
  static const String body = 'Belleza';

  // Etna is also a single-weight face: its letterforms are already heavy, so
  // it is used at w400 to avoid synthetic bolding as well.
  static TextStyle _etna(double size, double lineHeight, {double ls = 0}) =>
      TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w400,
        fontSize: size,
        height: lineHeight / size,
        letterSpacing: ls,
        color: AppColors.ink,
      );

  static TextStyle _belleza(double size, double lineHeight) => TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: 0,
    color: AppColors.ink,
  );

  /// Full M3 text theme. Styles not in the brief (display M/S, headline L/S,
  /// title S, label M/S) are filled in so no Material default font leaks in.
  static final TextTheme textTheme = TextTheme(
    displayLarge: _etna(32, 40),
    displayMedium: _etna(28, 36),
    displaySmall: _etna(26, 34),
    headlineLarge: _etna(26, 34),
    headlineMedium: _etna(24, 32),
    headlineSmall: _etna(22, 30),
    titleLarge: _etna(20, 28),
    titleMedium: _etna(16, 24),
    titleSmall: _etna(14, 20),
    labelLarge: _etna(16, 20, ls: 0.2),
    labelMedium: _etna(14, 20, ls: 0.2),
    labelSmall: _etna(12, 16, ls: 0.2),
    bodyLarge: _belleza(16, 24),
    bodyMedium: _belleza(14, 22),
    bodySmall: _belleza(12, 18),
  );
}
