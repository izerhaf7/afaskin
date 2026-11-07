import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:afaskin/core/l10n/app_strings.dart';

/// What the live guidance tells the user. Ordered by priority: the first
/// failing check wins, so the user fixes one thing at a time.
enum GuidanceStatus {
  noFace,
  multipleFaces,
  tooDark,
  tooBright,
  tooFar,
  tooClose,
  offCenter,
  notFrontal,
  turnHead,
  turnOtherSide,
  turnLess,
  ready;

  bool get isReady => this == ready;

  String get message => switch (this) {
    noFace => AppStrings.guideNoFace,
    multipleFaces => AppStrings.guideMultipleFaces,
    tooDark => AppStrings.guideTooDark,
    tooBright => AppStrings.guideTooBright,
    tooFar => AppStrings.guideTooFar,
    tooClose => AppStrings.guideTooClose,
    offCenter => AppStrings.guideOffCenter,
    notFrontal => AppStrings.guideNotFrontal,
    turnHead => AppStrings.guideTurnHead,
    turnOtherSide => AppStrings.guideTurnOtherSide,
    turnLess => AppStrings.guideTurnLess,
    ready => AppStrings.guideReady,
  };
}

/// Which photo of the three-view capture is being taken.
///
/// `side` covers both side photos: the user turns to either side first, then
/// to the other one. The server works out which cheek is facing the camera,
/// so the app never has to tell left from right (the front camera mirrors).
enum CapturePose { front, side }

/// One detected face, already converted to the preview's coordinate space:
/// [box] normalized 0-1, x mirrored for the front camera.
class FaceObservation {
  const FaceObservation({required this.box, this.yaw, this.pitch});

  final Rect box;

  /// Head Euler angle Y (left/right turn), degrees.
  final double? yaw;

  /// Head Euler angle X (up/down tilt), degrees.
  final double? pitch;
}

/// Thresholds, in one place so they can be tuned on real devices.
class GuidanceConfig {
  const GuidanceConfig({
    this.oval = const Rect.fromLTWH(0.18, 0.14, 0.64, 0.62),
    this.minLuminance = 70,
    this.maxLuminance = 215,
    this.minFaceToOvalWidth = 0.60,
    this.maxFaceToOvalWidth = 1.15,
    this.maxCenterOffset = 0.30,
    this.maxAngle = 15,
    this.minSideAngle = 20,
    this.maxSideAngle = 50,
  });

  /// Guide oval, normalized to the preview.
  final Rect oval;

  /// Mean luma (0-255) bounds.
  final double minLuminance;
  final double maxLuminance;

  /// Face box width relative to the oval width.
  final double minFaceToOvalWidth;
  final double maxFaceToOvalWidth;

  /// Face center distance from oval center, in units of the oval radii
  /// (0 = centered, 1 = on the oval edge).
  final double maxCenterOffset;

  /// Max |yaw| and |pitch| in degrees.
  final double maxAngle;

  /// Side photo: |yaw| must be within [minSideAngle, maxSideAngle] degrees.
  /// Around 30° shows the cheek and jawline while the server can still find
  /// the face landmarks.
  final double minSideAngle;
  final double maxSideAngle;
}

