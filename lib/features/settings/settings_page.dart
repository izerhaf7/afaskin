import 'dart:async';

import 'package:afaskin/core/config/app_info.dart';
import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:afaskin/features/settings/avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Profile summary line: "Rani · 23 tahun · Perempuan" (+ "belum lengkap").
String profileLine(SessionState s) {
  final parts = <String>[
    if ((s.name ?? '').trim().isNotEmpty) s.name!.trim(),
    '${s.profile?.age ?? '–'} ${AppStrings.ageSuffix}',
    if (s.profile?.gender case final g?)
      switch (g) {
        Gender.female => AppStrings.genderFemale,
        Gender.male => AppStrings.genderMale,
        Gender.unspecified => AppStrings.genderUnspecified,
      },
    if (!s.profileComplete) AppStrings.incomplete,
  ];
  return parts.join(' · ');
}

/// "Pengaturan" tab.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final ok = await showAfaSheet<bool>(
      context,
      builder: (sheet) {
        final text = Theme.of(sheet).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: text.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: text.bodyLarge?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 20),
            AfaButton(
              label: AppStrings.delete,
              variant: AfaButtonVariant.danger,
              onPressed: () => Navigator.pop(sheet, true),
            ),
            const SizedBox(height: AppSpacing.sm),
            AfaButton.secondary(
              label: AppStrings.cancel,
              onPressed: () => Navigator.pop(sheet, false),
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final n = ref.read(historyProvider).length;
    if (n == 0) {
      showAfaToast(context, AppStrings.historyAlreadyEmpty);
      return;
    }
    final ok = await _confirm(
      context,
      title: AppStrings.clearHistoryTitle,
      body: AppStrings.clearHistoryBody(n),
    );
    if (!ok) return;
    await ref.read(historyProvider.notifier).clear();
    await ref.read(profileStoreProvider).clear();
    if (context.mounted) showAfaToast(context, AppStrings.deleted);
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: AppStrings.clearAllDataTitle,
      body: AppStrings.clearAllDataBody,
    );
    if (!ok) return;
    ref.read(pendingPhotoProvider.notifier).clear();
    ref.read(pendingSidePhotosProvider.notifier).clear();
    ref.read(latestAnalysisPhotoProvider.notifier).clear();
    await ref.read(historyProvider.notifier).clear();
    await ref.read(profileStoreProvider).clear();
    // Resetting the session makes the router send the user to onboarding.
    await ref.read(sessionProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final s = ref.watch(sessionProvider);
    final session = ref.read(sessionProvider.notifier);
    final budget = s.activeBudget;

    return Scaffold(
      body: AfaBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Text(AppStrings.settingsTitle, style: text.displayLarge),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  20,
                  AppSpacing.md,
                  0,
                ),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.cardAll,
                ),
                child: Row(
                  children: [
                    AvatarFoil(
                      initial: s.initial,
                      size: 64,
                      fill: AppColors.mist,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.skinProfile, style: text.titleMedium),
                          Text(
                            profileLine(s),
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: text.labelMedium,
                      ),
                      onPressed: () => context.push(AppRoutes.editProfile),
                      child: const Text(AppStrings.change),
                    ),
                  ],
                ),
              ),
              const _SectionLabel(AppStrings.preferences),
              _Group(
                children: [
                  _Row(
                    icon: Icons.payments_outlined,
                    label: AppStrings.budgetSheetTitle,
                    value: budget == null
                        ? AppStrings.anyPrice
                        : formatRupiah(budget),
                    onTap: () => unawaited(
                      openBudgetSheet(
                        context,
                        current: budget,
                        apply: session.setBudgetFilter,
                      ),
                    ),
                  ),
                  _Row(
                    icon: Icons.notifications_none_rounded,
                    label: AppStrings.reminder,
                    subtitle: AppStrings.reminderEvery,
                    trailing: Switch(
                      value: s.reminderOn,
                      onChanged: (v) => unawaited(session.setReminder(on: v)),
                    ),
                    onTap: () =>
                        unawaited(session.setReminder(on: !s.reminderOn)),
                    toggled: s.reminderOn,
                  ),
                  _Row(
                    icon: Icons.language_rounded,
                    label: AppStrings.language,
                    value: AppStrings.languageValue,
                    onTap: () =>
                        showAfaToast(context, AppStrings.moreLanguagesSoon),
                  ),
                  _Row(
                    icon: Icons.quiz_outlined,
                    label: AppStrings.settingsRedoQuestionnaire,
                    onTap: () => context.push(AppRoutes.editQuestionnaire),
                  ),
                ],
              ),
              const _SectionLabel(AppStrings.privacyData),
              _Group(
                children: [
                  const _Row(
                    icon: Icons.verified_user_outlined,
                    label: AppStrings.photoNotStored,
                    subtitle: AppStrings.photoNotStoredBody,
                  ),
                  _Row(
                    icon: Icons.delete_outline_rounded,
                    label: AppStrings.clearHistory,
                    danger: true,
                    onTap: () => unawaited(_clearHistory(context, ref)),
                  ),
                  _Row(
                    icon: Icons.delete_forever_outlined,
                    label: AppStrings.clearAllData,
                    danger: true,
                    onTap: () => unawaited(_clearAll(context, ref)),
                  ),
                ],
              ),
              const _SectionLabel(AppStrings.others),
              _Group(
                children: [
                  _Row(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.aboutApp,
                    onTap: () => context.push(AppRoutes.about),
                  ),
                  _Row(
                    icon: Icons.description_outlined,
                    label: AppStrings.consentReviewTitle,
                    onTap: () => context.push(AppRoutes.consentReview),
                  ),
                  if (kDebugMode)
                    _Row(
                      icon: Icons.palette_outlined,
                      label: AppStrings.openStyleGuide,
                      onTap: () => context.push(AppRoutes.styleGuide),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  AppStrings.appVersion(AppInfo.version),
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: AppColors.inkMuted),
      ),
    ),
  );
}

/// White rounded group with dividers between rows.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(
      color: AppColors.white,
      borderRadius: AppRadius.cardAll,
    ),
    child: Column(
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) const Divider(height: 1),
          c,
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.toggled,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = danger ? AppColors.danger : AppColors.ink;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: text.bodyLarge?.copyWith(color: color)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                value!,
                style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
            ],
            if (trailing != null)
              ExcludeSemantics(child: trailing)
            else if (onTap != null && !danger)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.xxs),
                child: Icon(Icons.chevron_right_rounded),
              ),
          ],
        ),
      ),
    );
    if (onTap == null) return Semantics(container: true, child: content);
    return Semantics(
      button: toggled == null,
      toggled: toggled,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
