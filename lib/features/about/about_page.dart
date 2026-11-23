import 'package:afaskin/core/config/app_info.dart';
import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Backend model version, shown so testers know which model answered.
final FutureProvider<HealthStatus> backendHealthProvider =
    FutureProvider.autoDispose<HealthStatus>(
      (ref) => ref.watch(analysisRepositoryProvider).health(),
    );

/// Version, team, dataset/model/font attributions (CC BY 4.0 requires it).
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final health = ref.watch(backendHealthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Center(child: AfaLogo(height: 48)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppStrings.version} ${AppInfo.version}',
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            switch (health) {
              AsyncData(:final value) => AppStrings.modelVersion(
                value.modelVersion,
              ),
              AsyncError() => AppStrings.serverUnreachable,
              _ => AppStrings.loading,
            },
            style: text.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.disclaimerShort,
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.teamHeading, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppInfo.course, style: text.titleMedium),
                Text(AppInfo.team, style: text.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(AppStrings.membersHeading, style: text.titleSmall),
                for (final (name, nim) in AppInfo.members)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text('•  $name', style: text.bodyMedium),
                        ),
                        if (nim.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            nim,
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.modelHeading, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppInfo.modelSummary,
                  style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ModelTable(rows: AppInfo.modelTable),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppInfo.modelFooter,
                  style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppInfo.faceDetectionTitle, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            child: Text(AppInfo.faceDetectionBody, style: text.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.attributionHeading, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, (title, body))
                    in AppStrings.attributions.indexed) ...[
                  if (i > 0) const Divider(height: AppSpacing.lg),
                  Text(title, style: text.titleSmall),
                  Text(body, style: text.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AfaButton.secondary(
            label: AppStrings.openSourceLicenses,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppStrings.appName,
              applicationVersion: AppInfo.version,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabel status model: tugas di kiri, model di tengah, hasil uji di kanan.
///
/// Memakai [Table] dengan lebar kolom proporsional, bukan [DataTable], karena
/// DataTable memaksa lebar minimum yang membuat tabel meluber di layar 360 dp.
class _ModelTable extends StatelessWidget {
  const _ModelTable({required this.rows});

  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final head = text.labelMedium?.copyWith(color: AppColors.inkMuted);
    final cell = text.bodySmall;

    TableRow buildRow((String, String, String) r, {bool header = false}) {
      return TableRow(
        decoration: header
            ? null
            : const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: Text(r.$1, style: header ? head : cell),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: Text(
              r.$2,
              style: header
                  ? head
                  : cell?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              r.$3,
              style: header
                  ? head
                  : cell?.copyWith(color: AppColors.positive),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.25),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(0.85),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        buildRow(
          (
            AppInfo.tableTaskHeader,
            AppInfo.tableModelHeader,
            AppInfo.tableMetricHeader,
          ),
          header: true,
        ),
        for (final r in rows) buildRow(r),
      ],
    );
  }
}
