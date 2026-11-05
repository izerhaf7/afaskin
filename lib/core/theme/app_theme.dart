import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/theme/app_typography.dart';

/// Material 3 theme built by hand from the Copal tokens (no `fromSeed`).
abstract final class AppTheme {
  static final ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    // Ink is the primary action color: white label on ink = 11.5:1.
    primary: AppColors.ink,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.mist,
    onPrimaryContainer: AppColors.ink,
    // Sage is an accent only. "onSecondary" is white but only for icons.
    secondary: AppColors.sage,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.mist,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.positive,
    onTertiary: AppColors.white,
    error: AppColors.danger,
    onError: AppColors.white,
    errorContainer: AppColors.statusTint(AppColors.danger),
    onErrorContainer: AppColors.danger,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    // Keep secondary text on ink, never sage (sage fails body contrast).
    onSurfaceVariant: AppColors.ink,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.white,
    surfaceContainer: AppColors.white,
    surfaceContainerHigh: AppColors.white,
    surfaceContainerHighest: AppColors.mist,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    shadow: AppColors.ink,
    scrim: AppColors.ink,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.mist,
    surfaceTint: Colors.transparent,
  );

  static final ThemeData light = _build();

  static ThemeData _build() {
    final text = AppTypography.textTheme;

    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    );
    const buttonMinSize = Size(64, 52);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.mist,
      canvasColor: AppColors.mist,
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.mist,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),

      // Primary button: ink fill + white Etna label.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMinSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? AppColors.outline
                : AppColors.ink,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? AppColors.disabledForeground
                : AppColors.white,
          ),
          overlayColor: WidgetStatePropertyAll(
            AppColors.white.withValues(alpha: 0.12),
          ),
        ),
      ),

      // Secondary button: sage outline + ink label.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMinSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? AppColors.disabledForeground
                : AppColors.ink,
          ),
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(
              color: s.contains(WidgetState.disabled)
                  ? AppColors.outline
                  : AppColors.sage,
              width: 1.5,
            ),
          ),
          overlayColor: WidgetStatePropertyAll(
            AppColors.sage.withValues(alpha: 0.12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
          overlayColor: WidgetStatePropertyAll(
            AppColors.sage.withValues(alpha: 0.12),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
          overlayColor: WidgetStatePropertyAll(
            AppColors.sage.withValues(alpha: 0.12),
          ),
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: AppColors.outline),
        ),
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: text.bodyLarge,
        floatingLabelStyle: text.bodyMedium,
        hintStyle: text.bodyLarge?.copyWith(
          color: AppColors.ink.withValues(alpha: 0.70),
        ),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: AppColors.danger),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.sage, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.sageTint,
        disabledColor: AppColors.mist,
        checkmarkColor: AppColors.ink,
        labelStyle: text.labelMedium,
        side: const BorderSide(color: AppColors.outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sage,
        linearTrackColor: AppColors.outline,
        circularTrackColor: AppColors.outline,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sage,
        inactiveTrackColor: AppColors.outline,
        thumbColor: AppColors.ink,
        overlayColor: AppColors.sage.withValues(alpha: 0.12),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.ink
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.sageTint,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.ink),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.white,
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.white),
        actionTextColor: AppColors.mist,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
      ),
    );
  }
}
