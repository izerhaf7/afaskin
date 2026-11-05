import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'questionnaire_page.g.dart';

/// Questions come from `GET /questionnaire` (bundled fallback in the repo).
@riverpod
Future<Questionnaire> questionnaire(Ref ref) =>
    ref.watch(analysisRepositoryProvider).getQuestionnaire();

class QuestionnairePage extends ConsumerWidget {
  const QuestionnairePage({super.key, this.editing = false});

  /// Opened from Settings: pops back when done instead of going home.
  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(questionnaireProvider);
    return switch (async) {
      AsyncData(:final value) when value.questions.isEmpty => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.questionnaireTitle)),
        body: const EmptyView(title: AppStrings.questionnaireEmpty),
      ),
      AsyncData(:final value) => QuestionnaireFlow(
        questionnaire: value,
        editing: editing,
        initial: ref.read(sessionProvider).answers,
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.questionnaireTitle)),
        body: ErrorView(
          error: error,
          onRetry: () => ref.invalidate(questionnaireProvider),
        ),
      ),
      _ => const Scaffold(body: LoadingView()),
    };
  }
}

/// The step-by-step flow, split out so it can be tested with a fixed
/// questionnaire.
class QuestionnaireFlow extends ConsumerStatefulWidget {
  const QuestionnaireFlow({
    required this.questionnaire,
    super.key,
    this.editing = false,
    this.initial,
  });

  final Questionnaire questionnaire;
  final bool editing;

  /// Previously saved answers (pre-selected when retaking).
  final QuestionnaireAnswers? initial;

  @override
  ConsumerState<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends ConsumerState<QuestionnaireFlow> {
  int _index = 0;
  late final Map<String, int> _answers = {
    // Only keep old answers that still match a current question id.
    for (final e
        in widget.initial?.answers.entries ?? <MapEntry<String, int>>[])
      if (widget.questionnaire.questions.any((q) => q.id == e.key))
        e.key: e.value,
  };
  bool _saving = false;

  List<Question> get _questions => widget.questionnaire.questions;
  Question get _current => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  Future<void> _next() async {
    if (!_isLast) {
      setState(() => _index++);
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(sessionProvider.notifier)
        .saveAnswers(
          QuestionnaireAnswers(
            version: widget.questionnaire.version,
            answers: Map.of(_answers),
          ),
        );
    if (!mounted) return;
    if (widget.editing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.questionnaireSaved)),
      );
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
    } else if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = _questions.length;
    final question = _current;
    final selected = _answers[question.id];

    return PopScope(
      // System back steps through questions before leaving the flow.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.questionnaireTitle),
          automaticallyImplyLeading: false,
          leading: _index > 0 || context.canPop()
              ? IconButton(
                  tooltip: AppStrings.back,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _back,
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.questionProgress(_index + 1, total),
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadius.pillAll,
                      child: LinearProgressIndicator(
                        key: const Key('questionnaire_progress'),
                        value: (_index + 1) / total,
                        minHeight: 8,
                        semanticsLabel: AppStrings.questionnaireTitle,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey(question.id),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(question.text, style: text.titleLarge),
                      const SizedBox(height: AppSpacing.lg),
                      for (final v in question.scale.values) ...[
                        _LikertOption(
                          value: v,
                          label: v == question.scale.min
                              ? question.scale.minLabel
                              : v == question.scale.max
                              ? question.scale.maxLabel
                              : null,
                          selected: selected == v,
                          onTap: () =>
                              setState(() => _answers[question.id] = v),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: AfaButton(
                  label: _isLast ? AppStrings.finish : AppStrings.next,
                  loading: _saving,
                  onPressed: selected == null ? null : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikertOption extends StatelessWidget {
  const _LikertOption({
    required this.value,
    required this.selected,
    required this.onTap,
    this.label,
  });

  final int value;
  final String? label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AfaCard(
      selected: selected,
      onTap: onTap,
      semanticLabel: AppStrings.likertOption(value, label),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$value',
                style: text.titleMedium?.copyWith(
                  color: selected ? AppColors.white : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label ?? '', style: text.bodyLarge)),
            if (selected) const Icon(Icons.check_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