/// Pure guidance rule: faces + frame luminance -> status.
///
/// [luminance] is null when it could not be measured; the brightness check
/// is skipped then (the server-side quality gate still applies).
///
/// For [CapturePose.side], [avoidYawSign] is the sign of the yaw of the side
/// photo already taken (if any): the next one must turn the other way.
GuidanceStatus evaluateGuidance({
  required List<FaceObservation> faces,
  required double? luminance,
  GuidanceConfig config = const GuidanceConfig(),
  CapturePose pose = CapturePose.front,
  double? avoidYawSign,
}) {
  if (luminance != null && luminance < config.minLuminance) {
    // Too dark comes first: face detection itself is unreliable in the dark.
    return GuidanceStatus.tooDark;
  }
  if (faces.isEmpty) return GuidanceStatus.noFace;
  if (faces.length > 1) return GuidanceStatus.multipleFaces;
  if (luminance != null && luminance > config.maxLuminance) {
    return GuidanceStatus.tooBright;
  }

  final face = faces.single;
  final oval = config.oval;

  final widthRatio = face.box.width / oval.width;
  if (widthRatio < config.minFaceToOvalWidth) return GuidanceStatus.tooFar;
  if (widthRatio > config.maxFaceToOvalWidth) return GuidanceStatus.tooClose;

  final d = face.box.center - oval.center;
  final offset = math.sqrt(
    math.pow(d.dx / (oval.width / 2), 2) +
        math.pow(d.dy / (oval.height / 2), 2),
  );
  // A turned head shifts the detected box sideways: allow more slack.
  final maxOffset = pose == CapturePose.side
      ? config.maxCenterOffset * 1.5
      : config.maxCenterOffset;
  if (offset > maxOffset) return GuidanceStatus.offCenter;

  final yaw = face.yaw ?? 0;
  final pitch = face.pitch ?? 0;
  if (pose == CapturePose.side) {
    // No yaw reported: cannot verify the turn, let the server decide.
    if (face.yaw == null) return GuidanceStatus.ready;
    if (avoidYawSign != null && yaw.sign == avoidYawSign.sign) {
      return GuidanceStatus.turnOtherSide;
    }
    if (yaw.abs() < config.minSideAngle) return GuidanceStatus.turnHead;
    if (yaw.abs() > config.maxSideAngle) return GuidanceStatus.turnLess;
    if (pitch.abs() > config.maxAngle) return GuidanceStatus.notFrontal;
    return GuidanceStatus.ready;
  }
  if (yaw.abs() > config.maxAngle || pitch.abs() > config.maxAngle) {
    return GuidanceStatus.notFrontal;
  }
  return GuidanceStatus.ready;
}

/// Maps an ML Kit bounding box (pixels in the upright image of
/// [uprightWidth] x [uprightHeight]) to the normalized, mirrored preview
/// space used by [evaluateGuidance] and the overlay.
Rect normalizeFaceBox(
  Rect box, {
  required double uprightWidth,
  required double uprightHeight,
  required bool mirror,
}) {
  final left = box.left / uprightWidth;
  final right = box.right / uprightWidth;
  return Rect.fromLTRB(
    mirror ? 1 - right : left,
    box.top / uprightHeight,
    mirror ? 1 - left : right,
    box.bottom / uprightHeight,
  );
}

/// Mean of a luma (Y) plane, sampling every [step]-th pixel on every
/// [step]-th row. Works for NV21 / YUV420 (first plane is Y).
double meanLuma(
  List<int> yPlane, {
  required int width,
  required int height,
  required int bytesPerRow,
  int step = 8,
}) {
  var sum = 0;
  var n = 0;
  for (var y = 0; y < height; y += step) {
    final row = y * bytesPerRow;
    for (var x = 0; x < width; x += step) {
      final i = row + x;
      if (i >= yPlane.length) break;
      sum += yPlane[i];
      n++;
    }
  }
  return n == 0 ? 0 : sum / n;
}

/// Mean luma of a BGRA8888 frame (iOS), Rec. 601 weights.
double meanLumaBgra(
  List<int> bytes, {
  required int width,
  required int height,
  required int bytesPerRow,
  int step = 8,
}) {
  var sum = 0.0;
  var n = 0;
  for (var y = 0; y < height; y += step) {
    for (var x = 0; x < width; x += step) {
      final i = y * bytesPerRow + x * 4;
      if (i + 2 >= bytes.length) break;
      sum += 0.114 * bytes[i] + 0.587 * bytes[i + 1] + 0.299 * bytes[i + 2];
      n++;
    }
  }
  return n == 0 ? 0 : sum / n;
}

/// Convenience for tests and overlay drawing.
Offset ovalCenter([GuidanceConfig c = const GuidanceConfig()]) => c.oval.center;
