import 'package:afaskin/core/l10n/app_strings.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.face_outlined),
            selectedIcon: Icon(Icons.face_rounded),
            label: AppStrings.tabAnalysis,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: AppStrings.tabHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }
}
