import 'dart:typed_data';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/analysis/face_map.dart';
import 'package:afaskin/features/analysis/ingredient_section.dart';
import 'package:afaskin/features/analysis/problem_closeups.dart';
import 'package:afaskin/features/analysis/recommendation_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shows an analysis. Without [result] it shows the latest one (right after
/// analyzing); History passes a stored result.
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key, this.result});

  final AnalysisResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = result ?? ref.watch(latestAnalysisProvider);
    // The user's own photo exists (in memory) only for the latest analysis.
    final photo = ref.watch(latestAnalysisPhotoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.resultTitle)),
      body: r == null
          ? const EmptyView(title: AppStrings.historyEmptyTitle)
          : ResultView(
              result: r,
              photo: photo?.analysisId == r.analysisId ? photo!.jpeg : null,
            ),
    );
  }
}

class ResultView extends StatefulWidget {
  const ResultView({required this.result, super.key, this.photo});

  final AnalysisResult result;

  /// Front photo of this analysis (memory only), drawn under the face map.
  final Uint8List? photo;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  SkinConditionLabel? _selected;
  FaceRegion? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final text = Theme.of(context).textTheme;
    final conditions = r.conditionsByProbability;
    final highlighted = {for (final c in conditions) ...c.regions};
    final selected = conditions.where((c) => c.label == _selected).firstOrNull;
    final needsDoctor = conditions.any(
      (c) => c.label.suggestsDermatologist && c.probability >= 0.3,
    );

    // Nama kondisi per area, urut dari probabilitas tertinggi, dipakai untuk
    // memberi judul pada potongan close-up.
    final labelsByRegion = <FaceRegion, List<String>>{};
    for (final c in conditions) {
      final name = AppStrings.condition(c.label);
      for (final region in c.regions) {
        (labelsByRegion[region] ??= <String>[]).add(name);
      }
    }
    final selectedRegion = selected?.regions.firstOrNull ?? _selectedRegion;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        _SkinTypeCard(skinType: r.skinType),
        if (needsDoctor) ...[
          const SizedBox(height: AppSpacing.sm),
          const _DoctorBanner(),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.faceMapHeading, style: text.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        AfaCard(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.photo == null ? 240 : 300,
                  ),
                  child: FaceMap(
                    photo: widget.photo,
                    rois: r.rois,
                    highlighted: highlighted,
                    emphasized: selected?.regions.toSet() ?? const {},
                  ),
                ),
              ),
              if (highlighted.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                // Legend instead of labels inside the drawing (boxes such as
                // the nose are too narrow for text).
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.xxs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    for (final region in highlighted)
                      AfaChip(
                        label: AppStrings.region(region),
                        tone: (selected?.regions.contains(region) ?? false)
                            ? AfaChipTone.danger
                            : AfaChipTone.caution,
                      ),
                  ],
                ),
              ],
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.faceMapHint,
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        if (labelsByRegion.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.closeupHeading, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(AppStrings.closeupHint, style: text.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          ProblemCloseups(
            photo: widget.photo,
            rois: r.rois,
            labelsByRegion: labelsByRegion,
            selected: selectedRegion,
            onTapRegion: (region) => setState(() {
              _selectedRegion = _selectedRegion == region ? null : region;
              // Menyorot area juga menyorot kondisi yang ada di sana.
              final first = conditions
                  .where((c) => c.regions.contains(region))
                  .firstOrNull;
              _selected = _selectedRegion == null ? null : first?.label;
            }),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.conditionsHeading, style: text.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        if (conditions.isEmpty)
          AfaCard(
            child: Text(AppStrings.conditionsEmpty, style: text.bodyMedium),
          ),
        for (final c in conditions) ...[
          _ConditionCard(
            condition: c,
            selected: c.label == _selected,
            onTap: () => setState(() {
              _selected = _selected == c.label ? null : c.label;
              _selectedRegion = _selected == null
                  ? null
                  : c.regions.firstOrNull;
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.ingredientsNeededHeading, style: text.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(AppStrings.ingredientsHint, style: text.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        IngredientSection(conditions: conditions),
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.recommendationHeading, style: text.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(AppStrings.recommendationHint, style: text.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        RecommendationPreview(analysisId: r.analysisId),
        const SizedBox(height: AppSpacing.sm),
        AfaButton(
          label: AppStrings.viewAllProducts,
          icon: Icons.shopping_bag_outlined,
          onPressed: () =>
              context.push(AppRoutes.recommendations(r.analysisId)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(AppStrings.fusionNote(r.fusion.alpha), style: text.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(r.disclaimer, style: text.bodySmall),
      ],
    );
  }
}

class _SkinTypeCard extends StatelessWidget {
  const _SkinTypeCard({required this.skinType});

  final SkinTypeResult skinType;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final probs = skinType.probs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return AfaCard(
      shadow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.skinTypeHeading, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.xxs),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              Text(
                AppStrings.skinType(skinType.label),
                style: text.displayLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${formatPercent(skinType.confidence)} '
                  '${AppStrings.confidence}',
                  style: text.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final e in probs) ...[
            ProbabilityBar(
              label: AppStrings.skinTypeKey(e.key),
              value: e.value,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.condition,
    required this.selected,
    required this.onTap,
  });

  final SkinCondition condition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = condition;
    final description = (c.description?.trim().isNotEmpty ?? false)
        ? c.description!
        : AppStrings.conditionDescription(c.label);
    return AfaCard(
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProbabilityBar(
            label: AppStrings.condition(c.label),
            value: c.probability,
            labelStyle: text.titleMedium,
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: text.bodyMedium),
          ],
          if (c.regions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              children: [
                for (final region in c.regions)
                  AfaChip(
                    label: AppStrings.region(region),
                    icon: Icons.place_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorBanner extends StatelessWidget {
  const _DoctorBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.statusTint(AppColors.caution),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.caution.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_services_outlined, color: AppColors.caution),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dermatologistTitle,
                  style: text.titleMedium?.copyWith(color: AppColors.caution),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppStrings.dermatologistBody,
                  style: text.bodyMedium?.copyWith(color: AppColors.caution),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label + percentage + sage bar on an outline track.
class ProbabilityBar extends StatelessWidget {
  const ProbabilityBar({
    required this.label,
    required this.value,
    super.key,
    this.labelStyle,
  });

  final String label;
  final double value;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pct = formatPercent(value);
    return Semantics(
      label: AppStrings.percentOf(label, pct),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: labelStyle ?? text.bodyMedium),
                ),
                Text(pct, style: text.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
