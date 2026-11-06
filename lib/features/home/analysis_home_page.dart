import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:afaskin/features/settings/avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Days between analyses suggested by the design.
const int kReanalyzeDays = 14;

/// Starts a new analysis. With saved answers it offers "photo now" or
/// "update answers first"; without them it goes to the questionnaire.
Future<void> startAnalysis(BuildContext context, WidgetRef ref) async {
  final answers = ref.read(sessionProvider).answers;
  if (answers == null) {
    await context.push(AppRoutes.quizBeforeCapture);
    return;
  }
  await showAfaSheet<void>(
    context,
    builder: (sheet) => ReanalyzeSheet(
      answeredAt: answers.answeredAt,
      onPhoto: () {
        Navigator.pop(sheet);
        unawaited(context.push(AppRoutes.capture));
      },
      onUpdate: () {
        Navigator.pop(sheet);
        unawaited(context.push(AppRoutes.quizBeforeCapture));
      },
    ),
  );
}

/// "Analisis" tab (Beranda).
class AnalysisHomePage extends ConsumerWidget {
  const AnalysisHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final session = ref.watch(sessionProvider);
    final history = ref.watch(historyProvider);
    final last = history.isEmpty ? null : history.first;

    return Scaffold(
      body: AfaBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    const AfaLogo(height: 28),
                    const Spacer(),
                    Semantics(
                      button: true,
                      label: AppStrings.openProfile,
                      child: InkResponse(
                        onTap: () => context.go(AppRoutes.settings),
                        radius: 28,
                        child: SizedBox.square(
                          dimension: AppSpacing.minTouchTarget,
                          child: Center(
                            child: AvatarFoil(initial: session.initial),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  20,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.greeting(DateTime.now().hour, session.name),
                      style: text.bodyLarge?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(AppStrings.homeTitle, style: text.displayLarge),
                  ],
                ),
              ),
              _HeroCard(
                last: last,
                onStart: () => unawaited(startAnalysis(context, ref)),
              ),
              if (last != null) ...[
                _LastResultCard(result: last),
                _RecoRow(result: last, budget: session.activeBudget),
                if (session.reminderOn)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 18,
                          color: AppColors.inkMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            AppStrings.nextReminder(
                              formatDate(
                                last.createdAt.add(
                                  const Duration(days: kReanalyzeDays),
                                ),
                              ),
                            ),
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
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
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.last, required this.onStart});

  final AnalysisResult? last;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final white = text.bodyMedium?.copyWith(color: AppColors.white);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadius.cardAll,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -60,
            top: -60,
            child: Opacity(opacity: 0.35, child: QuatrefoilShape(size: 140)),
          ),
          const Positioned(right: -18, top: -12, child: AlfaMascot(size: 104)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      last == null
                          ? AppStrings.firstAnalysisTitle
                          : AppStrings.reanalyzeTitle,
                      style: text.headlineMedium?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      last == null
                          ? AppStrings.firstAnalysisBody
                          : AppStrings.reanalyzeBody(
                              formatDate(last!.createdAt),
                            ),
                      style: white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AfaButton(
                label: AppStrings.startAnalysis,
                icon: Icons.photo_camera_outlined,
                variant: AfaButtonVariant.onDark,
                onPressed: onStart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skin type tile + top 3 conditions.
class _LastResultCard extends StatelessWidget {
  const _LastResultCard({required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final top = result.conditionsByProbability.take(3);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(AppStrings.lastResult, style: text.titleLarge),
              ),
              Text(
                formatDate(result.createdAt),
                style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SkinTypeLine(skinType: result.skinType),
          const SizedBox(height: AppSpacing.md),
          for (final c in top) ...[
            MiniBar(label: AppStrings.condition(c.label), value: c.probability),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xxs),
          SizedBox(
            height: AppSpacing.minTouchTarget,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              ),
              onPressed: () =>
                  context.push(AppRoutes.historyEntry(result.analysisId)),
              child: const Text(AppStrings.seeFullResult),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sage tile with a drop icon + "Tipe kulit / Berminyak · 78%".
class SkinTypeLine extends StatelessWidget {
  const SkinTypeLine({required this.skinType, super.key, this.compact = false});

  final SkinTypeResult skinType;

  /// Single line (recommendation summary) instead of label + value.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final value =
        '${AppStrings.skinType(skinType.label)} · '
        '${formatPercent(skinType.confidence)}';
    return Row(
      children: [
        const QuatrefoilTile(
          icon: Icons.water_drop_outlined,
          size: 48,
          color: AppColors.sage,
          iconColor: AppColors.white,
          iconSize: 22,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.skinTypeHeading,
                style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
              Text(value, style: text.titleLarge),
            ],
          ),
        ),
      ],
    );
  }
}

/// Condition name + percent + thin sage bar on a mist track.
class MiniBar extends StatelessWidget {
  const MiniBar({required this.label, required this.value, super.key});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pct = formatPercent(value);
    return Semantics(
      label: AppStrings.percentOf(label, pct),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: text.bodyMedium)),
                Text(pct, style: text.titleSmall),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.mist,
                color: AppColors.sage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoRow extends ConsumerWidget {
  const _RecoRow({required this.result, required this.budget});

  final AnalysisResult result;
  final int? budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final count = ref
        .watch(
          recommendationsProvider(
            analysisId: result.analysisId,
            maxPrice: budget,
          ),
        )
        .whenOrNull(data: (items) => items.length);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push(AppRoutes.recommendations(result.analysisId)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const QuatrefoilTile(icon: Icons.shopping_bag_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.recommendationsTitle,
                          style: text.titleMedium,
                        ),
                        if (count != null)
                          Text(
                            AppStrings.recoLine(
                              count,
                              budget == null ? null : formatRupiah(budget!),
                            ),
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Analisis ulang" bottom sheet.
class ReanalyzeSheet extends StatelessWidget {
  const ReanalyzeSheet({
    required this.onPhoto,
    required this.onUpdate,
    super.key,
    this.answeredAt,
  });

  final DateTime? answeredAt;
  final VoidCallback onPhoto;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppStrings.reanalyzeTitle, style: text.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.reanalyzeSheetBody(
            answeredAt == null ? null : formatDayMonth(answeredAt!),
          ),
          style: text.bodyLarge?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.mist,
            borderRadius: AppRadius.inputAll,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(AppStrings.reanalyzeTip, style: text.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AfaButton(label: AppStrings.photoNow, onPressed: onPhoto),
        const SizedBox(height: AppSpacing.sm),
        AfaButton.secondary(
          label: AppStrings.updateAnswersFirst,
          onPressed: onUpdate,
        ),
      ],
    );
  }
}
