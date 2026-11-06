import 'dart:async';

import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/widgets/afa_backdrop.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:afaskin/core/widgets/alfa_mascot.dart';
import 'package:afaskin/core/widgets/quatrefoil_shape.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Alfa + logo on Mist, then forwards to the first unfinished setup step
/// (or home). Tapping skips the wait.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    super.key,
    this.delay = const Duration(milliseconds: 1600),
  });

  final Duration delay;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, _forward);
  }

  void _forward() {
    _timer?.cancel();
    if (!mounted) return;
    context.go(AppRoutes.forStep(ref.read(sessionProvider).nextStep));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _forward,
      child: const AfaBackdrop(
        style: BackdropStyle.bubbles,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AlfaMascot(mood: AlfaMood.excited, size: 150),
                  SizedBox(height: 20),
                  AfaLogo(height: 48),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: Center(child: PulseLoader()),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 2x2 quatrefoils pulsing in turn (the design's small spinner).
class PulseLoader extends StatefulWidget {
  const PulseLoader({super.key, this.dot = 14, this.label = 'Memuat'});

  final double dot;
  final String label;

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    still ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// afPulse: opacity .25 -> 1 -> .25, scale .78 -> 1, peak at 40%.
  double _phase(double delay) {
    final p = ((_c.value * 1.4 - delay) / 1.4) % 1.0;
    if (p < 0.4) return Curves.easeInOut.transform(p / 0.4);
    return 1 - Curves.easeInOut.transform((p - 0.4) / 0.6);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) => SizedBox(
        width: widget.dot * 2 + 3,
        child: Wrap(
          spacing: 3,
          runSpacing: 3,
          children: [
            for (final d in const [0, 1, 3, 2])
              Builder(
                builder: (_) {
                  final k = _c.isAnimating ? _phase(d * 0.35) : 1.0;
                  return Opacity(
                    opacity: 0.25 + 0.75 * k,
                    child: Transform.scale(
                      scale: 0.78 + 0.22 * k,
                      child: QuatrefoilShape(size: widget.dot),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ),
  );
}
