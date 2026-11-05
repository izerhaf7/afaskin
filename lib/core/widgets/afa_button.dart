import 'package:afaskin/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

enum AfaButtonVariant {
  /// Ink fill, white label. The main action on a screen.
  primary,

  /// Sage outline, ink label.
  secondary,
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
              color: variant == AfaButtonVariant.primary
                  ? AppColors.white
                  : AppColors.ink,
            ),
          )
        : Text(label, textAlign: TextAlign.center);

    final Widget button = switch ((variant, icon != null && !loading)) {
      (AfaButtonVariant.primary, true) => FilledButton.icon(
        onPressed: callback,
        icon: Icon(icon),
        label: content,
      ),
      (AfaButtonVariant.primary, false) => FilledButton(
        onPressed: callback,
        child: content,
      ),
      (AfaButtonVariant.secondary, true) => OutlinedButton.icon(
        onPressed: callback,
        icon: Icon(icon),
        label: content,
      ),
      (AfaButtonVariant.secondary, false) => OutlinedButton(
        onPressed: callback,
        child: content,
      ),
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
