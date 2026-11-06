import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(sessionProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.consent);
  }

  void _next() {
    if (_page == _pageCount - 1) {
      unawaited(_finish());
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_page + 1);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pageCount - 1;
    return Scaffold(
      body: AfaBackdrop(
        style: BackdropStyle.bubbles,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppSpacing.minTouchTarget,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: SegmentedProgress(
                          count: _pageCount,
                          filled: _page + 1,
                          height: 4,
                          semanticsLabel: AppStrings.onboardingPageLabel(
                            _page + 1,
                            _pageCount,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => unawaited(_finish()),
                        child: const Text(AppStrings.skip),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: const [_IntroPage(), _HowPage(), _TipsPage()],
                  ),
                ),
                AfaButton(
                  label: isLast ? AppStrings.start : AppStrings.next,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Illustration on top, big title + body below, vertically centered.
class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.art,
    required this.title,
    required this.body,
  });

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              art,
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: text.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(body, style: text.bodyLarge),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) => const _OnboardingContent(
    title: AppStrings.onboarding1Title,
    body: AppStrings.onboarding1Body,
    art: Center(
      child: SizedBox(
        width: 300,
        height: 280,
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 20,
              child: QuatrefoilShape(size: 150, color: AppColors.white),
            ),
            Positioned(right: 10, top: 0, child: QuatrefoilShape(size: 120)),
            Positioned(
              left: 60,
              bottom: 0,
              child: QuatrefoilShape(size: 110, color: AppColors.ink),
            ),
            Positioned(
              right: 30,
              bottom: 20,
              child: QuatrefoilShape(size: 130, color: AppColors.outline),
            ),
            Positioned(left: 62, top: 50, child: AlfaMascot(size: 180)),
          ],
        ),
      ),
    ),
  );
}

class _HowPage extends StatelessWidget {
  const _HowPage();

  static const List<(IconData, Color)> _icons = [
    (Icons.photo_camera_outlined, AppColors.sage),
    (Icons.search_rounded, AppColors.sage),
    (Icons.water_drop_outlined, AppColors.ink),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _OnboardingContent(
      title: AppStrings.onboarding2Title,
      body: AppStrings.onboarding2Body,
      art: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.cardAll,
        ),
        child: Column(
          children: [
            for (final (i, (title, body))
                in AppStrings.onboarding2Steps.indexed) ...[
              if (i > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 2,
                    height: 16,
                    margin: const EdgeInsets.only(left: 27),
                    color: AppColors.outline,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    QuatrefoilTile(
                      icon: _icons[i].$1,
                      size: 56,
                      color: _icons[i].$2,
                      iconColor: AppColors.white,
                      iconSize: 26,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: text.titleMedium),
                          Text(
                            body,
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TipsPage extends StatelessWidget {
  const _TipsPage();

  static const List<IconData> _icons = [
    Icons.wb_sunny_outlined,
    Icons.water_drop_outlined,
    Icons.visibility_off_outlined,
    Icons.smartphone_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget tip(int i) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuatrefoilTile(icon: _icons[i], iconSize: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(AppStrings.onboarding3Tips[i], style: text.bodyMedium),
        ],
      ),
    );
    return _OnboardingContent(
      title: AppStrings.onboarding3Title,
      body: AppStrings.onboarding3Body,
      art: Column(
        children: [
          for (final row in const [
            [0, 1],
            [2, 3],
          ]) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tip(row[0])),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: tip(row[1])),
                ],
              ),
            ),
            if (row[0] == 0) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
