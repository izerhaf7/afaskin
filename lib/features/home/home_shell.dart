import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom navigation: Analisis, Riwayat, Pengaturan. Each tab keeps its own
/// navigation stack (StatefulShellRoute).
class HomeShell extends StatelessWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.center_focus_weak_rounded),
              label: AppStrings.tabAnalysis,
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              label: AppStrings.tabHistory,
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded),
              label: AppStrings.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
