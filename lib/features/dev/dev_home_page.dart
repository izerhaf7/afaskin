import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Temporary landing page for Phase 0.
class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AfaLogo(height: 56),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.tagline,
                  style: text.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.devHomeBody,
                  style: text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AfaButton(
                    label: AppStrings.openStyleGuide,
                    icon: Icons.palette_outlined,
                    onPressed: () => context.push(AppRoutes.styleGuide),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
