import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/core/widgets/afa_chip.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:material_ui/material_ui.dart';

/// Debug-only page showing every token and base component, for visual
/// checks against the brand board. Not reachable in release builds.
/// Labels here are developer-facing, so they are not in AppStrings.
class StyleGuidePage extends StatefulWidget {
  const StyleGuidePage({super.key});

  @override
  State<StyleGuidePage> createState() => _StyleGuidePageState();
}

class _StyleGuidePageState extends State<StyleGuidePage> {
  bool _cardSelected = true;
  final Set<String> _chips = {'Serum'};

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.styleGuideTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          const _Section('Logo'),
          const _LogoRow(),

          const _Section('Warna'),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Swatch('mist', AppColors.mist, '#E3F0ED'),
              _Swatch('sage', AppColors.sage, '#7B9891'),
              _Swatch('ink', AppColors.ink, '#2B3B4B'),
              _Swatch('white', AppColors.white, '#FFFFFF'),
              _Swatch('outline', AppColors.outline, '#C8D1D9'),
              _Swatch('danger', AppColors.danger, '#A8483B'),
              _Swatch('caution', AppColors.caution, '#8A5A12'),
              _Swatch('positive', AppColors.positive, '#3E6B5E'),
            ],
          ),

          const _Section('Tipografi'),
          AfaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (name, style) in [
                  ('displayLarge · Etna 32', text.displayLarge),
                  ('headlineMedium · Etna 24', text.headlineMedium),
                  ('titleLarge · Etna 20', text.titleLarge),
                  ('titleMedium · Etna 16', text.titleMedium),
                  ('labelLarge · Etna 16', text.labelLarge),
                  ('bodyLarge · Belleza 16', text.bodyLarge),
                  ('bodyMedium · Belleza 14', text.bodyMedium),
                  ('bodySmall · Belleza 12', text.bodySmall),
                ]) ...[
                  Text(name, style: style),
                  const SizedBox(height: AppSpacing.xs),
                ],
                const Divider(),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kulit berminyak cenderung mudah berkomedo. Niacinamide '
                  'membantu mengontrol produksi sebum.',
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),

          const _Section('Tombol'),
          AfaButton(label: 'Mulai analisis', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AfaButton.secondary(
            label: 'Pilih dari galeri',
            icon: Icons.photo_library_outlined,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          const AfaButton(label: 'Nonaktif', onPressed: null),
          const SizedBox(height: AppSpacing.sm),
          AfaButton(label: 'Memuat', loading: true, onPressed: () {}),

          const _Section('Kartu'),
          AfaCard(
            selected: _cardSelected,
            onTap: () => setState(() => _cardSelected = !_cardSelected),
            child: Text(
              _cardSelected ? 'Kartu terpilih (ketuk)' : 'Kartu biasa (ketuk)',
              style: text.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AfaCard(
            shadow: true,
            child: Text('Kartu dengan bayangan halus', style: text.bodyLarge),
          ),

          const _Section('Chip'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final c in ['Cleanser', 'Toner', 'Serum', 'Sunscreen'])
                AfaChip(
                  label: c,
                  selected: _chips.contains(c),
                  onTap: () => setState(
                    () => _chips.contains(c) ? _chips.remove(c) : _chips.add(c),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AfaChip(label: 'niacinamide', tone: AfaChipTone.positive),
              AfaChip(
                label: 'retinol + AHA',
                tone: AfaChipTone.danger,
                icon: Icons.warning_amber_rounded,
              ),
              AfaChip(label: 'Agak gelap', tone: AfaChipTone.caution),
            ],
          ),

          const _Section('Alfa'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final m in AlfaMood.values)
                Column(
                  children: [
                    AlfaMascot(mood: m, size: 72),
                    Text(m.name, style: text.bodySmall),
                  ],
                ),
            ],
          ),

          const _Section('Quatrefoil'),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const QuatrefoilShape(size: 56),
              const QuatrefoilShape(size: 56, color: AppColors.ink),
              const QuatrefoilShape(
                size: 56,
                color: AppColors.white,
                borderColor: AppColors.sage,
              ),
              QuatrefoilShape(
                size: 72,
                color: AppColors.mist,
                borderColor: AppColors.sage,
                semanticLabel: 'Contoh bingkai avatar',
                child: Center(child: Text('AS', style: text.headlineMedium)),
              ),
              const QuatrefoilLoader(size: 72),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _LogoRow extends StatelessWidget {
  const _LogoRow();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.cardAll,
          ),
          child: const AfaLogo(height: 24),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Container(
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            borderRadius: AppRadius.cardAll,
          ),
          child: const AfaLogo(height: 24, onDark: true),
        ),
      ),
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.hex);
  final String name;
  final Color color;
  final String hex;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuatrefoilShape(
            size: 72,
            color: color,
            borderColor: AppColors.outline,
            borderWidth: 1,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(name, style: text.titleSmall),
          Text(hex, style: text.bodySmall),
        ],
      ),
    );
  }
}
