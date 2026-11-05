import 'dart:typed_data';

import 'package:afaskin/data/models/models.dart';
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

/// Result of the most recent analysis, shown on the result screen.
@Riverpod(keepAlive: true)
class LatestAnalysis extends _$LatestAnalysis {
  @override
  AnalysisResult? build() => null;

  // A method reads better than a setter on a notifier (`.notifier).set(x)`).
  // ignore: use_setters_to_change_properties
  void set(AnalysisResult result) => state = result;
}
