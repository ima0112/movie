import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'intro_mock_palette.dart';

/// The second slide's mini Surprise-me result, drawn inside the phone
/// frame: a backdrop that fades to black, a "based on your tastes" tag,
/// the suggestion, and the two action buttons. Positions follow the
/// "Onboarding 2 · Sorpréndeme" design.
class IntroSurpriseMock extends StatelessWidget {
  const IntroSurpriseMock({super.key});

  static const double _backdropHeight = 330;
  static const double _buttonHeight = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: _backdropHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: IntroMockPalette.backdropTeal),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: _backdropHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 1],
                colors: [
                  AppColors.surface.withValues(alpha: 0.3),
                  AppColors.surface.withValues(alpha: 0),
                  AppColors.surface,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: 236,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.surpriseSourceProfile.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Sample title and year/runtime, not UI copy.
              Text(
                'Arrival',
                style: AppTextStyles.h2,
              ), // l10n-exempt: sample-title
              const SizedBox(height: AppSpacing.xs),
              Text(
                '2016 · ${l10n.myListRuntimeHoursMinutes(1, 56)}', // l10n-exempt: sample-meta
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: 344,
          child: _MockButton(label: l10n.surpriseAddToWatchLater, filled: true),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: 392,
          child: _MockButton(
            label: l10n.surpriseAnotherSuggestion,
            filled: false,
          ),
        ),
      ],
    );
  }
}

class _MockButton extends StatelessWidget {
  const _MockButton({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: IntroSurpriseMock._buttonHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: filled ? null : Border.all(color: AppColors.sheetHandle),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: filled ? AppColors.onAccent : AppColors.ink,
        ),
      ),
    );
  }
}
