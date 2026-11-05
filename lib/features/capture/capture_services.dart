import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_services.g.dart';

enum CameraPermissionState { granted, denied, permanentlyDenied }

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
/// The temporary copy the picker makes is deleted right away (privacy).
abstract interface class GalleryPicker {
  Future<Uint8List?> pick();
}

class PluginGalleryPicker implements GalleryPicker {
  PluginGalleryPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    await deleteQuietly(file.path);
    return bytes;
  }
}

/// Deletes a temp file, ignoring errors (e.g. already gone, not ours).
Future<void> deleteQuietly(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    // Nothing to do.
  }
}

@Riverpod(keepAlive: true)
CameraPermissionService cameraPermission(Ref ref) =>
    const PluginCameraPermissionService();

@Riverpod(keepAlive: true)
GalleryPicker galleryPicker(Ref ref) => PluginGalleryPicker();
