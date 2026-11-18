import 'package:flutter/material.dart';

import '../../../../../app/router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../cubit/surprise_state.dart';
import 'surprise_affinity_ring.dart';
import 'surprise_in_watch_later_badge.dart';
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
                  _TopRow(
                    onClose: onClose,
                    strip: SurpriseThumbnailStrip(
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
                  ),
                  Text(
                    l10n.surpriseChosenLabel.toUpperCase(),
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: _Entrance(
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: SurpriseSparkles.behind(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenMargin,
                            ),
                            // The one way to the full detail: tap the card you
                            // chose.
                            child: Semantics(
                              button: true,
                              hint: l10n.surpriseViewDetailsLink,
                              child: GestureDetector(
                                onTap: () =>
                                    context.pushMediaDetail(card.item.key),
                                child: _ChosenFrame(
                                  child: SurpriseSuggestionCard(
                                    suggestion: card,
                                    number: chosen.index + 1,
                                    total: chosen.suggestions.length,
                                    showAffinity: false,
                                    topAction:
                                        const SurpriseInWatchLaterBadge(),
                                    bottomEnd: SurpriseAffinityRing(
                                      percent: card.affinityPercent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // A few stars over the card itself.
                          const Positioned.fill(
                            child: SurpriseSparkles.front(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.screenMargin),
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

/// The "×" on the left and the strip centred on the page, on one line.
class _TopRow extends StatelessWidget {
  const _TopRow({required this.onClose, required this.strip});

  final VoidCallback onClose;
  final Widget strip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(AppIcons.close, color: AppColors.ink),
            onPressed: onClose,
          ),
        ),
        Expanded(child: Center(child: strip)),
        // As wide as the button, so the strip is centred on the page.
        const SizedBox(width: kMinInteractiveDimension + 2 * AppSpacing.sm),
      ],
    );
  }
}

/// The chosen card's frame: an amber border and a soft amber glow around it.
class _ChosenFrame extends StatelessWidget {
  const _ChosenFrame({required this.child});

  final Widget child;

  static const double _border = 2;
  static const double _glowBlur = 28;
  static const double _glowAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusXxl);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: _glowAlpha),
            blurRadius: _glowBlur,
          ),
        ],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.accent, width: _border),
        ),
        child: child,
      ),
    );
  }
}
