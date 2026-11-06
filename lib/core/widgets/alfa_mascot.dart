import 'dart:math' as math;

import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_typography.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// Alfa's facial expressions (from the design's Mascot component).
enum AlfaMood {
  happy,
  excited,
  celebrate,
  thinking,
  focused,
  oops,
  sad,
  sleepy,
}

/// Idle motion: gentle float, squishy bounce, or still.
enum AlfaMotion { bob, squish, none }

/// Alfa, the Afa Skin axolotl. Drawn in a 160x160 design space and scaled to
/// [size]. Animations (body bob/squish, blinking, swaying gills) stop when the
/// system asks for reduced motion.
class AlfaMascot extends StatefulWidget {
  const AlfaMascot({
    super.key,
    this.mood = AlfaMood.happy,
    this.motion = AlfaMotion.bob,
    this.size = 160,
    this.semanticLabel,
  });

  final AlfaMood mood;
  final AlfaMotion motion;
  final double size;

  /// Decorative by default (excluded from semantics).
  final String? semanticLabel;

  @override
  State<AlfaMascot> createState() => _AlfaMascotState();
}

class _AlfaMascotState extends State<AlfaMascot>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final ValueNotifier<double> _seconds = ValueNotifier(0);

  void _onTick(Duration elapsed) =>
      _seconds.value = elapsed.inMicroseconds / 1e6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      if (_ticker.isActive) _ticker.stop();
      _seconds.value = 0;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: AlfaPainter(
            mood: widget.mood,
            motion: widget.motion,
            seconds: _seconds,
          ),
        ),
      ),
    );
    if (widget.semanticLabel == null) return ExcludeSemantics(child: art);
    return Semantics(image: true, label: widget.semanticLabel, child: art);
  }
}

/// Paints Alfa at time [seconds]. Coordinates follow the design (160 box).
class AlfaPainter extends CustomPainter {
  AlfaPainter({required this.mood, required this.motion, this.seconds})
    : super(repaint: seconds);

  final AlfaMood mood;
  final AlfaMotion motion;
  final ValueListenable<double>? seconds;

  double get _t => seconds?.value ?? 0;

  bool _has(List<AlfaMood> moods) => moods.contains(mood);

