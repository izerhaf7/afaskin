import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:material_ui/material_ui.dart';

/// Nickname initial in a sage-ringed quatrefoil (home header, settings).
class AvatarFoil extends StatelessWidget {
  const AvatarFoil({
    required this.initial,
    super.key,
    this.size = 40,
    this.fill = AppColors.white,
  });

  final String initial;
  final double size;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontSize: size * 0.4, height: 1);
    return QuatrefoilShape(
      size: size,
      child: Center(
        child: QuatrefoilShape(
          size: size * 0.9,
          color: fill,
          child: Center(child: Text(initial, style: style)),
        ),
      ),
    );
  }
}
