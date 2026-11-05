import 'package:afaskin/core/config/app_info.dart';
import 'package:afaskin/core/l10n/app_strings.dart';
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
                for (final m in AppInfo.members)
                  Text('•  $m', style: text.bodyMedium),
              ],
            ),
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