  /// CSS `ease-in-out` style 0..1..0 wave with period [p] and delay [d].
  double _wave(double p, [double d = 0]) =>
      0.5 - 0.5 * math.cos(2 * math.pi * ((_t - d) / p));

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 160);

    // Ground shadow (does not move with the body).
    _oval(
      canvas,
      const Rect.fromLTWH(34, 148, 92, 10),
      AppColors.ink.withValues(alpha: 0.1),
    );

    // Body motion, transform-origin: 50% 100%.
    canvas.save();
    switch (motion) {
      case AlfaMotion.bob:
        canvas.translate(0, -6 * _wave(2.6));
      case AlfaMotion.squish:
        final (sx, sy) = _squish((_t % 1.3) / 1.3);
        canvas
          ..translate(80, 160)
          ..scale(sx, sy)
          ..translate(-80, -160);
      case AlfaMotion.none:
        break;
    }

    _gills(canvas);
    // Tail.
    _rotated(canvas, const Offset(126, 133), -25, () {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(104, 124, 44, 18),
          topLeft: const Radius.elliptical(22, 9),
          topRight: const Radius.elliptical(39.6, 16.2),
          bottomRight: const Radius.elliptical(39.6, 16.2),
          bottomLeft: const Radius.elliptical(22, 9),
        ).scaleRadii(),
        Paint()..color = AlfaPalette.body,
      );
    });
    // Body, belly, arms.
    const body = Rect.fromLTWH(46, 102, 68, 52);
    canvas.drawOval(
      body,
      Paint()
        ..shader = _radial(body, 0.40, 0.30, const [
          AlfaPalette.bodyLight,
          AlfaPalette.body,
        ]),
    );
    _oval(
      canvas,
      const Rect.fromLTWH(62, 116, 36, 30),
      AlfaPalette.belly.withValues(alpha: 0.8),
    );
    _rotated(canvas, const Offset(51, 130), 25, () {
      _oval(canvas, const Rect.fromLTWH(44, 120, 14, 20), AlfaPalette.gillPale);
    });
    _rotated(canvas, const Offset(109, 130), -25, () {
      _oval(
        canvas,
        const Rect.fromLTWH(102, 120, 14, 20),
        AlfaPalette.gillPale,
      );
    });
    // Head.
    const head = Rect.fromLTWH(24, 32, 112, 86);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        head,
        topLeft: const Radius.elliptical(56, 43),
        topRight: const Radius.elliptical(56, 43),
        bottomLeft: const Radius.elliptical(51.5, 39.6),
        bottomRight: const Radius.elliptical(51.5, 39.6),
      ),
      Paint()
        ..shader = _radial(
          head,
          0.38,
          0.30,
          const [
            AlfaPalette.headLight,
            AlfaPalette.bodyLight,
            AlfaPalette.headShade,
          ],
          const [0, 0.55, 1],
        ),
    );

    _eyes(canvas);
    _brows(canvas);
    final blush = _has(const [AlfaMood.celebrate, AlfaMood.excited])
        ? 1.0
        : mood == AlfaMood.sad
        ? 0.45
        : 0.85;
    _oval(
      canvas,
      const Rect.fromLTWH(34, 80, 20, 11),
      AlfaPalette.blush.withValues(alpha: blush),
    );
    _oval(
      canvas,
      const Rect.fromLTWH(106, 80, 20, 11),
      AlfaPalette.blush.withValues(alpha: blush),
    );
    _mouth(canvas);
    _extras(canvas);

    canvas
      ..restore()
      ..restore();
  }

  /// Squish keyframes: 0/100% (1,1), 30% (1.08,.9), 60% (.95,1.06).
  (double, double) _squish(double p) {
    const keys = [
      (0.0, 1.0, 1.0),
      (0.3, 1.08, 0.9),
      (0.6, 0.95, 1.06),
      (1.0, 1.0, 1.0),
    ];
    for (var i = 0; i < keys.length - 1; i++) {
      final (a, ax, ay) = keys[i];
      final (b, bx, by) = keys[i + 1];
      if (p <= b) {
        final k = Curves.easeInOut.transform((p - a) / (b - a));
        return (ax + (bx - ax) * k, ay + (by - ay) * k);
      }
    }
    return (1, 1);
  }

  void _gills(Canvas canvas) {
    // (rect, base angle, pivot at inner end, gradient colors, delay)
    const left = [
      (
        Rect.fromLTWH(2, 42, 44, 16),
        30.0,
        [AlfaPalette.gillDark, AlfaPalette.gillLight],
        0.0,
      ),
      (
        Rect.fromLTWH(-2, 60, 48, 16),
        0.0,
        [AlfaPalette.gillMid, AlfaPalette.gillPale],
        0.2,
      ),
      (
        Rect.fromLTWH(2, 78, 44, 16),
        -30.0,
        [AlfaPalette.gillDark, AlfaPalette.gillLight],
        0.4,
      ),
    ];
    const right = [
      (
        Rect.fromLTWH(114, 42, 44, 16),
        -30.0,
        [AlfaPalette.gillDark, AlfaPalette.gillLight],
        0.0,
      ),
      (
        Rect.fromLTWH(114, 60, 48, 16),
        0.0,
        [AlfaPalette.gillMid, AlfaPalette.gillPale],
        0.2,
      ),
      (
        Rect.fromLTWH(114, 78, 44, 16),
        30.0,
        [AlfaPalette.gillDark, AlfaPalette.gillLight],
        0.4,
      ),
    ];
    for (final (r, base, colors, delay) in left) {
      final angle = base + 8 * _wave(2.4, delay);
      _rotated(canvas, Offset(r.right, r.center.dy), angle, () {
        canvas.drawOval(
          r,
          Paint()..shader = LinearGradient(colors: colors).createShader(r),
        );
      });
    }
    for (final (r, base, colors, delay) in right) {
      final angle = base + 8 * _wave(2.4, delay);
      _rotated(canvas, Offset(r.left, r.center.dy), angle, () {
        canvas.drawOval(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: colors,
            ).createShader(r),
        );
      });
    }
  }

  /// Blink: scaleY 1 until 92%, 0.1 at 95%, back at 100% (4.5 s cycle).
  double get _blink {
    final p = (_t % 4.5) / 4.5;
    if (p < 0.92) return 1;
    if (p < 0.95) return 1 - 0.9 * ((p - 0.92) / 0.03);
    return 0.1 + 0.9 * ((p - 0.95) / 0.05);
  }

  void _eyes(Canvas canvas) {
    final ink = Paint()..color = AppColors.ink;
    final white = Paint()..color = AppColors.white;

    if (_has(const [
      AlfaMood.happy,
      AlfaMood.thinking,
      AlfaMood.sad,
      AlfaMood.focused,
    ])) {
      final thinking = mood == AlfaMood.thinking;
      final top = thinking ? 57.0 : 62.0;
      for (final left in thinking ? const [50.0, 104.0] : const [46.0, 100.0]) {
        final r = Rect.fromLTWH(left, top, 14, 14);
        canvas
          ..save()
          ..translate(0, r.center.dy)
          ..scale(1, _blink)
          ..translate(0, -r.center.dy)
          ..drawOval(r, ink)
          ..drawOval(Rect.fromLTWH(left + 3, top + 3, 5, 5), white)
          ..restore();
      }
    }
    if (mood == AlfaMood.excited) {
      for (final left in const [44.0, 98.0]) {
        canvas
          ..drawOval(Rect.fromLTWH(left, 59, 18, 18), ink)
          ..drawOval(Rect.fromLTWH(left + 3, 62, 7, 7), white)
          ..drawOval(Rect.fromLTWH(left + 11, 70, 3, 3), white);
      }
    }
    // Happy-closed arcs (celebrate: ^ ^) and sleepy (u u).
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.ink;
    if (mood == AlfaMood.celebrate) {
      arc.strokeWidth = 3.5;
      for (final left in const [44.0, 98.0]) {
        canvas.drawArc(
          Rect.fromLTWH(left + 1.75, 63.75, 14.5, 14.5),
          -0.75 * math.pi,
          0.5 * math.pi,
          false,
          arc,
        );
      }
    }
    if (mood == AlfaMood.sleepy) {
      arc.strokeWidth = 3;
      for (final left in const [44.0, 98.0]) {
        canvas.drawArc(
          Rect.fromLTWH(left + 1.5, 55.5, 15, 15),
          0.25 * math.pi,
          0.5 * math.pi,
          false,
          arc,
        );
      }
    }
    if (mood == AlfaMood.oops) {
      canvas
        ..drawOval(const Rect.fromLTWH(46, 62, 14, 14), ink)
        ..drawOval(const Rect.fromLTWH(49, 65, 5, 5), white);
      _bar(canvas, const Rect.fromLTWH(98, 67, 17, 4), -12);
    }
  }

  void _brows(Canvas canvas) {
    if (mood == AlfaMood.sad) {
      _bar(canvas, const Rect.fromLTWH(43, 51, 17, 4), -18);
      _bar(canvas, const Rect.fromLTWH(100, 51, 17, 4), 18);
    }
    if (mood == AlfaMood.focused) {
      _bar(canvas, const Rect.fromLTWH(43, 53, 17, 4), 14);
      _bar(canvas, const Rect.fromLTWH(100, 53, 17, 4), -14);
    }
  }

  void _mouth(Canvas canvas) {
    final ink = Paint()..color = AppColors.ink;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.ink;

    if (mood == AlfaMood.happy) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(62, 80, 36, 12),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
        ).scaleRadii(),
        ink,
      );
    }
    if (_has(const [AlfaMood.excited, AlfaMood.celebrate])) {
      final mouth = RRect.fromRectAndCorners(
        const Rect.fromLTWH(62, 78, 36, 20),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
      ).scaleRadii();
      canvas
        ..save()
        ..clipRRect(mouth)
        ..drawRRect(mouth, ink)
        ..drawOval(
          const Rect.fromLTWH(72, 89, 16, 12),
          Paint()..color = AlfaPalette.blush,
        )
        ..restore();
    }
    if (_has(const [AlfaMood.thinking, AlfaMood.oops])) {
      final left = mood == AlfaMood.oops ? 80.0 : 75.0;
      canvas.drawOval(Rect.fromLTWH(left, 82, 11, 10), ink);
    }
    if (mood == AlfaMood.sad) {
      // Upper half of a rounded box: a small frown.
      canvas.drawArc(
        const Rect.fromLTWH(70.5, 84.5, 19, 16),
        math.pi,
        math.pi,
        false,
        line..strokeWidth = 3,
      );
    }
    if (mood == AlfaMood.focused) {
      canvas.drawArc(
        const Rect.fromLTWH(71.5, 76.5, 17, 13),
        0,
        math.pi,
        false,
        line..strokeWidth = 3,
      );
    }
    if (mood == AlfaMood.sleepy) {
      canvas.drawArc(
        const Rect.fromLTWH(73.25, 75.25, 13.5, 11.5),
        0,
        math.pi,
        false,
        line..strokeWidth = 2.5,
      );
    }
  }

  void _extras(Canvas canvas) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AlfaPalette.gillPale;
    final white = Paint()..color = AppColors.white;

    if (mood == AlfaMood.thinking) {
      final bob = -6 * _wave(1.6);
      for (final r in [
        const Rect.fromLTWH(126, 22, 12, 12),
        const Rect.fromLTWH(136, 6, 16, 16),
        Rect.fromLTWH(146, -16 + bob, 22, 22),
      ]) {
        canvas
          ..drawOval(r, white)
          ..drawOval(r.deflate(1), ring);
      }
    }
    if (_has(const [AlfaMood.excited, AlfaMood.celebrate])) {
      void spark(Rect r, Color c, [double delay = 0]) {
        final (sx, sy) = _squish(((_t - delay) % 1.2) / 1.2);
        canvas
          ..save()
          ..translate(r.center.dx, r.center.dy)
          ..scale(sx, sy)
          ..translate(-r.center.dx, -r.center.dy)
          ..drawPath(QuatrefoilPath.inRect(r), Paint()..color = c)
          ..restore();
      }

      spark(const Rect.fromLTWH(6, 14, 16, 16), AppColors.sage);
      spark(const Rect.fromLTWH(142, 16, 12, 12), AlfaPalette.gillPale, 0.4);
      canvas.drawPath(
        QuatrefoilPath.inRect(const Rect.fromLTWH(148, 104, 9, 9)),
        Paint()..color = AppColors.sage,
      );
    }
    if (mood == AlfaMood.sad) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(47, 78, 7, 11),
          topLeft: const Radius.elliptical(3.5, 3.85),
          topRight: const Radius.elliptical(3.5, 3.85),
          bottomLeft: const Radius.elliptical(3.5, 7.15),
          bottomRight: const Radius.elliptical(3.5, 7.15),
        ),
        Paint()..color = AlfaPalette.gillPale,
      );
    }
    if (mood == AlfaMood.oops) {
      _rotated(canvas, const Offset(130, 34), -45, () {
        final drop = RRect.fromRectAndCorners(
          const Rect.fromLTWH(122, 26, 16, 16),
          topLeft: const Radius.circular(8),
          bottomLeft: const Radius.circular(8),
          bottomRight: const Radius.circular(8),
        );
        canvas
          ..drawRRect(drop, white)
          ..drawRRect(drop.deflate(1), ring);
      });
    }
    if (mood == AlfaMood.sleepy) {
      for (final (dx, dy, fs) in const [
        (124.0, 6.0, 18.0),
        (138.0, -8.0, 13.0),
      ]) {
        TextPainter(
            text: TextSpan(
              text: 'z',
              style: TextStyle(
                fontFamily: AppTypography.display,
                fontSize: fs,
                height: 1,
                color: AppColors.sage,
              ),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(canvas, Offset(dx, dy));
      }
    }
  }

  // Helpers.

  static void _oval(Canvas canvas, Rect r, Color c) =>
      canvas.drawOval(r, Paint()..color = c);

  static void _bar(Canvas canvas, Rect r, double degrees) =>
      _rotated(canvas, r.center, degrees, () {
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(2)),
          Paint()..color = AppColors.ink,
        );
      });

  static void _rotated(
    Canvas canvas,
    Offset pivot,
    double degrees,
    VoidCallback draw,
  ) {
    canvas
      ..save()
      ..translate(pivot.dx, pivot.dy)
      ..rotate(degrees * math.pi / 180)
      ..translate(-pivot.dx, -pivot.dy);
    draw();
    canvas.restore();
  }

  /// CSS `radial-gradient(circle at x% y%, ...)` (farthest-corner radius).
  static Shader _radial(
    Rect r,
    double cx,
    double cy,
    List<Color> colors, [
    List<double>? stops,
  ]) {
    final c = Offset(r.left + r.width * cx, r.top + r.height * cy);
    final radius = [
      r.topLeft,
      r.topRight,
      r.bottomLeft,
      r.bottomRight,
    ].map((p) => (p - c).distance).reduce(math.max);
    return RadialGradient(
      colors: colors,
      stops: stops,
    ).createShader(Rect.fromCircle(center: c, radius: radius));
  }

  @override
  bool shouldRepaint(AlfaPainter old) =>
      old.mood != mood || old.motion != motion;
}
