import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/flow_scaffold.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
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

enum QuizMode {
  /// First run: ends at the camera.
  setup,

  /// "Perbarui jawaban dulu" before a new analysis: ends at the camera.
  beforeCapture,

  /// From Settings: saves and goes back.
  edit,
}

class QuestionnairePage extends ConsumerWidget {
  const QuestionnairePage({super.key, this.mode = QuizMode.setup});

  final QuizMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(questionnaireProvider);
    Widget plain(Widget body) => Scaffold(
      appBar: AppBar(title: const Text(AppStrings.questionnaireTitle)),
      body: AfaBackdrop(child: body),
    );
    return switch (async) {
      AsyncData(:final value) when value.questions.isEmpty => plain(
        const EmptyView(title: AppStrings.questionnaireEmpty),
      ),
      AsyncData(:final value) => QuestionnaireFlow(
        questionnaire: value,
        mode: mode,
        initial: ref.read(sessionProvider).answers,
      ),
      AsyncError(:final error) => plain(
        ErrorView(
          error: error,
          onRetry: () => ref.invalidate(questionnaireProvider),
        ),
      ),
      _ => const Scaffold(body: AfaBackdrop(child: LoadingView())),
    };
  }
}

/// The step-by-step flow, split out so it can be tested with a fixed
/// questionnaire.
class QuestionnaireFlow extends ConsumerStatefulWidget {
  const QuestionnaireFlow({
    required this.questionnaire,
    super.key,
    this.mode = QuizMode.setup,
    this.initial,
    this.autoAdvance = const Duration(milliseconds: 450),
  });

  final Questionnaire questionnaire;
  final QuizMode mode;

  /// Previously saved answers (pre-selected when retaking).
  final QuestionnaireAnswers? initial;

  /// Delay before moving on after an answer is picked.
  final Duration autoAdvance;

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
  Timer? _advance;

  List<Question> get _questions => widget.questionnaire.questions;
  Question get _current => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _pick(int value) {
    setState(() => _answers[_current.id] = value);
    _advance?.cancel();
    if (!_isLast) {
      final at = _index;
      _advance = Timer(widget.autoAdvance, () {
        if (mounted && _index == at) setState(() => _index++);
      });
    }
  }

  Future<void> _next() async {
    _advance?.cancel();
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
            answeredAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    switch (widget.mode) {
      case QuizMode.setup:
        // Home first, so "back" from the camera lands on the home tab.
        context.go(AppRoutes.capture);
      case QuizMode.beforeCapture:
        context.pushReplacement(AppRoutes.capture);
      case QuizMode.edit:
        showAfaToast(context, AppStrings.questionnaireSaved);
        context.pop();
    }
  }

  void _back() {
    _advance?.cancel();
    if (_index > 0) {
      setState(() => _index--);
    } else if (widget.mode == QuizMode.setup) {
      context.go(AppRoutes.setupProfile);
    } else if (context.canPop()) {
      context.pop();
    }
  }

  (AlfaMood, AlfaMotion) get _mood {
    final answered = _answers[_current.id] != null;
    if (answered) {
      return (
        _isLast ? AlfaMood.celebrate : AlfaMood.excited,
        AlfaMotion.squish,
      );
    }
    final idle = [AlfaMood.thinking, AlfaMood.happy, AlfaMood.focused];
    return (idle[_index % idle.length], AlfaMotion.bob);
  }

  String? get _lead {
    if (_index == 0 && widget.mode == QuizMode.setup) {
      final name = (ref.read(sessionProvider).name ?? '').trim();
      return AppStrings.quizLeadFirst(
        name.isEmpty ? AppStrings.you : name,
        _questions.length,
      );
    }
    if (_isLast && _questions.length > 1) return AppStrings.quizLeadLast;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = _questions.length;
    final question = _current;
    final selected = _answers[question.id];
    final (mood, motion) = _mood;
    final lead = _lead;

    return PopScope(
      // System back steps through questions before leaving the flow.
      canPop: _index == 0 && widget.mode != QuizMode.setup,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: FlowScaffold(
        topBar: FlowTopBar(
          onBack: _back,
          count: AppStrings.stepCount(_index + 1, total),
          progress: FlowProgressBar(
            value: (_index + 1) / total,
            semanticsLabel: AppStrings.questionProgress(_index + 1, total),
          ),
        ),
        ctaLabel: _isLast
            ? (widget.mode == QuizMode.edit
                  ? AppStrings.finish
                  : AppStrings.takeFacePhoto)
            : AppStrings.next,
        ctaLoading: _saving,
        onCta: selected == null ? null : () => unawaited(_next()),
        body: Column(
          key: ValueKey(question.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xs),
            AlfaSays(
              mood: mood,
              motion: motion,
              size: 96,
              bubbleBottomGap: 36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lead != null) ...[
                    Text(
                      lead,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  Text(question.text, style: text.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final v in question.scale.values) ...[
              LikertOption(
                value: v,
                label: question.scale.labelFor(v),
                selected: selected == v,
                onTap: () => _pick(v),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

/// 64 dp answer card with a quatrefoil number badge.
class LikertOption extends StatelessWidget {
  const LikertOption({
    required this.value,
    required this.selected,
    required this.onTap,
    super.key,
    this.label,
  });

  final int value;
  final String? label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: AppStrings.likertOption(value, label),
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardAll,
            side: BorderSide(
              color: selected ? AppColors.sage : AppColors.white,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    // Selected: ink badge (white digit 11.5:1). The design's
                    // sage badge gives white text only 3.1:1 (rule 3.3).
                    QuatrefoilShape(
                      size: 36,
                      color: selected ? AppColors.ink : AppColors.mist,
                      child: Center(
                        child: Text(
                          '$value',
                          style: text.titleMedium?.copyWith(
                            color: selected ? AppColors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(label ?? '', style: text.bodyLarge)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
