import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/setup_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Medical disclaimer + photo privacy. Both boxes must be ticked.
class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key});

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool _medical = false;
  bool _photo = false;
  bool _saving = false;

  Future<void> _accept() async {
    setState(() => _saving = true);
    await ref.read(sessionProvider.notifier).acceptConsent();
    if (mounted) context.go(AppRoutes.setupProfile);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SetupScaffold(
      title: AppStrings.consentTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.consentIntro, style: text.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          _ConsentItem(
            icon: Icons.medical_services_outlined,
            title: AppStrings.consentMedicalTitle,
            body: AppStrings.consentMedicalBody,
            checkLabel: AppStrings.consentMedicalCheck,
            value: _medical,
            onChanged: (v) => setState(() => _medical = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ConsentItem(
            icon: Icons.lock_outline_rounded,
            title: AppStrings.consentPhotoTitle,
            body: AppStrings.consentPhotoBody,
            checkLabel: AppStrings.consentPhotoCheck,
            value: _photo,
            onChanged: (v) => setState(() => _photo = v),
          ),
        ],
      ),
      bottom: AfaButton(
        label: AppStrings.consentAccept,
        loading: _saving,
        onPressed: _medical && _photo ? _accept : null,
      ),
    );
  }
}

class _ConsentItem extends StatelessWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.checkLabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String body;
  final String checkLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AfaCard(
      selected: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.sage),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(title, style: text.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          // Whole row is the tap target, not just the 18 dp box.
          MergeSemantics(
            child: InkWell(
              borderRadius: AppRadius.inputAll,
              onTap: () => onChanged(!value),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTouchTarget,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: value,
                      onChanged: (v) => onChanged(v ?? false),
                    ),
                    Expanded(child: Text(checkLabel, style: text.bodyMedium)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
