import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:material_ui/material_ui.dart';

/// Quatrefoil badge with an icon in the middle; used for illustrations and
/// empty/error states.
class QuatrefoilIcon extends StatelessWidget {
  const QuatrefoilIcon({
    required this.icon,
    super.key,
    this.size = 96,
    this.color = AppColors.white,
    this.iconColor = AppColors.ink,
    this.borderColor = AppColors.sage,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => QuatrefoilShape(
    size: size,
    color: color,
    borderColor: borderColor,
    child: Center(
      child: Icon(icon, size: size * 0.42, color: iconColor),
    ),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = AppStrings.loading});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuatrefoilLoader(size: 72, semanticLabel: message),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    super.key,
    this.body,
    this.icon = Icons.spa_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuatrefoilIcon(icon: icon),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(body!, style: text.bodyMedium, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AfaButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, super.key, this.onRetry});

  /// A `Failure` shows its friendly message; anything else a generic one.
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is Failure
        ? (error as Failure).message
        : AppStrings.errorUnknown;
    final offline = error is NetworkFailure;
    return EmptyView(
      title: message,
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      actionLabel: onRetry == null ? null : AppStrings.retry,
      onAction: onRetry,
    );
  }
}
