import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Uploads the pending photo and shows a staged checklist.
/// - success: saves to history, toasts, opens the result screen;
/// - quality rejected: shows the reasons, back to the camera to retake;
/// - network/server error: keeps the photo in memory and offers retry.
class AnalyzingPage extends ConsumerStatefulWidget {
  const AnalyzingPage({
    super.key,
    this.stepInterval = const Duration(milliseconds: 1100),
  });

  final Duration stepInterval;

  @override
  ConsumerState<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends ConsumerState<AnalyzingPage> {
  int _step = 0;
  Timer? _ticker;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _run() async {
    final photo = ref.read(pendingPhotoProvider);
    final session = ref.read(sessionProvider);
    if (photo == null || session.profile == null) {
      if (mounted) context.pop();
      return;
    }

    setState(() {
      _failure = null;
      _step = 0;
    });
    _ticker?.cancel();
    // Langkah mengikuti tahap nyata dari repository. Timer hanya jaring
    // pengaman: kalau satu tahap lama, penanda bergerak sendiri supaya layar
    // tidak terlihat beku.
    void mark(AnalysisStage stage) {
      final i = stage.index;
      if (!mounted || i <= _step) return;
      setState(() => _step = i);
    }

    _ticker = Timer.periodic(widget.stepInterval, (_) {
      if (_step < AppStrings.analyzingSteps.length - 1) {
        setState(() => _step++);
      }
    });

    try {
      final repo = ref.read(analysisRepositoryProvider);
      final sides = ref.read(pendingSidePhotosProvider);
      final payload = AnalyzePayload(
        profile: session.profile!,
        questionnaire: session.answers?.answers ?? const {},
      );
      final result = sides.isEmpty
          ? await repo.analyze(
              imageJpeg: photo,
              payload: payload,
              onStage: mark,
            )
          : await repo.analyze(
              imageJpeg: photo,
              payload: payload,
              sideImagesJpeg: sides,
              onStage: mark,
            );
      // Front photo stays in memory for the face map on the result screen.
      ref
          .read(latestAnalysisPhotoProvider.notifier)
          .set(result.analysisId, photo);
      ref.read(pendingPhotoProvider.notifier).clear();
      ref.read(pendingSidePhotosProvider.notifier).clear();
      ref.read(latestAnalysisProvider.notifier).set(result);
      // History keeps the result JSON only; the photo is never stored.
      await ref.read(historyProvider.notifier).add(result);
      if (!mounted) return;
      showAfaToast(context, AppStrings.savedToHistory);
      context.go(AppRoutes.result);
    } on Failure catch (f) {
      // A rejected photo is useless: drop it. Keep it for network retries.
      if (f is QualityRejected) {
        ref.read(pendingPhotoProvider.notifier).clear();
        ref.read(pendingSidePhotosProvider.notifier).clear();
      }
      if (mounted) setState(() => _failure = f);
    } finally {
      _ticker?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final failure = _failure;
    return PopScope(
      // No accidental back while uploading.
      canPop: failure != null,
      child: Scaffold(
        body: AfaBackdrop(
          style: failure == null ? BackdropStyle.bubbles : BackdropStyle.waves,
          child: SafeArea(
            child: switch (failure) {
              QualityRejected() => _QualityRejectedView(
                failure: failure,
                onRetake: () => context.pop(),
              ),
              Failure() => _FailureView(
                failure: failure,
                onRetry: () => unawaited(_run()),
                onHome: () => context.go(AppRoutes.home),
              ),
              null => _Progress(step: _step),
            },
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const steps = AppStrings.analyzingSteps;
    final now = '${steps[step]}…';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        children: [
                          _SpinningFoil(),
                          Positioned(
                            left: 20,
                            top: 16,
                            child: AlfaMascot(
                              mood: AlfaMood.thinking,
                              motion: AlfaMotion.squish,
                              size: 140,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      AppStrings.analyzingTitle,
                      style: text.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        now,
                        style: text.bodyLarge?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.cardAll,
                      ),
                      child: Column(
                        children: [
                          for (final (i, label) in steps.indexed)
                            _StepRow(
                              label: label,
                              done: i < step,
                              active: i == step,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            AppStrings.analyzingFooter,
            style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.sage : AppColors.white,
            border: done
                ? null
                : Border.all(
                    color: active ? AppColors.sage : AppColors.outline,
                    width: active ? 2 : 1.5,
                  ),
          ),
          child: done
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.white,
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: done || active ? AppColors.ink : AppColors.inkMuted,
            ),
          ),
        ),
      ],
    ),
  );
}

/// White quatrefoil turning slowly behind Alfa (static under reduced motion).
class _SpinningFoil extends StatefulWidget {
  const _SpinningFoil();

  @override
  State<_SpinningFoil> createState() => _SpinningFoilState();
}

class _SpinningFoilState extends State<_SpinningFoil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    still ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _c,
    child: const QuatrefoilShape(size: 180, color: AppColors.white),
  );
}

/// Network ("Koneksi terputus") or server error.
class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.failure,
    required this.onRetry,
    required this.onHome,
  });

  final Failure failure;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final offline = failure is NetworkFailure;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const AlfaMascot(
                            mood: AlfaMood.sad,
                            motion: AlfaMotion.none,
                            size: 150,
                          ),
                          Positioned(
                            right: -8,
                            top: 0,
                            child: QuatrefoilTile(
                              icon: offline
                                  ? Icons.wifi_off_rounded
                                  : Icons.cloud_off_rounded,
                              size: 52,
                              color: AppColors.white,
                              iconSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      offline
                          ? AppStrings.netErrorTitle
                          : AppStrings.serverErrorTitle,
                      style: text.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        offline ? AppStrings.netErrorBody : failure.message,
                        style: text.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AfaButton(label: AppStrings.retry, onPressed: onRetry),
          const SizedBox(height: AppSpacing.sm),
          AfaButton.secondary(label: AppStrings.backToHome, onPressed: onHome),
        ],
      ),
    );
  }
}

class _QualityRejectedView extends StatelessWidget {
  const _QualityRejectedView({required this.failure, required this.onRetake});

  final QualityRejected failure;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: AlfaMascot(
                        mood: AlfaMood.oops,
                        motion: AlfaMotion.none,
                        size: 150,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppStrings.qualityRejectedTitle,
                      style: text.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      failure.message,
                      style: text.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (failure.readableReasons.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.cardAll,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final r in failure.readableReasons)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xxs,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.caution,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        r,
                                        style: text.bodyMedium?.copyWith(
                                          color: AppColors.caution,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          AfaButton(
            label: AppStrings.retakePhoto,
            icon: Icons.photo_camera_outlined,
            onPressed: onRetake,
          ),
        ],
      ),
    );
  }
}
