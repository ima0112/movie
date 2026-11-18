import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'surprise_card_fan.dart';
import 'surprise_star_row.dart';

/// E3a — Surprise me's "Searching" screen (`docs/SCREENS.md` E3a): a solid
/// page with a "×" at the top left, the "SURPRISE ME" eyebrow, the shuffling
/// fan of "?" cards, "Shuffling your 5 surprises" with its line and the
/// pulsing stars. It shows while the suggestions are computed, whatever the
/// type or source.
///
/// The column is flexible (spacers between the blocks), not pinned to fixed
/// offsets, so it breathes on a tall phone and still fits a short one; it
/// scrolls when the text is large.
///
/// Pure presentation — [onCancel] comes in by parameter.
class SurpriseSearchingView extends StatelessWidget {
  const SurpriseSearchingView({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        icon: const Icon(AppIcons.close, color: AppColors.ink),
                        onPressed: onCancel,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.matchHubSurpriseMeTitle.toUpperCase(),
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const Spacer(flex: 2),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SurpriseCardFan(),
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      label: l10n.surpriseShufflingTitle,
                      excludeSemantics: true,
                      child: Column(
                        children: [
                          Text(
                            l10n.surpriseShufflingTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1Strong,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.surpriseShufflingSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SurpriseStarRow(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
