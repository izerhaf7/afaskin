import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The first few product matches, shown right under the ingredient advice so
/// the reader goes condition → ingredient → product in one screen.
///
/// A vertical list, not a horizontal carousel: product names are long, so a
/// fixed-height card clips them. Cards let the height follow the content, the
/// same way the recommendations page lays them out. Products without a photo
/// fall back to the row layout, as everywhere else.
class RecommendationPreview extends ConsumerWidget {
  const RecommendationPreview({
    required this.analysisId,
    super.key,
    this.limit = 3,
  });

  final String analysisId;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final async = ref.watch(recommendationsProvider(analysisId: analysisId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) =>
          Text(AppStrings.errorLocalAnalysis, style: text.bodySmall),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final top = [...items]
          ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
        final shown = top.take(limit).toList();
        return Column(
          children: [
            for (final p in shown) ...[
              if (p.hasImage)
                ProductCard(
                  product: p,
                  onTap: () => context.push(AppRoutes.product(p.id)),
                )
              else
                ProductListTile(
                  product: p,
                  onTap: () => context.push(AppRoutes.product(p.id)),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}
