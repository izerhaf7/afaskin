import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Pengaturan" tab.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(AppStrings.clearDataTitle),
        content: const Text(AppStrings.clearDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    ref.read(pendingPhotoProvider.notifier).clear();
    await ref.read(historyProvider.notifier).clear();
    // Resetting the session makes the router send the user to onboarding.
    await ref.read(sessionProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(sessionProvider).profile;
    const divider = Divider(indent: AppSpacing.md, endIndent: AppSpacing.md);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(AppStrings.settingsAccountSection, style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.settingsEditProfile,
                  subtitle: profile == null
                      ? null
                      : '${profile.age} ${AppStrings.ageSuffix} · '
                            '${AppStrings.budgetUpTo(formatRupiah(profile.budgetMax))}',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                divider,
                _Tile(
                  icon: Icons.quiz_outlined,
                  label: AppStrings.settingsRedoQuestionnaire,
                  onTap: () => context.push(AppRoutes.editQuestionnaire),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(AppStrings.settingsDataSection, style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          AfaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.delete_forever_outlined,
                  label: AppStrings.settingsClearData,
                  danger: true,
                  onTap: () => _clearAll(context, ref),
                ),
                divider,
                _Tile(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.settingsAbout,
                  onTap: () => context.push(AppRoutes.about),
                ),
                if (kDebugMode) ...[
                  divider,
                  _Tile(
                    icon: Icons.palette_outlined,
                    label: AppStrings.openStyleGuide,
                    onTap: () => context.push(AppRoutes.styleGuide),
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      minTileHeight: 56,
      iconColor: color,
      leading: Icon(icon),
      title: Text(label, style: text.titleMedium?.copyWith(color: color)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: text.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
