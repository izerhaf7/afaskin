import 'dart:async';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_parts.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/flow_scaffold.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Budget presets in the profile flow (design: 2 x 2 grid).
const List<int> kBudgetPresets = [50000, 100000, 150000, 300000];

enum ProfileMode {
  /// First run: nickname, age -> questionnaire.
  setup,

  /// After the first result ("Lengkapi profilmu"): gender, budget.
  complete,

  /// From Settings: all four.
  edit,
}

enum _Step { name, age, gender, budget }

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.mode = ProfileMode.setup});

  final ProfileMode mode;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final List<_Step> _steps = switch (widget.mode) {
    ProfileMode.setup => const [_Step.name, _Step.age],
    ProfileMode.complete => const [_Step.gender, _Step.budget],
    ProfileMode.edit => _Step.values,
  };
  int _i = 0;
  bool _saving = false;

  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _budget;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sessionProvider);
    _name = TextEditingController(text: s.name ?? '');
    _age = TextEditingController(
      text: s.profile == null ? '' : '${s.profile!.age}',
    );
    _budget = TextEditingController(
      text: s.profile?.budgetMax == null
          ? ''
          : formatThousands(s.profile!.budgetMax!),
    );
    _gender = s.profile?.gender;
    for (final c in [_name, _age, _budget]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _budget.dispose();
    super.dispose();
  }

  _Step get _step => _steps[_i];
  String get _nick =>
      _name.text.trim().isEmpty ? AppStrings.you : _name.text.trim();
  int? get _ageValue => int.tryParse(_age.text);
  int? get _budgetValue => int.tryParse(_budget.text.replaceAll('.', ''));

  bool get _ageTooYoung =>
      _age.text.isNotEmpty && (_ageValue == null || _ageValue! < kMinAge);

  bool get _stepOk => switch (_step) {
    _Step.name => _name.text.trim().isNotEmpty,
    _Step.age =>
      _ageValue != null && _ageValue! >= kMinAge && _ageValue! <= kMaxAge,
    _Step.gender => _gender != null,
    _Step.budget => (_budgetValue ?? 0) > 0,
  };

  (String, AlfaMood) get _ask => switch (_step) {
    _Step.name => (AppStrings.askName, AlfaMood.happy),
    _Step.age =>
      _ageTooYoung
          ? (AppStrings.askAgeTooYoung, AlfaMood.oops)
          : (AppStrings.askAge(_nick), AlfaMood.excited),
    _Step.gender => (
      widget.mode == ProfileMode.complete
          ? AppStrings.askGenderAfterResult(_nick)
          : AppStrings.askGender,
      AlfaMood.thinking,
    ),
    _Step.budget => (AppStrings.askBudget, AlfaMood.celebrate),
  };

  String get _cta {
    if (_i < _steps.length - 1) return AppStrings.next;
    return widget.mode == ProfileMode.setup
        ? AppStrings.toQuestionnaire
        : AppStrings.save;
  }

  void _back() {
    if (_i > 0) {
      setState(() => _i--);
    } else if (widget.mode == ProfileMode.setup) {
      context.go(AppRoutes.consent);
    } else {
      context.pop();
    }
  }

  Future<void> _next() async {
    if (!_stepOk) return;
    if (_i < _steps.length - 1) {
      setState(() => _i++);
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider.notifier);
    switch (widget.mode) {
      case ProfileMode.setup:
        await session.saveNameAndAge(_name.text, _ageValue!);
        if (mounted) context.go(AppRoutes.setupQuestionnaire);
      case ProfileMode.complete:
        await session.completeProfile(_gender!, _budgetValue!);
        if (!mounted) return;
        showAfaToast(context, AppStrings.profileCompleted);
        context.pop();
      case ProfileMode.edit:
        final current = ref.read(sessionProvider).profile;
        await session.saveProfile(
          _name.text,
          (current ?? UserProfile(age: _ageValue!)).copyWith(
            age: _ageValue!,
            gender: _gender,
            budgetMax: _budgetValue,
          ),
        );
        if (!mounted) return;
        showAfaToast(context, AppStrings.profileSaved);
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final (ask, mood) = _ask;
    return PopScope(
      canPop: _i == 0 && widget.mode != ProfileMode.setup,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: FlowScaffold(
        topBar: FlowTopBar(
          onBack: _back,
          count: AppStrings.stepCount(_i + 1, _steps.length),
          progress: SegmentedProgress(count: _steps.length, filled: _i + 1),
        ),
        ctaLabel: _cta,
        ctaLoading: _saving,
        onCta: _stepOk ? () => unawaited(_next()) : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            AlfaSays(
              mood: mood,
              child: Text(
                ask,
                key: const Key('alfa_ask'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(key: ValueKey(_step), child: _field()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field() {
    final text = Theme.of(context).textTheme;
    final note = text.bodyMedium?.copyWith(color: AppColors.inkMuted);
    switch (_step) {
      case _Step.name:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BigField(
              key: const Key('profile_name'),
              controller: _name,
              hint: AppStrings.nameHint,
              maxLength: 20,
              capitalization: TextCapitalization.words,
              onSubmitted: () => unawaited(_next()),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(AppStrings.nameNote, style: note),
          ],
        );
      case _Step.age:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BigField(
              key: const Key('profile_age'),
              controller: _age,
              hint: AppStrings.ageHint,
              suffix: AppStrings.ageSuffix,
              error: _ageTooYoung,
              digitsOnly: true,
              maxLength: 2,
              onSubmitted: () => unawaited(_next()),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _ageTooYoung ? AppStrings.ageTooYoung : AppStrings.ageNote,
              style: _ageTooYoung
                  ? text.bodyMedium?.copyWith(color: AppColors.danger)
                  : note,
            ),
          ],
        );
      case _Step.gender:
        return Column(
          children: [
            for (final (g, label) in const [
              (Gender.female, AppStrings.genderFemale),
              (Gender.male, AppStrings.genderMale),
              (Gender.unspecified, AppStrings.genderUnspecified),
            ]) ...[
              ChoiceTile(
                label: label,
                selected: _gender == g,
                onTap: () => setState(() => _gender = g),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        );
      case _Step.budget:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BigField(
              key: const Key('profile_budget'),
              controller: _budget,
              hint: AppStrings.budgetHint,
              prefix: AppStrings.currency,
              thousands: true,
              maxLength: 10,
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              childAspectRatio: 3.4,
              children: [
                for (final b in kBudgetPresets)
                  _PresetButton(
                    label: formatRupiah(b),
                    selected: _budgetValue == b,
                    onTap: () => _budget.text = formatThousands(b),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.budgetNote, style: note),
          ],
        );
    }
  }
}

/// 60 dp white input with sage border (danger when [error]).
class _BigField extends StatelessWidget {
  const _BigField({
    required this.controller,
    required this.hint,
    super.key,
    this.prefix,
    this.suffix,
    this.error = false,
    this.digitsOnly = false,
    this.thousands = false,
    this.maxLength,
    this.capitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final String? suffix;
  final bool error;
  final bool digitsOnly;
  final bool thousands;
  final int? maxLength;
  final TextCapitalization capitalization;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final big = text.bodyLarge?.copyWith(fontSize: 20, height: 1.3);
    final side = BorderSide(
      color: error ? AppColors.danger : AppColors.sage,
      width: 2,
    );
    final border = OutlineInputBorder(
      borderRadius: AppRadius.inputAll,
      borderSide: side,
    );
    return TextField(
      controller: controller,
      autofocus: true,
      style: big,
      textCapitalization: capitalization,
      keyboardType: digitsOnly || thousands
          ? TextInputType.number
          : TextInputType.name,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: [
        if (digitsOnly || thousands) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        if (thousands) const _ThousandsFormatter(),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: big?.copyWith(color: AppColors.inkMuted),
        prefixText: prefix == null ? null : '$prefix ',
        prefixStyle: text.bodyLarge?.copyWith(
          fontSize: 18,
          color: AppColors.inkMuted,
        ),
        suffixText: suffix,
        suffixStyle: text.bodyLarge?.copyWith(color: AppColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

/// Live "150.000" grouping while typing.
class _ThousandsFormatter extends TextInputFormatter {
  const _ThousandsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    final n = int.tryParse(digits);
    if (n == null) return TextEditingValue.empty;
    final f = formatThousands(n);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.inputAll,
        side: BorderSide(
          color: selected ? AppColors.sage : AppColors.white,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    ),
  );
}
