import 'dart:typed_data';

import 'package:afaskin/data/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analysis_flow.g.dart';

/// The processed (resized, EXIF-free) JPEG waiting to be analyzed.
/// Memory only: never written to disk, cleared once the server has it.
@Riverpod(keepAlive: true)
class PendingPhoto extends _$PendingPhoto {
  @override
  Uint8List? build() => null;

  // A method reads better than a setter on a notifier (`.notifier).set(x)`).
  // ignore: use_setters_to_change_properties
  void set(Uint8List bytes) => state = bytes;
  void clear() => state = null;
}

/// Optional side photos (0-2, already processed) taken after the front one.
/// Memory only, like [PendingPhoto].
class PendingSidePhotos extends Notifier<List<Uint8List>> {
  @override
  List<Uint8List> build() => const [];

  void add(Uint8List bytes) => state = [...state, bytes];
  void clear() => state = const [];
}

final pendingSidePhotosProvider =
    NotifierProvider<PendingSidePhotos, List<Uint8List>>(PendingSidePhotos.new);

/// The front photo of the latest analysis, kept in MEMORY ONLY so the result
/// screen can draw the face map on the user's own photo. Never written to
/// disk; gone when the app closes, on a new analysis, or on "hapus semua data".
class LatestAnalysisPhoto
    extends Notifier<({String analysisId, Uint8List jpeg})?> {
  @override
  ({String analysisId, Uint8List jpeg})? build() => null;

  // ignore: use_setters_to_change_properties
  void set(String analysisId, Uint8List jpeg) =>
      state = (analysisId: analysisId, jpeg: jpeg);
  void clear() => state = null;
}

final latestAnalysisPhotoProvider =
    NotifierProvider<
      LatestAnalysisPhoto,
      ({String analysisId, Uint8List jpeg})?
    >(LatestAnalysisPhoto.new);

/// Result of the most recent analysis, shown on the result screen.
@Riverpod(keepAlive: true)
class LatestAnalysis extends _$LatestAnalysis {
  @override
  AnalysisResult? build() => null;

  // A method reads better than a setter on a notifier (`.notifier).set(x)`).
  // ignore: use_setters_to_change_properties
  void set(AnalysisResult result) => state = result;
}
