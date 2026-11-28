import 'dart:io';

import 'package:afaskin/features/capture/capture_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Path provider yang mengembalikan direktori sementara uji.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);
  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory cache;
  late Directory galeri;

  setUp(() {
    cache = Directory.systemTemp.createTempSync('afaskin_cache_');
    galeri = Directory.systemTemp.createTempSync('afaskin_galeri_');
    PathProviderPlatform.instance = _FakePathProvider(cache.path);
  });

  tearDown(() {
    for (final d in [cache, galeri]) {
      if (d.existsSync()) d.deleteSync(recursive: true);
    }
  });

  group('deleteIfOwnedCopy', () {
    test('menghapus salinan sementara di dalam cache aplikasi', () async {
      final salinan = File('${cache.path}/picker_copy.jpg')
        ..writeAsBytesSync([1, 2, 3]);

      await deleteIfOwnedCopy(salinan.path);

      expect(salinan.existsSync(), isFalse,
          reason: 'salinan milik aplikasi boleh dihapus');
    });

    test('TIDAK menghapus foto asli pengguna di luar cache', () async {
      // Ini kasus yang dulu berbahaya: image_picker mengembalikan path ke berkas
      // asli di galeri, lalu aplikasi menghapusnya.
      final asli = File('${galeri.path}/foto_pengguna.jpg')
        ..writeAsBytesSync([9, 9, 9]);

      await deleteIfOwnedCopy(asli.path);

      expect(asli.existsSync(), isTrue,
          reason: 'foto asli pengguna tidak boleh terhapus');
      expect(asli.readAsBytesSync(), [9, 9, 9]);
    });

    test('tidak menghapus direktori yang namanya berawalan sama dengan cache',
        () async {
      // Jebakan prefix: /tmp/x/cache2 bukan bagian dari /tmp/x/cache.
      final tetangga = Directory('${cache.path}2')..createSync(recursive: true);
      final berkas = File('${tetangga.path}/foto.jpg')
        ..writeAsBytesSync([7]);
      addTearDown(() {
        if (tetangga.existsSync()) tetangga.deleteSync(recursive: true);
      });

      await deleteIfOwnedCopy(berkas.path);

      expect(berkas.existsSync(), isTrue,
          reason: 'cache2 bukan cache, berkasnya tidak boleh dihapus');
    });

    test('tidak melempar bila berkas sudah tidak ada', () async {
      await expectLater(
        deleteIfOwnedCopy('${cache.path}/sudah_hilang.jpg'),
        completes,
      );
    });

    test('menolak path yang menembus keluar cache', () async {
      final asli = File('${galeri.path}/rahasia.jpg')..writeAsBytesSync([5]);
      // Path dengan ".." yang secara string tidak berawalan cache.
      final menembus = '${cache.path}/../${galeri.path.split(Platform.pathSeparator).last}/rahasia.jpg';

      await deleteIfOwnedCopy(menembus);

      expect(asli.existsSync(), isTrue,
          reason: 'traversal tidak boleh mencapai berkas di luar cache');
    });
  });
}
