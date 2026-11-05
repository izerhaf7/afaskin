import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/state_views.dart';
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
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.jumpToPage(_page + 1);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pageCount - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: isLast
                    ? const SizedBox(height: AppSpacing.minTouchTarget)
                    : TextButton(
                        onPressed: _finish,
                        child: const Text(AppStrings.skip),
                      ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [_IntroPage(), _HowPage(), _TipsPage()],
              ),
            ),
            _Dots(count: _pageCount, index: _page),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AfaButton(
                label: isLast ? AppStrings.start : AppStrings.next,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppStrings.onboardingPageLabel(index + 1, count),
    child: ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppColors.sage : AppColors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Shared page layout: illustration, title, then free content.
class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    child: Column(
      children: [
        QuatrefoilIcon(icon: icon, size: 140),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    ),
  );
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) => _OnboardingContent(
    icon: Icons.face_retouching_natural_rounded,
    title: AppStrings.onboarding1Title,
    child: Text(
      AppStrings.onboarding1Body,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    ),
  );
}

class _HowPage extends StatelessWidget {
  const _HowPage();

  static const List<IconData> _icons = [
    Icons.photo_camera_outlined,
    Icons.insights_rounded,
    Icons.shopping_bag_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _OnboardingContent(
      icon: Icons.auto_awesome_outlined,
      title: AppStrings.onboarding2Title,
      child: Column(
        children: [
          for (final (i, (title, body)) in AppStrings.onboarding2Steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AfaCard(
                child: Row(
                  children: [
                    QuatrefoilIcon(
                      icon: _icons[i],
                      size: 48,
                      color: AppColors.mist,
                      borderColor: null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. $title', style: text.titleMedium),
                          Text(body, style: text.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TipsPage extends StatelessWidget {
  const _TipsPage();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _OnboardingContent(
      icon: Icons.wb_sunny_outlined,
      title: AppStrings.onboarding3Title,
      child: AfaCard(
        child: Column(
          children: [
            for (final tip in AppStrings.onboarding3Tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.positive,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(tip, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
