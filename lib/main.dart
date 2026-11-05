import 'package:afaskin/app.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/features/history/history_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open local storage before the first frame so the router can decide the
  // start screen synchronously.
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: PrefsFlagStore.allowList,
    ),
  );
  await Hive.initFlutter();
  final userBox = await Hive.openBox<String>(HiveUserStore.boxName);
  final historyBox = await Hive.openBox<String>(HiveHistoryStore.boxName);

  LicenseRegistry.addLicense(_bundledFontLicenses);

  runApp(
    ProviderScope(
      overrides: [
        flagStoreProvider.overrideWithValue(PrefsFlagStore(prefs)),
        userStoreProvider.overrideWithValue(HiveUserStore(userBox)),
        historyStoreProvider.overrideWithValue(HiveHistoryStore(historyBox)),
      ],
      child: const AfaSkinApp(),
    ),
  );
}

/// Shows the bundled OFL fonts on the "Lisensi open source" page.
Stream<LicenseEntry> _bundledFontLicenses() async* {
  for (final (pkg, path) in const [
    ('Belleza font', 'assets/fonts/belleza/OFL.txt'),
    ('League Spartan font', 'assets/fonts/etna/OFL-LeagueSpartan.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([pkg], await rootBundle.loadString(path));
  }
}
