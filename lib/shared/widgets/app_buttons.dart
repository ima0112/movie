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
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;

  /// Optional leading icon (the detail screens' play icon on "Trailer").
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      icon: icon,
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

/// Filled pill in `danger` red, background and border both red, dark
/// `onDanger` text — destructive actions (delete My List, delete My Tastes...).
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
      foregroundColor: AppColors.onDanger,
    );
  }
}

/// Filled pill in the `accent` (amber), `onAccent` (near-black) text, on **one
/// line** (it never grows taller: a label that doesn't fit is ellipsized).
/// Not a second primary: it is the one call-to-action of a card that sits on
/// the dark page (B1's taste card), where the amber carries the card's own
/// accent — see `docs/DESIGN_SYSTEM.md` §5.4. Never next to a [PrimaryButton].
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  /// A smaller pill (less padding, `bodySm` semibold label) for a button that
  /// sits inside a card, not at the foot of a screen.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      icon: icon,
      onTap: onTap,
      isLoading: isLoading,
      isDisabled: isDisabled,
      fullWidth: fullWidth,
      dense: dense,
      singleLine: true,
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
    );
  }
}

/// Shared pill shape, tap handling, loading spinner, and disabled dimming
/// for the button styles above.
class _BaseButton extends StatelessWidget {
  const _BaseButton({
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
    this.singleLine = false,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  /// Keep the label on one line (ellipsized) so the pill never grows taller.
  final bool singleLine;

  /// Less padding and a `bodySm` label: the in-card size.
  final bool dense;

  static const double _spinnerSize = 18;
  static const double _iconSize = 18;

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
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.lg : AppSpacing.xl,
          vertical: dense ? AppSpacing.md : AppSpacing.lg,
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: _iconSize, color: foregroundColor),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: singleLine ? 1 : null,
                        overflow: singleLine ? TextOverflow.ellipsis : null,
                        style:
                            (dense
                                    ? AppTextStyles.bodySmStrong
                                    : AppTextStyles.h3)
                                .copyWith(color: foregroundColor),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return Opacity(
      opacity: isDisabled ? _disabledOpacity : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: GestureDetector(
          onTap: isInteractive ? onTap : null,
          child: pill,
        ),
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
