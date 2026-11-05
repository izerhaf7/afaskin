import 'package:json_annotation/json_annotation.dart';

/// Skin type classes from the skin-type model.
@JsonEnum(fieldRename: FieldRename.snake)
enum SkinType { oily, dry, normal, unknown }

/// The 9 skin-condition classes from the condition model.
@JsonEnum(fieldRename: FieldRename.snake)
enum SkinConditionLabel {
  acne,
  birthmark,
  blackhead,
  cysts,
  milium,
  papular,
  purulent,
  scars,
  whitehead,
  unknown;

  /// Conditions where the app should actively suggest seeing a dermatologist.
  bool get suggestsDermatologist =>
      this == SkinConditionLabel.cysts || this == SkinConditionLabel.purulent;
}

/// Regions of interest extracted with MediaPipe Face Mesh.
@JsonEnum(fieldRename: FieldRename.snake)
enum FaceRegion { forehead, leftCheek, rightCheek, nose, chin, unknown }

@JsonEnum(fieldRename: FieldRename.snake)
enum ProductCategory { cleanser, toner, serum, moisturizer, sunscreen, unknown }

@JsonEnum(fieldRename: FieldRename.snake)
enum Gender { female, male, other }
