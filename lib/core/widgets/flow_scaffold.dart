import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:material_ui/material_ui.dart';

/// Layout of the design's step screens (consent, profile, questionnaire):
/// backdrop, optional top bar, scrollable content, pinned primary button.
/// The button stays reachable at 130% text size and with the keyboard open.
class FlowScaffold extends StatelessWidget {
  const FlowScaffold({
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    super.key,
    this.topBar,
    this.ctaLoading = false,
    this.backdrop = BackdropStyle.waves,
    this.secondary,
  });

  final Widget? topBar;
  final Widget body;
  final String ctaLabel;

  /// Null disables the button.
  final VoidCallback? onCta;
  final bool ctaLoading;
  final BackdropStyle backdrop;

  /// Optional second button under the main one.
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: AfaBackdrop(
        style: backdrop,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?topBar,
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: body,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AfaButton(
                  label: ctaLabel,
                  loading: ctaLoading,
                  onPressed: onCta,
                ),
                if (secondary != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  secondary!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Back button + progress + "1/2" counter.
class FlowTopBar extends StatelessWidget {
  const FlowTopBar({
    required this.progress,
    super.key,
    this.onBack,
    this.count,
  });

  /// Usually `SegmentedProgress` or [FlowProgressBar].
  final Widget progress;
  final VoidCallback? onBack;
  final String? count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-12, 0),
            child: IconButton(
              tooltip: AppStrings.back,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          Expanded(child: progress),
          if (count != null)
            SizedBox(
              width: 44,
              child: Text(
                count!,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
        ],
      ),
    );
  }
}

/// Continuous bar on a white track (questionnaire).
class FlowProgressBar extends StatelessWidget {
  const FlowProgressBar({required this.value, super.key, this.semanticsLabel});

  final double value;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 350),
      builder: (context, v, _) => LinearProgressIndicator(
        key: const Key('flow_progress'),
        value: v,
        minHeight: 8,
        backgroundColor: AppColors.white,
        color: AppColors.sage,
        semanticsLabel: semanticsLabel,
      ),
    ),
  );
}
