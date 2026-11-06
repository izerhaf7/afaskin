import 'package:afaskin/core/theme/app_colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

enum BackdropStyle {
  /// Soft white swells at the top, sage swells at the bottom (forms, tabs).
  waves,

  /// Scattered circles plus slowly rising bubbles (splash, onboarding,
  /// analyzing).
  bubbles,
}

/// Mist background with the design's decorative shapes, drawn behind
/// [child]. Coordinates follow the 390 x 844 design frame and scale with
/// the screen width. Rising bubbles are skipped under reduced motion.
class AfaBackdrop extends StatefulWidget {
  const AfaBackdrop({
    required this.child,
    super.key,
    this.style = BackdropStyle.waves,
  });

  final Widget child;
  final BackdropStyle style;

  @override
  State<AfaBackdrop> createState() => _AfaBackdropState();
}

class _AfaBackdropState extends State<AfaBackdrop>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(
    (e) => _seconds.value = e.inMicroseconds / 1e6,
  );
  final ValueNotifier<double> _seconds = ValueNotifier(0);

  bool get _animate => widget.style == BackdropStyle.bubbles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_animate && !still) {
      if (!_ticker.isActive) _ticker.start();
    } else if (_ticker.isActive) {
      _ticker.stop();
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
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return ColoredBox(
      color: AppColors.mist,
      child: CustomPaint(
        painter: _BackdropPainter(
          style: widget.style,
          seconds: _seconds,
          rising: _animate && !still,
        ),
        child: widget.child,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.style,
    required this.seconds,
    required this.rising,
  }) : super(repaint: seconds);

  final BackdropStyle style;
  final ValueNotifier<double> seconds;
  final bool rising;

  // (left, size, ring?, color, opacity, duration s, delay s)
  static const List<(double, double, bool, Color, double, double, double)>
  _risers = [
    (40.0, 18.0, true, AppColors.white, 1.0, 10.0, 0.0),
    (300.0, 28.0, false, AppColors.white, 0.7, 13.0, 2.0),
    (180.0, 12.0, true, AppColors.sage, 0.4, 9.0, 4.0),
    (90.0, 20.0, false, AppColors.white, 0.6, 12.0, 6.0),
    (340.0, 14.0, true, AppColors.white, 1.0, 11.0, 3.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 390;
    switch (style) {
      case BackdropStyle.waves:
        _ellipse(
          canvas,
          Offset(195 * k, -40 * k),
          350 * k,
          220 * k,
          AppColors.white.withValues(alpha: 0.55),
        );
        _ellipse(
          canvas,
          Offset(234 * k, -80 * k),
          338 * k,
          220 * k,
          AppColors.white.withValues(alpha: 0.5),
        );
        _ellipse(
          canvas,
          Offset(182 * k, size.height + 100 * k),
          390 * k,
          230 * k,
          AppColors.sage.withValues(alpha: 0.12),
        );
        _ellipse(
          canvas,
          Offset(286 * k, size.height + 130 * k),
          364 * k,
          230 * k,
          AppColors.sage.withValues(alpha: 0.10),
        );
      case BackdropStyle.bubbles:
        void dot(double x, double y, double d, Color c, {bool ring = false}) {
          final r = d * k / 2;
          final center = Offset(x * k + r, y * k + r);
          canvas.drawCircle(
            center,
            ring ? r - k : r,
            Paint()
              ..color = c
              ..style = ring ? PaintingStyle.stroke : PaintingStyle.fill
              ..strokeWidth = 2 * k,
          );
        }

        dot(318, 92, 56, AppColors.white.withValues(alpha: 0.6));
        dot(298, 156, 18, AppColors.white, ring: true);
        dot(-40, 390, 120, AppColors.white.withValues(alpha: 0.5));
        dot(
          390 - 30 - 26,
          size.height / k - 210 - 26,
          26,
          AppColors.sage.withValues(alpha: 0.3),
          ring: true,
        );
        dot(60, 170, 10, AppColors.white);

        if (!rising) return;
        final t = seconds.value;
        for (final (left, d, ring, color, opacity, dur, delay) in _risers) {
          if (t < delay) continue;
          final p = ((t - delay) % dur) / dur;
          // Fade in over the first 12%, out towards the top.
          final alpha = p < 0.12 ? p / 0.12 : 1 - (p - 0.12) / 0.88;
          final y = size.height + 30 * k - d * k - 900 * k * p;
          dot(
            left,
            y / k,
            d,
            color.withValues(alpha: opacity * alpha),
            ring: ring,
          );
        }
    }
  }

  static void _ellipse(
    Canvas c,
    Offset center,
    double rx,
    double ry,
    Color color,
  ) => c.drawOval(
    Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
    Paint()..color = color,
  );

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.style != style || old.rising != rising;
}
