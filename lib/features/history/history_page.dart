import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// "Riwayat" tab. Hive-backed list arrives in Phase 4.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.tabHistory)),
    body: const EmptyView(
      title: AppStrings.historyEmptyTitle,
      body: AppStrings.historyEmptyBody,
      icon: Icons.history_rounded,
    ),
  );
}
