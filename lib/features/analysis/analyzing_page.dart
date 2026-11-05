import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Uploads the pending photo and shows staged progress text.
/// - success: stores the result and opens the result screen;
/// - quality rejected: shows the reasons and sends the user back to retake;
/// - network/server error: keeps the photo in memory and offers retry.
class AnalyzingPage extends ConsumerStatefulWidget {
  const AnalyzingPage({
    super.key,
    this.stepInterval = const Duration(milliseconds: 1200),
  });

  final Duration stepInterval;

  @override
  ConsumerState<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends ConsumerState<AnalyzingPage> {
  int _step = 0;
  Timer? _ticker;
  Failure? _failure;
  bool _running = false;

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
      _running = true;
      _failure = null;
      _step = 0;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(widget.stepInterval, (_) {
      if (_step < AppStrings.analyzingSteps.length - 1) {
        setState(() => _step++);
      }
    });

    try {
      final result = await ref
          .read(analysisRepositoryProvider)
          .analyze(
            imageJpeg: photo,
            payload: AnalyzePayload(
              profile: session.profile!,
              questionnaire: session.answers?.answers ?? const {},
            ),
          );
      ref.read(pendingPhotoProvider.notifier).clear();
      ref.read(latestAnalysisProvider.notifier).set(result);
      // History keeps the result JSON only; the photo is never stored.
      await ref.read(historyProvider.notifier).add(result);
      if (mounted) context.go(AppRoutes.result);
    } on Failure catch (f) {
      // A rejected photo is useless: drop it. Keep it for network retries.
      if (f is QualityRejected) ref.read(pendingPhotoProvider.notifier).clear();
      if (mounted) setState(() => _failure = f);
    } finally {
      _ticker?.cancel();
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final failure = _failure;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analyzingTitle),
        automaticallyImplyLeading: !_running,
      ),
      body: SafeArea(
        child: switch (failure) {
          QualityRejected() => _QualityRejectedView(
            failure: failure,
            onRetake: () => context.pop(),
          ),
          Failure() => ErrorView(error: failure, onRetry: _run),
          null => _Progress(step: _step),
        },
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
    final message = AppStrings.analyzingSteps[step];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuatrefoilLoader(size: 120, semanticLabel: message),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                message,
                key: ValueKey(step),
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Center(
          child: QuatrefoilIcon(
            icon: Icons.wb_twilight_rounded,
            iconColor: AppColors.caution,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.md),
        if (failure.readableReasons.isNotEmpty)
          AfaCard(
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
        const SizedBox(height: AppSpacing.lg),
        AfaButton(
          label: AppStrings.retakePhoto,
          icon: Icons.photo_camera_outlined,
          onPressed: onRetake,
        ),
      ],
    );
  }
}
