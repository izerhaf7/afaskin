import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productDetailProvider(productId);
    final async = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(),
      body: switch (async) {
        AsyncData(:final value) => ProductDetailView(product: value),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(provider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = product;
    final ingredients = p.ingredients ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(url: p.imageUrl, size: 112),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.brand} · ${AppStrings.category(p.category)}',
                    style: text.bodyMedium,
                  ),
                  Text(p.name, style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(formatRupiah(p.price), style: text.titleLarge),
                      MatchBadge(score: p.matchScore),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (p.hasWarnings) ...[
          const SizedBox(height: AppSpacing.md),
          ConflictBanner(warnings: p.warnings),
        ],
        if (p.reasons.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.whyRecommended, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            child: Column(
              children: [
                for (final r in p.reasons)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.positive,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(r, style: text.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (p.matchedIngredients.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.matchedIngredients, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final m in p.matchedIngredients)
                AfaChip(label: m, tone: AfaChipTone.positive),
            ],
          ),
        ],
        if (ingredients.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.ingredientsHeading, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(AppStrings.ingredientsLegend, style: text.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final i in ingredients)
                AfaChip(
                  key: ValueKey('ingredient_$i'),
                  label: i,
                  tone: p.isMatchedIngredient(i)
                      ? AfaChipTone.positive
                      : AfaChipTone.neutral,
                ),
            ],
          ),
        ],
        if (p.sourceUrl != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.source, style: text.titleSmall),
          SelectableText(p.sourceUrl!, style: text.bodySmall),
        ],
      ],
    );
  }
}
