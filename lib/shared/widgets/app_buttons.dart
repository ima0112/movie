// PakoTV's four button styles.
//
// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.4 and
// `docs/DECISIONS.md` section 9 ("Primary: white pill with black text.
// Secondary: pill with a thin gray border. Never two primaries.").
//
// Pure presentation — no feature dependency, everything comes in by
// parameter. All four are full width by default (pass `fullWidth: false`
// to size to content instead, e.g. two buttons side by side).

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Filled pill, `ink` (white) background, dark text. The only button that
/// should appear more than once per screen only if there's no other
/// primary action competing with it — see DECISIONS.md ("Never two
/// primaries").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      isDisabled: isDisabled,
      fullWidth: fullWidth,
      backgroundColor: AppColors.ink,
      // No token for pure black text exists — `surface` is the closest
      // near-black in the palette and reads correctly on a white pill.
      foregroundColor: AppColors.surface,
    );
  }
}

/// Outline pill: transparent background, `lineStrong` border, `ink` text.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      isDisabled: isDisabled,
      fullWidth: fullWidth,
      backgroundColor: Colors.transparent,
      borderColor: AppColors.lineStrong,
      foregroundColor: AppColors.ink,
    );
  }
}

/// Text-only link: `accent` text, no fill, no border.
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      isDisabled: isDisabled,
      fullWidth: fullWidth,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.accent,
    );
  }
}

/// Filled pill in `danger` red, background and border both red, `ink`
/// text — destructive actions (delete My List, delete My Tastes...).
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      isDisabled: isDisabled,
      fullWidth: fullWidth,
      backgroundColor: AppColors.danger,
      borderColor: AppColors.danger,
      foregroundColor: AppColors.ink,
    );
  }
}

/// Shared pill shape, tap handling, loading spinner, and disabled dimming
/// for the four button styles above.
class _BaseButton extends StatelessWidget {
  const _BaseButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  static const double _spinnerSize = 18;

  // Same convention as QuizTileState.disabled — see quiz_tile.dart.
  static const double _disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null && !isDisabled && !isLoading;

    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Center(
          widthFactor: fullWidth ? null : 1,
          child: isLoading
              ? SizedBox(
                  width: _spinnerSize,
                  height: _spinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor,
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.h3.copyWith(color: foregroundColor),
                ),
        ),
      ),
    );

    return Opacity(
      opacity: isDisabled ? _disabledOpacity : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: GestureDetector(onTap: isInteractive ? onTap : null, child: pill),
      ),
    );
  }
}

/// Toggleable icon button — favorite / watch later / watched. Outline icon
/// in `ink` when inactive, filled icon in `accent` when active.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.iconOutline,
    required this.iconFill,
    this.isActive = false,
    this.onTap,
  });

  final IconData iconOutline;
  final IconData iconFill;
  final bool isActive;
  final VoidCallback? onTap;

  // docs/SCREENS.md D1: "Row of three actions with a 24 px icon".
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isActive ? iconFill : iconOutline,
        size: _iconSize,
        color: isActive ? AppColors.accent : AppColors.ink,
      ),
    );
  }
}
