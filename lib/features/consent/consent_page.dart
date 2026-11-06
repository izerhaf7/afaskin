import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/flow_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Medical disclaimer + photo privacy. Both cards must be ticked.
/// With [review] (from Settings) it only shows the accepted terms.
class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key, this.review = false});

  final bool review;

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  late bool _medical = widget.review;
  late bool _photo = widget.review;
  bool _saving = false;

  Future<void> _accept() async {
    setState(() => _saving = true);
    await ref.read(sessionProvider.notifier).acceptConsent();
    if (mounted) context.go(AppRoutes.setupProfile);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FlowScaffold(
      topBar: widget.review
          ? Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-12, 0),
                child: IconButton(
                  tooltip: AppStrings.back,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
            )
          : null,
      ctaLabel: widget.review ? AppStrings.back : AppStrings.consentAccept,
      ctaLoading: _saving,
      onCta: widget.review
          ? () => context.pop()
          : _medical && _photo
          ? _accept
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: widget.review ? 0 : AppSpacing.lg),
          const QuatrefoilTile(
            icon: Icons.verified_user_outlined,
            size: 72,
            color: AppColors.sage,
            iconColor: AppColors.white,
            iconSize: 32,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            widget.review
                ? AppStrings.consentReviewTitle
                : AppStrings.consentTitle,
            style: text.displayLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.review
                ? AppStrings.consentAccepted
                : AppStrings.consentIntro,
            style: text.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ConsentCard(
            key: const Key('consent_medical'),
            title: AppStrings.consentMedicalTitle,
            body: AppStrings.consentMedicalBody,
            icon: Icons.medical_services_outlined,
            checked: _medical,
            onChanged: widget.review
                ? null
                : (v) => setState(() => _medical = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConsentCard(
            key: const Key('consent_photo'),
            title: AppStrings.consentPhotoTitle,
            body: AppStrings.consentPhotoBody,
            icon: Icons.lock_outline_rounded,
            checked: _photo,
            onChanged: widget.review ? null : (v) => setState(() => _photo = v),
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AlfaMascot(size: 96),
              SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 52),
                  child: SpeechBubble(
                    compact: true,
                    child: Text(AppStrings.consentAlfa),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Whole card is the checkbox (large touch target).
class ConsentCard extends StatelessWidget {
  const ConsentCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.checked,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool checked;

  /// Null = read-only.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      checked: checked,
      enabled: onChanged != null,
      label: '$title. $body',
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardAll,
            side: BorderSide(
              color: checked ? AppColors.sage : AppColors.white,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(!checked),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: checked ? AppColors.ink : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: checked
                          ? null
                          : Border.all(color: AppColors.outline, width: 1.5),
                    ),
                    child: checked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          body,
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  QuatrefoilTile(icon: icon, iconSize: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
