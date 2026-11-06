import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Splits `"Judul: isi"` into (title, body); no colon -> (null, text).
(String?, String) splitTitled(String text) {
  final i = text.indexOf(': ');
  if (i <= 0 || i > 60) return (null, text);
  return (text.substring(0, i), text.substring(i + 2));
}

/// Diagonal mist stripes: the design's product-photo placeholder.
class StripePlaceholder extends StatelessWidget {
  const StripePlaceholder({super.key, this.stripe = 10, this.caption});

  final double stripe;
  final String? caption;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _StripePainter(stripe),
    child: caption == null
        ? const SizedBox.expand()
        : Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 11, color: AppColors.inkMuted),
              ),
            ),
          ),
  );
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.stripe);

  final double stripe;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = AppColors.mist)
      ..save()
      ..clipRect(Offset.zero & size);
    final p = Paint()
      ..color = AppColors.mistStripe
      ..strokeWidth = stripe;
    // 135deg stripes: lines running from top-right to bottom-left.
    final step = stripe * 2 * 1.4142;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.stripe != stripe;
}

/// Product photo, striped placeholder while loading or when missing.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, super.key, this.caption});

  final String? url;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final placeholder = StripePlaceholder(caption: caption);
    return Semantics(
      image: true,
      label: AppStrings.productImage,
      child: url == null || url!.isEmpty
          ? placeholder
          : Image.network(
              url!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => placeholder,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder,
            ),
    );
  }
}

/// "92% cocok": positive text on a positive tint (5.0:1).
class MatchBadge extends StatelessWidget {
  const MatchBadge({required this.score, super.key, this.large = false});

  final double score;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    height: large ? 32 : 28,
    padding: EdgeInsets.symmetric(horizontal: large ? 12 : 10),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppColors.positiveTint,
      borderRadius: AppRadius.pillAll,
    ),
    child: Text(
      AppStrings.matchScore(formatPercent(score)),
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: AppColors.positive, fontSize: large ? 14 : 13),
    ),
  );
}

/// Grid card: photo with match badge, brand · category, name, price.
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = product;
    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardAll,
        side: BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    url: p.imageUrl,
                    caption: AppStrings.productPhoto,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: MatchBadge(score: p.matchScore),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.brand} · ${AppStrings.category(p.category)}',
                    style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    p.name,
                    style: text.titleSmall?.copyWith(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(formatRupiah(p.price), style: text.bodyLarge),
                  if (p.hasWarnings) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            AppStrings.hasConflict,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Danger banner: warning title in danger, explanation in ink.
class ConflictBanner extends StatelessWidget {
  const ConflictBanner({required this.warnings, super.key});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: AppStrings.conflictHeading,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.dangerTint,
          borderRadius: AppRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, w) in warnings.indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              Builder(
                builder: (context) {
                  final (title, body) = splitTitled(w);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title ?? AppStrings.conflictHeading,
                              style: text.titleMedium?.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(body, style: text.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Budget options in the sheet (0 = "Semua harga").
const List<int> kBudgetSheetOptions = [0, 50000, 100000, 150000, 300000];

/// "Budget per produk" sheet. Returns the chosen budget via [onPick]
/// (null = "Semua harga").
class BudgetSheet extends StatelessWidget {
  const BudgetSheet({required this.current, required this.onPick, super.key});

  /// Active budget, or null when the filter is off.
  final int? current;
  final ValueChanged<int?> onPick;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = {...kBudgetSheetOptions, ?current}.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppStrings.budgetSheetTitle, style: text.headlineMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.budgetSheetBody,
          style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final v in options) ...[
          ChoiceTile(
            label: v == 0
                ? AppStrings.anyPrice
                : AppStrings.maxPrice(formatRupiah(v)),
            selected: v == 0 ? current == null : current == v,
            onTap: () => onPick(v == 0 ? null : v),
            height: 56,
            radius: 16,
            outlineWhenIdle: true,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

/// Opens [BudgetSheet] and applies the choice through [apply].
Future<void> openBudgetSheet(
  BuildContext context, {
  required int? current,
  required Future<void> Function(int? budget) apply,
}) => showAfaSheet<void>(
  context,
  builder: (sheet) => BudgetSheet(
    current: current,
    onPick: (v) {
      Navigator.pop(sheet);
      unawaited(apply(v));
    },
  ),
);
