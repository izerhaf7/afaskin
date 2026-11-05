import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Layout for setup and form screens: scrollable content with the main
/// action pinned at the bottom (stays reachable at 130% text scale and with
/// the keyboard open).
class SetupScaffold extends StatelessWidget {
  const SetupScaffold({
    required this.body,
    required this.bottom,
    super.key,
    this.title,
    this.top,
    this.showBack = false,
  });

  final String? title;

  /// Pinned above the scrolling body (e.g. a progress bar).
  final Widget? top;
  final Widget body;
  final Widget bottom;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null && !showBack
          ? null
          : AppBar(
              title: title == null ? null : Text(title!),
              automaticallyImplyLeading: showBack,
            ),
      body: SafeArea(
        child: Column(
          children: [
            ?top,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }
}
