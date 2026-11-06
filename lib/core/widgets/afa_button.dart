import 'package:afaskin/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

enum AfaButtonVariant {
  /// Ink fill, white label. The main action on a screen.
  primary,

  /// Sage outline, ink label.
  secondary,

  /// White fill, ink label: primary action on an ink card.
  onDark,

  /// Danger fill, white label (5.8:1): destructive confirmation.
  danger,
}

/// App button. Colors and shape come from the theme
/// (`filledButtonTheme` / `outlinedButtonTheme`); this widget only picks the
/// variant and adds icon, full-width and loading support.
class AfaButton extends StatelessWidget {
  const AfaButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AfaButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
  });

  const AfaButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = true,
    this.loading = false,
  }) : variant = AfaButtonVariant.secondary;

  static ButtonStyle? _styleFor(AfaButtonVariant v) => switch (v) {
    AfaButtonVariant.onDark =>
      FilledButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
      ).copyWith(
        overlayColor: const WidgetStatePropertyAll(AppColors.mistPressed),
      ),
    AfaButtonVariant.danger => FilledButton.styleFrom(
      backgroundColor: AppColors.danger,
      foregroundColor: AppColors.white,
    ),
    _ => null,
  };

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AfaButtonVariant variant;
  final IconData? icon;
  final bool expand;

  /// Shows a spinner and blocks taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // While loading the button keeps its enabled look; taps are absorbed.
    final callback = loading ? (onPressed == null ? null : () {}) : onPressed;

    final content = loading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: switch (variant) {
                AfaButtonVariant.primary ||
                AfaButtonVariant.danger => AppColors.white,
                _ => AppColors.ink,
              },
            ),
          )
        : Text(label, textAlign: TextAlign.center);

    final filled = variant != AfaButtonVariant.secondary;
    final style = _styleFor(variant);
    final Widget button = switch ((filled, icon != null && !loading)) {
      (true, true) => FilledButton.icon(
        onPressed: callback,
        style: style,
        icon: Icon(icon),
        label: content,
      ),
      (true, false) => FilledButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      (false, true) => OutlinedButton.icon(
        onPressed: callback,
        icon: Icon(icon),
        label: content,
      ),
      (false, false) => OutlinedButton(onPressed: callback, child: content),
    };

    return Semantics(
      button: true,
      enabled: callback != null && !loading,
      label: loading ? '$label, sedang diproses' : null,
      child: AbsorbPointer(
        absorbing: loading,
        child: expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
