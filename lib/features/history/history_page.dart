import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Riwayat" tab: past analyses stored locally (no photos).
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(AppStrings.historyClearAll),
        content: const Text(AppStrings.historyClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(historyProvider.notifier).clear();
  }

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
          content: const Text(AppStrings.historyDeleted),
          action: SnackBarAction(
            label: AppStrings.undo,
            onPressed: () => unawaited(history.add(r)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabHistory),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: AppStrings.historyClearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearAll(context, ref),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyView(
              title: AppStrings.historyEmptyTitle,
              body: AppStrings.historyEmptyBody,
              icon: Icons.history_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, i) {
                final r = items[i];
                return Dismissible(
                  key: ValueKey(r.analysisId),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  onDismissed: (_) => _delete(context, ref, r),
                  child: _HistoryCard(
                    result: r,
                    onTap: () =>
                        context.push(AppRoutes.historyEntry(r.analysisId)),
                    onDelete: () => _delete(context, ref, r),
                  ),
                );
              },
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  final AnalysisResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final date = formatDateTime(result.createdAt);
    final top = result.topCondition;
    return AfaCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xxs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: text.bodySmall),
                Text(
                  '${AppStrings.skinType(result.skinType.label)} · '
                  '${formatPercent(result.skinType.confidence)}',
                  style: text.titleMedium,
                ),
                Text(
                  top == null
                      ? AppStrings.noMainCondition
                      : '${AppStrings.condition(top.label)} '
                            '(${formatPercent(top.probability)})',
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppStrings.deleteEntry(date),
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onDelete,
          ),
        ],
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
    decoration: BoxDecoration(
      color: AppColors.statusTint(AppColors.danger),
      borderRadius: AppRadius.cardAll,
    ),
    child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
  );
}

/// A stored analysis opened from History.
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
