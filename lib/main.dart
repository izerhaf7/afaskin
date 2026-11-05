import 'package:afaskin/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive and SharedPreferences are initialized here from Phase 1/4 onward.
  runApp(const ProviderScope(child: AfaSkinApp()));
}
