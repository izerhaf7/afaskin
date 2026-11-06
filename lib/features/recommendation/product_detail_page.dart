import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a store page in the browser. Overridable in tests.
final storeLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productDetailProvider(productId);
    final async = ref.watch(provider);
    return switch (async) {
      AsyncData(:final value) => ProductDetailView(product: value),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: AfaBackdrop(
          child: ErrorView(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
        ),
      ),
      _ => const Scaffold(body: AfaBackdrop(child: LoadingView())),
    };
  }
}

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({required this.product, super.key});

  final Product product;

  Future<void> _openStore(BuildContext context, WidgetRef ref) async {
    final url = product.sourceUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      showAfaToast(context, AppStrings.storeUnavailable);
      return;
    }
    showAfaToast(context, AppStrings.openingStore);
    final ok = await ref.read(storeLauncherProvider)(uri);
    if (!ok && context.mounted) {
      showAfaToast(context, AppStrings.storeUnavailable);
    }
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final added = await ref
        .read(sessionProvider.notifier)
        .toggleFavorite(product.id);
    if (context.mounted) {
      showAfaToast(
        context,
        added ? AppStrings.savedToFavorites : AppStrings.removedFromFavorites,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final p = product;
    final saved = ref.watch(sessionProvider).favorites.contains(p.id);
    final ingredients = p.ingredients ?? const <String>[];
    final muted = text.bodyMedium?.copyWith(color: AppColors.inkMuted);

    return Scaffold(
      backgroundColor: AppColors.mist,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  child: ProductImage(
                    url: p.imageUrl,
                    caption: '${AppStrings.productPhoto} · ${p.name}',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.sheetTop,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${p.brand} · ${AppStrings.category(p.category)}',
                          style: muted,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(p.name, style: text.headlineMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatRupiah(p.price),
                                style: text.bodyLarge?.copyWith(
                                  fontSize: 20,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            MatchBadge(score: p.matchScore, large: true),
                          ],
                        ),
                        if (p.hasWarnings) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ConflictBanner(warnings: p.warnings),
                        ],
                        if (p.reasons.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            AppStrings.whyRecommended,
                            style: text.titleLarge,
                          ),
                          for (final r in p.reasons) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _WhyRow(text: r),
                          ],
                        ],
                        if (ingredients.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.ingredientsHeading,
                                  style: text.titleLarge,
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.positive,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.goodForYou,
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final i in ingredients)
                                _IngredientChip(
                                  key: ValueKey('ingredient_$i'),
                                  name: i,
                                  matched: p.isMatchedIngredient(i),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          AppStrings.fictionalNote,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  _RoundButton(
                    tooltip: AppStrings.back,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  _RoundButton(
                    tooltip: saved
                        ? AppStrings.removedFromFavorites
                        : AppStrings.savedToFavorites,
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: saved ? AppColors.sage : AppColors.ink,
                    selected: saved,
                    onTap: () => unawaited(_toggleFavorite(context, ref)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: AfaButton(
                    label: AppStrings.openStore,
                    onPressed: () => unawaited(_openStore(context, ref)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyRow extends StatelessWidget {
  const _WhyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (title, body) = splitTitled(text);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: QuatrefoilShape(size: 24),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) Text(title, style: t.titleMedium),
              Text(
                body,
                style: title == null
                    ? t.bodyMedium
                    : t.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ingredient pill; relevant ones get the positive tint and a check.
class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.name, required this.matched, super.key});

  final String name;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: matched ? AppColors.positive : AppColors.ink);
    return Semantics(
      label: matched ? '$name, ${AppStrings.goodForYou}' : name,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: matched ? AppColors.positiveTint : AppColors.white,
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: matched ? AppColors.positiveTint : AppColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (matched) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.positive,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(child: Text(name, style: style)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48 dp white circle button floating over the hero image.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.color = AppColors.ink,
    this.selected,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool? selected;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: selected,
    child: IconButton.filled(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: color,
        fixedSize: const Size.square(48),
      ),
      icon: Icon(icon, size: 20),
    ),
  );
}
