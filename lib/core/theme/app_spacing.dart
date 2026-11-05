import 'package:afaskin/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Spacing scale: multiples of 4.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Default horizontal page padding.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: md);

  /// Minimum touch target (accessibility).
  static const double minTouchTarget = 48;
}

/// Corner radii.
abstract final class AppRadius {
  static const double card = 20;
  static const double input = 14;
  static const double pill = 999;
  static const double sheet = 28;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Minimal elevation: a soft ink shadow instead of Material elevation.
abstract final class AppShadows {
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
