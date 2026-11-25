import 'dart:async';
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
import 'package:afaskin/features/analysis/lesion_areas.dart';
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
    final sides = ref.watch(latestAnalysisSidePhotosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.resultTitle)),
      body: r == null
          ? const EmptyView(title: AppStrings.historyEmptyTitle)
          : ResultView(
              result: r,
              photo: photo?.analysisId == r.analysisId ? photo!.jpeg : null,
              sidePhotos: sides?.analysisId == r.analysisId
                  ? sides!.jpegs
                  : const <Uint8List>[],
            ),
    );
  }
}

class ResultView extends StatefulWidget {
  const ResultView({
    required this.result,
    super.key,
    this.photo,
    this.sidePhotos = const [],
  });

  final AnalysisResult result;

  /// Front photo of this analysis (memory only), drawn under the face map.
  final Uint8List? photo;

  /// Foto samping (memory only) — ikut dipakai sorotan area.
  final List<Uint8List> sidePhotos;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  SkinConditionLabel? _selected;

  /// Area lesi yang sedang disorot. Kotak di peta dan kartu sorotan memakai
  /// id yang sama, sehingga ketukan pada kotak bisa menunjuk kartu yang tepat,
  /// bukan hanya kondisi yang sama.
  String? _selectedAreaId;

  /// Penanda bagian sorotan, dipakai untuk menggulir halaman ke sana saat
  /// sebuah kotak lesi ditekan.
  final GlobalKey _closeupKey = GlobalKey();

  /// Menyorot satu kondisi (dari kartu kondisi, kartu sorotan, atau peta).
  void _selectCondition(SkinConditionLabel? label, List<SkinCondition> conditions) {
    setState(() {
      // Ketukan pada kondisi yang sama melepas sorotan.
      _selected = label != null && _selected != label ? label : null;
      // Sorotan kondisi tidak menunjuk area tertentu.
      _selectedAreaId = null;
    });
  }

  /// Menyorot satu **area** lesi, lalu menggulir halaman ke sorotan area itu.
  ///
  /// Dipakai saat kotak lesi di peta ditekan: pengguna langsung dibawa ke
  /// potongan foto area yang sama, bukan hanya ke kondisi yang sama.
  void _selectArea(LesionArea area, List<SkinCondition> conditions) {
    final sama = _selectedAreaId == area.id;
    setState(() {
      _selectedAreaId = sama ? null : area.id;
      _selected = sama ? null : area.label;
    });
    if (sama) return;
    // Gulir setelah kerangka diperbarui, supaya posisi kartu sudah final.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _closeupKey.currentContext;
      if (ctx != null) {
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            alignment: 0.1,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final text = Theme.of(context).textTheme;
    final conditions = r.conditionsByProbability;
    final needsDoctor = conditions.any(
      (c) => c.label.suggestsDermatologist && c.probability >= 0.3,
    );

    // Area lesi: satu kotak per area (beberapa deteksi berdekatan digabung).
    // Dihitung sekali di sini supaya peta dan sorotan memakai identitas yang
    // sama, sehingga ketukan pada kotak menunjuk kartu yang benar.
    final areas = buildLesionAreas(conditions);
    final areasDepan = [
      for (final a in areas)
        if (a.viewIndex == 0) a,
    ];
    final adaLesi = areas.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    areas: areasDepan,
                    selectedAreaId: _selectedAreaId,
                    onTapArea: (a) => _selectArea(a, conditions),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Legenda warna gumpalan; label kondisi singkat agar tidak
              // menabrak gumpalan di atasnya.
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xxs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final c in conditions)
                    _LegendChip(
                      label: AppStrings.condition(c.label),
                      color:
                          AppColors.conditionColor(c.label.name),
                      selected: _selected == c.label,
                      // Jumlah kotak yang benar-benar tergambar untuk warna
                      // ini, bukan jumlah spot mentah. Sebelumnya chip memakai
                      // `c.spots.length` sementara peta memakai `areas` yang
                      // sudah digabung, sehingga chip menulis "4" padahal peta
                      // menggambar 2 kotak.
                      count: areasDepan.where((a) => a.label == c.label).length,
                    ),
                ],
              ),
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
        if (adaLesi) ...[
          const SizedBox(height: AppSpacing.lg),
          // Penanda gulir: menekan kotak lesi membawa pengguna ke sini.
          Column(
            key: _closeupKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.closeupHeading, style: text.titleLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(AppStrings.closeupHint, style: text.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              ProblemCloseups(
                photo: widget.photo,
                sidePhotos: widget.sidePhotos,
                areas: areas,
                selectedAreaId: _selectedAreaId,
                onTapArea: (a) => _selectArea(a, conditions),
              ),
            ],
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
            onTap: () => _selectCondition(
              _selected == c.label ? null : c.label,
              conditions,
            ),
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
      ),
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

/// Chip legenda warna gumpalan: titik warna + nama kondisi.
class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    required this.selected,
    this.count = 0,
  });

  final String label;
  final Color color;
  final bool selected;

  /// Jumlah area lesi dengan warna ini; 0 = tidak ditampilkan.
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.dangerTint : AppColors.mist,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppColors.danger : AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(child: Text(label, style: text.labelMedium, overflow: TextOverflow.ellipsis)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: text.labelSmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
