import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/utils/formatters.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/setup_scaffold.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Budget options (max price per product, Rupiah).
const List<int> kBudgetOptions = [50000, 100000, 150000, 250000, 500000];

/// Age, gender and budget. Used both in first-run setup and from Settings
/// ([editing] = true: pops back instead of moving to the questionnaire).
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _age;
  Gender? _gender;
  int? _budget;
  bool _submitted = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(sessionProvider).profile;
    _age = TextEditingController(text: p == null ? '' : '${p.age}');
    _gender = p?.gender;
    _budget = p?.budgetMax;
  }

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  static String? validateAge(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 12 || n > 100) return AppStrings.ageError;
    return null;
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _gender == null || _budget == null) return;

    setState(() => _saving = true);
    await ref
        .read(sessionProvider.notifier)
        .saveProfile(
          UserProfile(
            age: int.parse(_age.text.trim()),
            gender: _gender!,
            budgetMax: _budget!,
          ),
        );
    if (!mounted) return;
    if (widget.editing) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.profileSaved)));
      context.pop();
    } else {
      context.go(AppRoutes.setupQuestionnaire);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final errorStyle = text.bodySmall?.copyWith(color: AppColors.danger);

    return SetupScaffold(
      title: widget.editing
          ? AppStrings.profileEditTitle
          : AppStrings.profileTitle,
      showBack: widget.editing,
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.profileIntro, style: text.bodyLarge),
            const SizedBox(height: AppSpacing.lg),

            Text(AppStrings.ageLabel, style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              key: const Key('profile_age'),
              controller: _age,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: const InputDecoration(
                hintText: AppStrings.ageHint,
                suffixText: AppStrings.ageSuffix,
              ),
              validator: validateAge,
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(AppStrings.genderLabel, style: text.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final (g, label) in const [
                  (Gender.female, AppStrings.genderFemale),
                  (Gender.male, AppStrings.genderMale),
                  (Gender.other, AppStrings.genderOther),
                ])
                  AfaChip(
                    label: label,
                    selected: _gender == g,
                    onTap: () => setState(() => _gender = g),
                  ),
              ],
            ),
            if (_submitted && _gender == null)
              Text(AppStrings.genderError, style: errorStyle),
            const SizedBox(height: AppSpacing.lg),

            Text(AppStrings.budgetLabel, style: text.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final b in kBudgetOptions)
                  AfaChip(
                    label: AppStrings.budgetUpTo(formatRupiah(b)),
                    selected: _budget == b,
                    onTap: () => setState(() => _budget = b),
                  ),
              ],
            ),
            if (_submitted && _budget == null)
              Text(AppStrings.budgetError, style: errorStyle),
          ],
        ),
      ),
      bottom: AfaButton(
        label: widget.editing ? AppStrings.save : AppStrings.next,
        loading: _saving,
        onPressed: _save,
      ),
    );
  }
}
