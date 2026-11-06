import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:afaskin/features/home/analysis_home_page.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Trend of the latest main condition over (up to) the last 3 analyses,
/// oldest first. Null when fewer than 2 analyses report that condition.
({SkinConditionLabel label, List<(DateTime, double)> points})? conditionTrend(
  List<AnalysisResult> newestFirst,
) {
  if (newestFirst.isEmpty) return null;
  final top = newestFirst.first.topCondition;
  if (top == null) return null;
  final points = <(DateTime, double)>[];
  for (final r in newestFirst.take(3)) {
    final c = r.conditions.where((c) => c.label == top.label).firstOrNull;
    if (c != null) points.add((r.createdAt, c.probability));
  }
  if (points.length < 2) return null;
  return (label: top.label, points: points.reversed.toList());
}

/// "Riwayat" tab: past analyses stored locally (no photos).
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AnalysisResult r,
  ) async {
    final history = ref.read(historyProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    await history.remove(r.analysisId);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(AppStrings.deleted),
          action: SnackBarAction(
            label: AppStrings.undo,
            onPressed: () => unawaited(history.add(r)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final items = ref.watch(historyProvider);
    final trend = conditionTrend(items);

    return Scaffold(
      body: AfaBackdrop(
        child: SafeArea(
          bottom: false,
          child: items.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Title(),
                    Expanded(
                      child: _EmptyHistory(
                        onStart: () => unawaited(startAnalysis(context, ref)),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  children: [
                    const _Title(),
                    if (trend != null)
                      _TrendCard(label: trend.label, points: trend.points),
                    for (final (i, r) in items.indexed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          0,
                        ),
                        child: Dismissible(
                          key: ValueKey(r.analysisId),
                          direction: DismissDirection.endToStart,
                          background: const _DeleteBackground(),
                          onDismissed: (_) => _delete(context, ref, r),
                          child: Semantics(
                            customSemanticsActions: {
                              CustomSemanticsAction(
                                label: AppStrings.deleteEntry(
                                  formatDate(r.createdAt),
                                ),
                              ): () =>
                                  unawaited(_delete(context, ref, r)),
                            },
                            child: _HistoryRow(
                              result: r,
                              mark: const [
                                AppColors.sage,
                                AppColors.ink,
                                AppColors.outline,
                              ][i % 3],
                              onTap: () => context.push(
                                AppRoutes.historyEntry(r.analysisId),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        20,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Text(
                        AppStrings.historyLocalNote,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.sm,
    ),
    child: Text(
      AppStrings.historyTitle,
      style: Theme.of(context).textTheme.displayLarge,
    ),
  );
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.label, required this.points});

  final SkinConditionLabel label;
  final List<(DateTime, double)> points;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final first = points.first;
    final delta = ((points.last.$2 - first.$2) * 100).round();
    final since = formatDayMonth(first.$1);
    final (message, mood, color) = delta < 0
        ? (
            AppStrings.trendDown(-delta, since),
            AlfaMood.celebrate,
            AppColors.positive,
          )
        : delta > 0
        ? (AppStrings.trendUp(delta, since), AlfaMood.thinking, AppColors.ink)
        : (AppStrings.trendFlat(since), AlfaMood.happy, AppColors.ink);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.condition(label), style: text.titleMedium),
          Row(
            children: [
              AlfaMascot(mood: mood, motion: AlfaMotion.none, size: 56),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: text.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: [
              for (final (d, v) in points)
                '${formatDayMonth(d)} ${formatPercent(v)}',
            ].join(', '),
            child: ExcludeSemantics(
              child: SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, (_, v)) in points.indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: (v * 0.85).clamp(0.06, 1),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: i == points.length - 1
                                  ? AppColors.sage
                                  : AppColors.outline,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                                bottom: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final (i, (d, _)) in points.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      formatDayMonth(d),
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.result,
    required this.mark,
    required this.onTap,
  });

  final AnalysisResult result;
  final Color mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final top = result.topCondition;
    return Material(
      color: AppColors.white,
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                QuatrefoilShape(size: 44, color: mark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.skinType(result.skinType.label)} · '
                        '${formatPercent(result.skinType.confidence)}',
                        style: text.titleMedium,
                      ),
                      Text(
                        '${formatDate(result.createdAt)} · '
                        '${top == null ? AppStrings.noMainCondition : '${AppStrings.condition(top.label)} ${formatPercent(top.probability)}'}',
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
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    decoration: const BoxDecoration(
      color: AppColors.dangerTint,
      borderRadius: AppRadius.cardAll,
    ),
    child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -20,
                    top: 10,
                    child: QuatrefoilShape(size: 70, color: AppColors.white),
                  ),
                  Positioned(
                    right: -16,
                    bottom: 10,
                    child: Opacity(
                      opacity: 0.3,
                      child: QuatrefoilShape(size: 48),
                    ),
                  ),
                  AlfaMascot(mood: AlfaMood.sleepy, motion: AlfaMotion.none),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.historyEmptyTitle,
              style: text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.historyEmptyBody,
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AfaButton(
              label: AppStrings.startAnalysis,
              expand: false,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

/// A stored analysis opened from History or the home card.
class HistoryEntryPage extends ConsumerWidget {
  const HistoryEntryPage({required this.analysisId, super.key});

  final String analysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyProvider);
    final r = ref.read(historyProvider.notifier).byId(analysisId);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(title: AppStrings.historyNotFound),
      );
    }
    return ResultPage(result: r);
  }
}
