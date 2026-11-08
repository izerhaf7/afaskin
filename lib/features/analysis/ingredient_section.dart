import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/ingredient_guide.dart';
import 'package:material_ui/material_ui.dart';

/// "Kandungan yang dibutuhkan": for every detected condition, the actives that
/// help it, what each one does, and the reference behind it.
///
/// Content comes from [IngredientGuide], which is generated from
/// `recommender/ingredient_mapping.csv` — the same table the recommender scores
/// against, so the advice and the product list never disagree.
class IngredientSection extends StatelessWidget {
  const IngredientSection({required this.conditions, super.key});

  final List<SkinCondition> conditions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (conditions.isEmpty) {
      return AfaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.ingredientsBasic, style: text.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final i in IngredientGuide.basic) _IngredientRow(info: i),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final c in conditions) ...[
          _ConditionIngredients(condition: c),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _ConditionIngredients extends StatelessWidget {
  const _ConditionIngredients({required this.condition});

  final SkinCondition condition;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final all = IngredientGuide.forCondition(condition.label);
    if (all.isEmpty) return const SizedBox.shrink();
    final recommended = all.where((i) => !i.isAvoid).toList();
    final avoid = all.where((i) => i.isAvoid).toList();

    return AfaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.condition(condition.label),
                  style: text.titleMedium,
                ),
              ),
              Text(
                '${(condition.probability * 100).round()}%',
                style: text.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final i in recommended) _IngredientRow(info: i),
          if (avoid.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.ingredientAvoid,
              style: text.titleSmall?.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.xxs),
            for (final i in avoid) _IngredientRow(info: i, avoid: true),
          ],
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.info, this.avoid = false});

  final IngredientInfo info;
  final bool avoid;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tint = avoid ? AppColors.danger : AppColors.sage;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: AppSpacing.xs),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: text.titleSmall?.copyWith(
                    fontSize: 14,
                    color: avoid ? AppColors.danger : AppColors.ink,
                  ),
                ),
                Text(info.benefit, style: text.bodyMedium),
                if (info.source.trim().isNotEmpty)
                  Text(
                    info.source,
                    style: text.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
