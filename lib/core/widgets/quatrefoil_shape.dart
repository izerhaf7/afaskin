import 'dart:math' as math;

import 'package:afaskin/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The brand quatrefoil (four rounded lobes), traced from the color swatches
/// on the Afa Skin brand board. Coordinates are in a 162.1 x 162.1 box.
abstract final class QuatrefoilPath {
  static const double _size = 162.097656;
  static const double _ox = 0.679688;
  static const double _oy = 0.535156;

  static Path _unit() {
    // Original swatch path, translated so the box starts at (0, 0).
    double x(double v) => v - _ox;
    double y(double v) => v - _oy;
    return Path()
      ..moveTo(x(10.265625), y(68.5))
      ..cubicTo(
        x(14.980469),
        y(74.167969),
        x(14.992188),
        y(89.214844),
        x(10.300781),
        y(94.90625),
      )
      ..cubicTo(
        x(4.40625),
        y(102.066406),
        x(0.875),
        y(111.222656),
        x(0.875),
        y(121.175781),
      )
      ..cubicTo(
        x(0.875),
        y(144.164062),
        x(19.496094),
        y(162.632812),
        x(42.234375),
        y(162.632812),
      )
      ..cubicTo(
        x(52.242188),
        y(162.632812),
        x(61.398438),
        y(159.113281),
        x(68.550781),
        y(153.234375),
      )
      ..cubicTo(
        x(74.257812),
        y(148.546875),
        x(89.394531),
        y(148.546875),
        x(95.101562),
        y(153.234375),
      )
      ..cubicTo(
        x(102.253906),
        y(159.113281),
        x(111.414062),
        y(162.632812),
        x(121.421875),
        y(162.632812),
      )
      ..cubicTo(
        x(144.160156),
        y(162.632812),
        x(162.777344),
        y(144.164062),
        x(162.777344),
        y(121.175781),
      )
      ..cubicTo(
        x(162.777344),
        y(111.148438),
        x(159.136719),
        y(101.929688),
        x(153.140625),
        y(94.75),
      )
      ..cubicTo(
        x(148.429688),
        y(89.105469),
        x(148.429688),
        y(74.253906),
        x(153.132812),
        y(68.605469),
      )
      ..cubicTo(
        x(159.132812),
        y(61.402344),
        x(162.777344),
        y(52.132812),
        x(162.777344),
        y(41.992188),
      )
      ..cubicTo(
        x(162.777344),
        y(19.203125),
        x(144.160156),
        y(0.535156),
        x(121.421875),
        y(0.535156),
      )
      ..cubicTo(
        x(111.5),
        y(0.535156),
        x(102.449219),
        y(3.976562),
        x(95.332031),
        y(9.738281),
      )
      ..cubicTo(
        x(89.539062),
        y(14.425781),
        x(73.824219),
        y(14.375),
        x(68.03125),
        y(9.6875),
      )
      ..cubicTo(
        x(60.957031),
        y(3.957031),
        x(51.929688),
        y(0.535156),
        x(42.035156),
        y(0.535156),
      )
      ..cubicTo(
        x(19.296875),
        y(0.535156),
        x(0.679688),
        y(19.203125),
        x(0.679688),
        y(41.992188),
      )
      ..cubicTo(
        x(0.679688),
        y(52.082031),
        x(4.289062),
        y(61.3125),
        x(10.265625),
        y(68.5),
      )
      ..close();
  }

  static final Path _cached = _unit();

  /// The quatrefoil scaled to fill [rect].
  static Path inRect(Rect rect) {
    final m = Matrix4.identity()
      ..translateByDouble(rect.left, rect.top, 0, 1)
      ..scaleByDouble(rect.width / _size, rect.height / _size, 1, 1);
    return _cached.transform(m.storage);
  }
}

/// [ShapeBorder] so the quatrefoil works anywhere a shape is accepted:
/// `ShapeDecoration`, `Material(shape:)`, `ClipPath.shape`, avatar frames.
class QuatrefoilBorder extends OutlinedBorder {
  const QuatrefoilBorder({super.side});

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      QuatrefoilPath.inRect(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      QuatrefoilPath.inRect(rect.deflate(side.strokeInset));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    final inset = rect.deflate(side.width / 2);
    canvas.drawPath(QuatrefoilPath.inRect(inset), side.toPaint());
  }

  @override
  QuatrefoilBorder copyWith({BorderSide? side}) =>
      QuatrefoilBorder(side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => QuatrefoilBorder(side: side.scale(t));

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);
}

/// A solid quatrefoil, optionally framing a [child] (e.g. an avatar image).
class QuatrefoilShape extends StatelessWidget {
  const QuatrefoilShape({
    super.key,
    this.size = 64,
    this.color = AppColors.sage,
    this.borderColor,
    this.borderWidth = 2,
    this.child,
    this.semanticLabel,
  });

  final double size;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shape = QuatrefoilBorder(
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor!, width: borderWidth),
    );
    final box = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: shape),
        child: child == null
            ? null
            : ClipPath(
                clipper: ShapeBorderClipper(shape: shape),
                child: child,
              ),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: box);
    return Semantics(label: semanticLabel, image: true, child: box);
  }
}

/// Loading animation: a sage quatrefoil turning slowly with a smaller ink one
/// counter-rotating and breathing inside it. Static when the system asks for
/// reduced motion.
class QuatrefoilLoader extends StatefulWidget {
  const QuatrefoilLoader({
    super.key,
    this.size = 96,
    this.semanticLabel = 'Memuat',
  });

  final double size;
  final String semanticLabel;

  @override
  State<QuatrefoilLoader> createState() => _QuatrefoilLoaderState();
}

class _QuatrefoilLoaderState extends State<QuatrefoilLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _LoaderPainter(_c.value)),
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final turn = t * 2 * math.pi;
    final breathe = 0.5 + 0.5 * math.sin(turn); // 0..1

    void draw(double scale, double angle, Paint paint) {
      final s = size.width * scale;
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(angle)
        ..drawPath(
          QuatrefoilPath.inRect(
            Rect.fromCenter(center: Offset.zero, width: s, height: s),
          ),
          paint,
        )
        ..restore();
    }

    draw(1, turn / 4, Paint()..color = AppColors.sage);
    draw(0.62, turn / 4 + math.pi / 4, Paint()..color = AppColors.mist);
    draw(0.22 + 0.12 * breathe, -turn / 2, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.t != t;
}
