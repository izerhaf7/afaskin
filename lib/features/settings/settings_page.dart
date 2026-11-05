import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Pengaturan" tab. Clear-data and About are completed in Phase 4.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AfaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.settingsEditProfile,
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _Tile(
                  icon: Icons.quiz_outlined,
                  label: AppStrings.settingsRedoQuestionnaire,
                  onTap: () => context.push(AppRoutes.editQuestionnaire),
                ),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _Tile(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.settingsAbout,
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.md),
            AfaCard(
              padding: EdgeInsets.zero,
              child: _Tile(
                icon: Icons.palette_outlined,
                label: AppStrings.openStyleGuide,
                onTap: () => context.push(AppRoutes.styleGuide),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    leading: Icon(icon),
    title: Text(label, style: Theme.of(context).textTheme.titleMedium),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
