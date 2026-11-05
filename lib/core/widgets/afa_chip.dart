import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

enum AfaChipTone {
  /// White with outline border; sage wash when selected.
  neutral,

  /// Matching / helpful ingredient.
  positive,

  /// Ingredient conflict, error.
  danger,

  /// Mild warning, e.g. photo quality.
  caution,
}

/// Pill chip. Text is always Ink or a status color (never Sage), so every
/// tone passes contrast for small text.
class AfaChip extends StatelessWidget {
  const AfaChip({
    required this.label,
    super.key,
    this.tone = AfaChipTone.neutral,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  final String label;
  final AfaChipTone tone;

  /// Only meaningful for [AfaChipTone.neutral] (filter chips).
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  ({Color bg, Color fg, Color border}) get _colors => switch (tone) {
    AfaChipTone.neutral when selected => (
      bg: AppColors.sageTint,
      fg: AppColors.ink,
      border: AppColors.sage,
    ),
    AfaChipTone.neutral => (
      bg: AppColors.white,
      fg: AppColors.ink,
      border: AppColors.outline,
    ),
    AfaChipTone.positive => _status(AppColors.positive),
    AfaChipTone.danger => _status(AppColors.danger),
    AfaChipTone.caution => _status(AppColors.caution),
  };

  static ({Color bg, Color fg, Color border}) _status(Color c) =>
      (bg: AppColors.statusTint(c), fg: c, border: c.withValues(alpha: 0.40));

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: colors.fg);
    final leading =
        icon ??
        (selected && tone == AfaChipTone.neutral ? Icons.check_rounded : null);

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 2,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: colors.border, width: selected ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 16, color: colors.fg),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(child: Text(label, style: style)),
        ],
      ),
    );

    if (onTap == null) return chip;

    // Interactive chips get a full 48 dp touch target around the visual pill.
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: AppSpacing.minTouchTarget,
            ),
            child: Center(widthFactor: 1, child: chip),
          ),
        ),
      ),
    );
  }
}
