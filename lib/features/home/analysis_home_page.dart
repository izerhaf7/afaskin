import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Analisis" tab: entry point for a new skin analysis.
class AnalysisHomePage extends StatelessWidget {
  const AnalysisHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AfaLogo(height: 28),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(AppStrings.greeting, style: text.bodyLarge),
            Text(AppStrings.homeTitle, style: text.displayLarge),
            const SizedBox(height: AppSpacing.lg),
            AfaCard(
              shadow: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      QuatrefoilShape(size: 132, color: AppColors.mist),
                      QuatrefoilIcon(
                        icon: Icons.photo_camera_front_outlined,
                        size: 84,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.homeBody,
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AfaButton(
                    label: AppStrings.startAnalysis,
                    icon: Icons.photo_camera_outlined,
                    onPressed: () => context.push(AppRoutes.capture),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AfaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.onboarding3Title, style: text.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  for (final tip in AppStrings.onboarding3Tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Text('•  $tip', style: text.bodyMedium),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
