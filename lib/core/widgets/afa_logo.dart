import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// "Afa Skin" wordmark. [onDark] picks the variant for Ink backgrounds
/// ("Afa" stays Sage, "Skin" turns White).
class AfaLogo extends StatelessWidget {
  const AfaLogo({super.key, this.height = 40, this.onDark = false});

  final double height;
  final bool onDark;

  // Aspect ratio of the trimmed SVG viewBox (388 x 84).
  static const double _aspect = 388 / 84;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      onDark
          ? 'assets/brand/afaskin_logo_dark.svg'
          : 'assets/brand/afaskin_logo.svg',
      height: height,
      width: height * _aspect,
      semanticsLabel: AppStrings.appName,
    );
  }
}
