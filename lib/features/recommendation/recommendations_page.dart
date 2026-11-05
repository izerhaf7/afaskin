import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/profile/profile_page.dart';
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

  /// Starts at the profile budget; null = any price.
  late int? _maxPrice = ref.read(sessionProvider).profile?.budgetMax;

  void _reset() => setState(() {
    _category = null;
    _maxPrice = null;
  });

  @override
  Widget build(BuildContext context) {
    final provider = recommendationsProvider(
      analysisId: widget.analysisId,
      category: _category,
      maxPrice: _maxPrice,
    );
    final async = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recommendationsTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterRow(
            children: [
              AfaChip(
                label: AppStrings.allCategories,
                selected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              for (final c in _categories)
                AfaChip(
                  label: AppStrings.category(c),
                  selected: _category == c,
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
          _FilterRow(
            children: [
              AfaChip(
                label: AppStrings.anyPrice,
                selected: _maxPrice == null,
                onTap: () => setState(() => _maxPrice = null),
              ),
              for (final b in kBudgetOptions)
                AfaChip(
                  label: AppStrings.budgetUpTo(formatRupiah(b)),
                  selected: _maxPrice == b,
                  onTap: () => setState(() => _maxPrice = b),
                ),
            ],
          ),
          const Divider(),
          Expanded(
            child: switch (async) {
              AsyncData(:final value) when value.isEmpty => EmptyView(
                title: AppStrings.recommendationsEmpty,
                body: AppStrings.recommendationsEmptyBody,
                icon: Icons.filter_alt_off_outlined,
                actionLabel: AppStrings.resetFilters,
                onAction: _reset,
              ),
              AsyncData(:final value) => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: value.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, i) => ProductCard(
                  product: value[i],
                  onTap: () => context.push(AppRoutes.product(value[i].id)),
                ),
              ),
              AsyncError(:final error) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(provider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrolling chip row.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Row(
      children: [
        for (final c in children)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: c,
          ),
      ],
    ),
  );
}
