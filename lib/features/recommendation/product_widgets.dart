import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Product photo with a quatrefoil placeholder while loading or on error.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, super.key, this.size = 88});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.mist,
      child: Center(
        child: QuatrefoilIcon(
          icon: Icons.spa_outlined,
          size: size * 0.6,
          borderColor: null,
        ),
      ),
    );
    return Semantics(
      image: true,
      label: AppStrings.productImage,
      child: ClipRRect(
        borderRadius: AppRadius.inputAll,
        child: SizedBox.square(
          dimension: size,
          child: url == null || url!.isEmpty
              ? placeholder
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => placeholder,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : placeholder,
                ),
        ),
      ),
    );
  }
}

/// "82% cocok" badge: ink text on a sage wash.
class MatchBadge extends StatelessWidget {
  const MatchBadge({required this.score, super.key});

  final double score;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: AppColors.sageTint,
      borderRadius: AppRadius.pillAll,
    ),
    child: Text(
      AppStrings.matchScore(formatPercent(score)),
      style: Theme.of(context).textTheme.labelSmall,
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = product;
    return AfaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(url: p.imageUrl),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.brand} · ${AppStrings.category(p.category)}',
                  style: text.bodySmall,
                ),
                Text(p.name, style: text.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(formatRupiah(p.price), style: text.titleSmall),
                    MatchBadge(score: p.matchScore),
                  ],
                ),
                if (p.hasWarnings) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const AfaChip(
                    label: AppStrings.hasWarning,
                    tone: AfaChipTone.danger,
                    icon: Icons.warning_amber_rounded,
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

/// Danger banner listing ingredient conflicts.
class ConflictBanner extends StatelessWidget {
  const ConflictBanner({required this.warnings, super.key});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.statusTint(AppColors.danger),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppStrings.conflictHeading,
                  style: text.titleMedium?.copyWith(color: AppColors.danger),
                ),
              ),
            ],
          ),
          for (final w in warnings) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(w, style: text.bodyMedium?.copyWith(color: AppColors.danger)),
          ],
        ],
      ),
    );
  }
}
