import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds the single `ThemeData` for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`. Light mode is a later
/// iteration (see `docs/DECISIONS.md`) — do not implement it yet.
class AppTheme {
  const AppTheme._();

  // TODO(light-theme): implement light mode in a later iteration and
  // switch this to ThemeMode.system. See docs/DECISIONS.md.
  static const ThemeMode themeMode = ThemeMode.dark;

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      error: AppColors.danger,
      onError: AppColors.ink,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      canvasColor: AppColors.surface,
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        titleMedium: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySm,
        bodySmall: AppTextStyles.caption,
        labelSmall: AppTextStyles.micro,
      ),
      appBarTheme: AppBarTheme(
        // Every screen's title is centered, the same on iOS and Android (the
        // Material default is platform-dependent). Screens don't repeat it.
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        // One size for every app bar title: `h3`, the one the detail screens'
        // compact bar uses. Screens don't set their own.
        titleTextStyle: AppTextStyles.h3,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      // The one snackbar: a floating `surfaceRaised` pill with a hairline,
      // the action in amber (`AppSnackBar` is how it is shown).
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceRaised,
        elevation: 0,
        contentTextStyle: AppTextStyles.bodySm,
        actionTextColor: AppColors.accent,
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          0,
          AppSpacing.screenMargin,
          AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.lineStrong),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceRaised,
        // Every sheet gets the design's handle (40×4) unless it opts out.
        showDragHandle: true,
        dragHandleColor: AppColors.sheetHandle,
        dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.bottomSheetRadius,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
