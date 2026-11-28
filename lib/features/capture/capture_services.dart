import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_services.g.dart';

enum CameraPermissionState { granted, denied, permanentlyDenied }

/// Result of asking for the storage permission the gallery needs.
enum GalleryAccessState { granted, denied }

/// Thin wrapper over permission_handler so the UI can be tested.
abstract interface class CameraPermissionService {
  Future<CameraPermissionState> status();
  Future<CameraPermissionState> request();
  Future<void> openSettings();
}

class PluginCameraPermissionService implements CameraPermissionService {
  const PluginCameraPermissionService();

  static CameraPermissionState _map(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return CameraPermissionState.granted;
    // "restricted" (parental controls) cannot be fixed by asking again.
    if (s.isPermanentlyDenied || s.isRestricted) {
      return CameraPermissionState.permanentlyDenied;
    }
    return CameraPermissionState.denied;
  }

  @override
  Future<CameraPermissionState> status() async =>
      _map(await Permission.camera.status);

  @override
  Future<CameraPermissionState> request() async =>
      _map(await Permission.camera.request());

  @override
  Future<void> openSettings() => openAppSettings();
}

/// Picks a photo from the gallery. Returns raw bytes, or null if cancelled.
abstract interface class GalleryPicker {
  Future<Uint8List?> pick();

  /// Asks for the permission the gallery needs on this Android version.
  ///
  /// Android 10-12 need READ_EXTERNAL_STORAGE to read the picked file. Without
  /// it image_picker still returns a path, but reading it throws
  /// `PlatformException(no_valid_image_uri)` — the user only sees the camera
  /// reopen with no message, which is indistinguishable from a broken button.
  Future<GalleryAccessState> ensureAccess();
}

class PluginGalleryPicker implements GalleryPicker {
  PluginGalleryPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<GalleryAccessState> ensureAccess() async {
    // On Android 13+ media picked through the Photo Picker is granted per-URI,
    // so the permission is neither declared nor needed. permission_handler
    // reports it as "denied" there, so only ask where it is meaningful.
    if (!Platform.isAndroid) return GalleryAccessState.granted;
    final status = await Permission.storage.status;
    if (status.isGranted || status.isLimited) return GalleryAccessState.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return GalleryAccessState.denied;
    }
    final asked = await Permission.storage.request();
    return asked.isGranted || asked.isLimited
        ? GalleryAccessState.granted
        : GalleryAccessState.denied;
  }

  @override
  Future<Uint8List?> pick() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    await deleteIfOwnedCopy(file.path);
    return bytes;
  }
}

/// Deletes a file only if it really is a temporary copy owned by this app.
///
/// The previous version deleted whatever path the picker returned. image_picker
/// usually copies the selection into the app's cache directory, but that is an
/// implementation detail — on some platforms and versions the path points at the
/// user's original gallery file, so deleting it blindly erased the user's photo.
/// Here the path is only removed when it lives inside our own cache directory.
Future<void> deleteIfOwnedCopy(String path) async {
  try {
    final cache = await getTemporaryDirectory();
    // Normalise BOTH sides: a plain string prefix check lets `cache/../lain/x`
    // through, and File.delete would then happily remove a file outside the
    // cache. `p.normalize` resolves "." and ".." so the comparison is real.
    final cachePath = p.normalize(p.absolute(cache.path));
    final target = p.normalize(p.absolute(path));
    if (target == cachePath) return;
    if (!p.isWithin(cachePath, target)) return;
    await File(target).delete();
  } on FileSystemException {
    // Already gone, or not ours to delete. Nothing to do.
  }
}

@Riverpod(keepAlive: true)
CameraPermissionService cameraPermission(Ref ref) =>
    const PluginCameraPermissionService();

@Riverpod(keepAlive: true)
GalleryPicker galleryPicker(Ref ref) => PluginGalleryPicker();
