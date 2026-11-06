import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const List<ProductCategory> _categories = [
  ProductCategory.cleanser,
  ProductCategory.toner,
  ProductCategory.serum,
  ProductCategory.moisturizer,
  ProductCategory.sunscreen,
];

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({required this.analysisId, super.key});

  final String analysisId;

  @override
  ConsumerState<RecommendationsPage> createState() =>
      _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  ProductCategory? _category;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final session = ref.watch(sessionProvider);
    final budget = session.activeBudget;
    final analysis =
        ref.watch(historyProvider.notifier).byId(widget.analysisId) ??
        ref.watch(latestAnalysisProvider);
    ref.watch(historyProvider);

    final provider = recommendationsProvider(
      analysisId: widget.analysisId,
      category: _category,
      maxPrice: budget,
    );
    final async = ref.watch(provider);

    return Scaffold(
      body: AfaBackdrop(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.xxs,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: AppStrings.backToHome,
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.home),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis != null)
                              Text(
                                AppStrings.analysisOf(
                                  formatDate(analysis.createdAt),
                                ),
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            Text(
                              AppStrings.recoTitle,
                              style: text.displayLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (analysis != null)
                SliverToBoxAdapter(child: _SummaryCard(result: analysis)),
              if (!session.profileComplete)
                SliverToBoxAdapter(
                  child: _CompleteProfileCard(
                    onTap: () => context.push(AppRoutes.completeProfile),
                  ),
                ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    20,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    children: [
                      for (final c in [null, ..._categories]) ...[
                        _Pill(
                          label: c == null
                              ? AppStrings.allCategories
                              : AppStrings.category(c),
                          selected: _category == c,
                          leading: _category == c ? Icons.check_rounded : null,
                          onTap: () => setState(() => _category = c),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: _Pill(
                          key: const Key('budget_chip'),
                          label: budget == null
                              ? AppStrings.anyPrice
                              : AppStrings.maxPrice(formatRupiah(budget)),
                          selected: budget != null,
                          leading: Icons.payments_outlined,
                          trailing: Icons.expand_more_rounded,
                          onTap: () => unawaited(
                            openBudgetSheet(
                              context,
                              current: budget,
                              apply: ref
                                  .read(sessionProvider.notifier)
                                  .setBudgetFilter,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (async case AsyncData(:final value))
                        Text(
                          AppStrings.productCount(value.length),
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ...switch (async) {
                AsyncData(:final value) when value.isEmpty => [
                  const SliverToBoxAdapter(child: _EmptyBudget()),
                ],
                AsyncData(:final value) => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    sliver: SliverList.separated(
                      itemCount: (value.length + 1) ~/ 2,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, row) {
                        Widget cell(int i) => i < value.length
                            ? ProductCard(
                                product: value[i],
                                onTap: () => context.push(
                                  AppRoutes.product(value[i].id),
                                ),
                              )
                            : const SizedBox.shrink();
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: cell(row * 2)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: cell(row * 2 + 1)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                AsyncError(:final error) => [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 360,
                      child: ErrorView(
                        error: error,
                        onRetry: () => ref.invalidate(provider),
                      ),
                    ),
                  ),
                ],
                _ => [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 280, child: LoadingView()),
                  ),
                ],
              },
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    20,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.inkMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          AppStrings.scoreNote,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
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

/// "Berminyak · 78%" + top conditions + "Detail" link to the full result.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final conds = result.conditionsByProbability
        .take(3)
        .map((c) => AppStrings.condition(c.label))
        .join(', ');
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
      ),
      child: Row(
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
                  '${AppStrings.skinType(result.skinType.label)} · '
                  '${formatPercent(result.skinType.confidence)}',
                  style: text.titleMedium,
                ),
                if (conds.isNotEmpty)
                  Text(
                    conds,
                    style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                context.push(AppRoutes.historyEntry(result.analysisId)),
            child: Text(
              AppStrings.detail,
              style: text.labelMedium?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteProfileCard extends StatelessWidget {
  const _CompleteProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: CustomPaint(
        foregroundPainter: const _DashedBorder(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.cardAll,
          ),
          child: Row(
            children: [
              const AlfaMascot(size: 80),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.completeProfileTitle,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.completeProfileBody,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        textStyle: text.labelMedium,
                      ),
                      child: const Text(AppStrings.completeProfileCta),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1.5 px dashed sage outline matching the card radius.
class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      const Radius.circular(AppRadius.card),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.sage;
    for (final m in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => false;
}

/// White pill with optional leading/trailing icon (filter chips).
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.leading,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: AppColors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.sage : AppColors.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 18),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  Icon(trailing, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _EmptyBudget extends StatelessWidget {
  const _EmptyBudget();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        children: [
          const QuatrefoilTile(icon: Icons.filter_alt_off_outlined, size: 56),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.recoEmptyTitle,
            style: text.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            AppStrings.recoEmptyBody,
            style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
