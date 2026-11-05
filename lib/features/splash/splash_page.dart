import 'dart:async';

import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/widgets/afa_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Logo on Mist, then forwards to the first unfinished setup step (or home).
/// Session state is already loaded, so the delay is only a brief brand moment.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key, this.delay = const Duration(milliseconds: 900)});

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
    if (!mounted) return;
    final step = ref.read(sessionProvider).nextStep;
    context.go(AppRoutes.forStep(step));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: AfaLogo(height: 56)));
}
