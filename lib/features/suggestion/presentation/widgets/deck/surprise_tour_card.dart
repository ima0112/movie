import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/app_buttons.dart';

/// The text card of Surprise me's first-time tour: a [title] and [body], the
/// progress dots, and the buttons — "Skip" and "Next" on the first steps, "Back"
/// and "Got it" on the last. Pure presentation — everything comes in by
/// parameter.
class SurpriseTourCard extends StatelessWidget {
  const SurpriseTourCard({
    super.key,
    required this.title,
    required this.body,
    required this.step,
    required this.steps,
    required this.onSkip,
    required this.onBack,
    required this.onNext,
    required this.onDone,
  });

  final String title;
  final String body;

  /// 0-based.
  final int step;
  final int steps;

  /// First steps: "Skip" (a no-op on the last).
  final VoidCallback onSkip;

  /// Last step: "Back".
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onDone;

  bool get _isLast => step == steps - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(title, style: AppTextStyles.h3),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Semantics(
                  label: l10n.surpriseTourStep(step + 1, steps),
                  excludeSemantics: true,
                  child: _Dots(step: step, steps: steps),
                ),
                const Spacer(),
                TextLinkButton(
                  label: _isLast
                      ? l10n.surpriseTourBack
                      : l10n.surpriseTourSkip,
                  fullWidth: false,
                  onTap: _isLast ? onBack : onSkip,
                ),
                const SizedBox(width: AppSpacing.sm),
                AccentButton(
                  label: _isLast
                      ? l10n.surpriseTourDone
                      : l10n.surpriseTourNext,
                  fullWidth: false,
                  dense: true,
                  onTap: _isLast ? onDone : onNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The progress dots: the current step is a longer amber pill.
class _Dots extends StatelessWidget {
  const _Dots({required this.step, required this.steps});

  final int step;
  final int steps;

  static const double _dot = 6;
  static const double _current = 18;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == step ? _current : _dot,
            height: _dot,
            decoration: BoxDecoration(
              color: i == step ? AppColors.accent : AppColors.lineStrong,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
        ],
      ],
    );
  }
}
