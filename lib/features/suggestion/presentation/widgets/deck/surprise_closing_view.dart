import 'package:flutter/material.dart';

import '../../../../../app/router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../cubit/surprise_state.dart';
import 'surprise_affinity_ring.dart';
import 'surprise_deck_top_bar.dart';
import 'surprise_sparkles.dart';
import 'surprise_suggestion_card.dart';
import 'surprise_thumbnail_strip.dart';

/// The closing screen — "Your surprise of the day" (`docs/SCREENS.md` E3): the
/// strip (inactive, the chosen thumbnail with its check), the chosen card alone
/// among sparkles, its affinity ring next to an "In Watch later" line, and a
/// "View details" link. Nothing here changes any more, so it is built once from
/// the [SurpriseChosen] it is given.
class SurpriseClosingView extends StatelessWidget {
  const SurpriseClosingView({
    super.key,
    required this.chosen,
    required this.onClose,
  });

  final SurpriseChosen chosen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = chosen.chosen;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  SurpriseDeckTopBar(
                    title: l10n.surpriseChosenLabel,
                    onClose: onClose,
                  ),
                  SurpriseThumbnailStrip(
                    posterUrls: [
                      for (final s in chosen.suggestions) s.item.posterUrl,
                    ],
                    currentIndex: chosen.index,
                    savedIndexes: {
                      for (var i = 0; i < chosen.suggestions.length; i++)
                        if (chosen.savedKeys.contains(
                          chosen.suggestions[i].item.key,
                        ))
                          i,
                    },
                    chosenIndex: chosen.index,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: _Entrance(
                      child: Stack(
                        children: [
                          const Positioned.fill(child: SurpriseSparkles()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxl,
                            ),
                            child: SurpriseSuggestionCard(
                              suggestion: card,
                              number: chosen.index + 1,
                              total: chosen.suggestions.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SurpriseAffinityRing(percent: card.affinityPercent),
                      const SizedBox(width: AppSpacing.lg),
                      const Icon(
                        AppIcons.watchLaterFill,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.surpriseChosenInWatchLater,
                        style: AppTextStyles.bodySmStrong,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    child: TextButton(
                      onPressed: () => context.pushMediaDetail(card.item.key),
                      child: Text(l10n.surpriseViewDetailsLink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card settles in: a short fade and grow. Still with "reduce motion".
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: child,
    );
  }
}
