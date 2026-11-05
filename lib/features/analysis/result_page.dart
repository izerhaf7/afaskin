import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Minimal result screen; the full version (ROI map, conditions,
/// recommendations) is built in Phase 3.
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(latestAnalysisProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analysisDoneTitle)),
      body: result == null
          ? const EmptyView(title: AppStrings.historyEmptyTitle)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AfaCard(
                  child: Text(
                    '${result.skinType.label.name} · '
                    '${formatPercent(result.skinType.confidence)}',
                    style: text.headlineMedium,
                  ),
                ),
              ],
            ),
    );
  }
}
