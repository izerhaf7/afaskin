import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:material_ui/material_ui.dart';

/// Alfa next to a speech bubble (tail at the bottom-left, pointing at Alfa).
class AlfaSays extends StatelessWidget {
  const AlfaSays({
    required this.child,
    super.key,
    this.mood = AlfaMood.happy,
    this.motion = AlfaMotion.bob,
    this.size = 116,
    this.bubbleBottomGap = 48,
    this.liveRegion = true,
  });

  /// Bubble content (question text, optional lead line).
  final Widget child;
  final AlfaMood mood;
  final AlfaMotion motion;
  final double size;

  /// Lifts the bubble so its tail sits near Alfa's mouth.
  final double bubbleBottomGap;

  /// Announce bubble changes to screen readers (Alfa "speaks").
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.translate(
          offset: const Offset(-8, 0),
          child: AlfaMascot(mood: mood, motion: motion, size: size),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: bubbleBottomGap),
            child: Semantics(
              liveRegion: liveRegion,
              child: SpeechBubble(child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({required this.child, super.key, this.compact = false});

  final Widget child;

  /// Smaller padding/radius (inline hints, e.g. on the consent screen).
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(compact ? 16 : 20),
        topRight: Radius.circular(compact ? 16 : 20),
        bottomRight: Radius.circular(compact ? 16 : 20),
        bottomLeft: Radius.circular(compact ? 4 : 6),
      ),
    ),
    child: child,
  );
}

/// Filled quatrefoil tile with a centered icon (design's icon badges).
class QuatrefoilTile extends StatelessWidget {
  const QuatrefoilTile({
    required this.icon,
    super.key,
    this.size = 44,
    this.color = AppColors.mist,
    this.iconColor = AppColors.ink,
    this.iconSize,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) => QuatrefoilShape(
    size: size,
    color: color,
    child: Center(
      child: Icon(icon, size: iconSize ?? size / 2, color: iconColor),
    ),
  );
}

/// Single-choice row with a quatrefoil "radio" (gender, budget options).
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.height = 60,
    this.radius = AppRadius.card,
    this.outlineWhenIdle = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final double radius;

  /// Idle border: outline grey (in sheets on white) instead of invisible.
  final bool outlineWhenIdle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(
              color: selected
                  ? AppColors.sage
                  : outlineWhenIdle
                  ? AppColors.outline
                  : AppColors.white,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    QuatrefoilShape(
                      size: 28,
                      color: selected ? AppColors.sage : AppColors.mist,
                      child: selected
                          ? const Center(
                              child: SizedBox.square(
                                dimension: 12,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(label, style: text.bodyLarge)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented progress (onboarding dots, profile steps).
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({
    required this.count,
    required this.filled,
    super.key,
    this.height = 6,
    this.semanticsLabel,
  });

  final int count;

  /// Number of filled segments (1-based progress).
  final int filled;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    child: Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: height,
              decoration: BoxDecoration(
                color: i < filled ? AppColors.sage : AppColors.outline,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Opens a design-style bottom sheet (handle, 28 radius, dark scrim).
Future<T?> showAfaSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  showDragHandle: false,
  useSafeArea: true,
  barrierColor: AppColors.sheetScrim,
  backgroundColor: AppColors.white,
  shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(child: SingleChildScrollView(child: builder(context))),
        ],
      ),
    ),
  ),
);

/// Short message pill above the bottom navigation.
void showAfaToast(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 2400),
      ),
    );
}
