import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// White card with an outline border (no Material elevation).
/// [selected] swaps to a sage border on a light sage wash, used for
/// tappable choices such as Likert answers.
class AfaCard extends StatelessWidget {
  const AfaCard({
    required this.child,
    super.key,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.shadow = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;

  /// Soft ink shadow for cards that float above the Mist background.
  final bool shadow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? AppColors.sageTint : AppColors.white,
        borderRadius: AppRadius.cardAll,
        border: Border.all(
          color: selected ? AppColors.sage : AppColors.outline,
          width: selected ? 2 : 1,
        ),
        boxShadow: shadow ? AppShadows.soft : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    if (onTap == null && semanticLabel == null) return card;
    return Semantics(
      button: onTap != null,
      selected: onTap != null ? selected : null,
      label: semanticLabel,
      child: card,
    );
  }
}
