import 'package:flutter/material.dart';
import '../../../../shared/widgets/overline_label.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_wordmark.dart';
import 'poster_wall.dart';

/// Step 0 — `docs/SCREENS.md` A2: poster wall under a dark overlay that
/// goes solid by 78% of the height, the 48 px "PakoTV" wordmark with a
/// spaced-out tagline, TMDB's attribution line, and "Get started"
/// (the "Onboarding 0 · Bienvenida" design — no mascot).
///
/// Pure presentation (CLAUDE.md rule 9) — [posterUrls] and
/// [onGetStarted] are supplied by whatever screen eventually wires up
/// `OnboardingCubit` and `MediaRepository.getCarouselSection
/// (CarouselSection.popularThisWeek)`; neither is built yet.
class WelcomeView extends StatelessWidget {
  const WelcomeView({
    super.key,
    this.posterUrls = const [],
    required this.onGetStarted,
  });

  final List<String?> posterUrls;
  final VoidCallback onGetStarted;

  static const double _wordmarkSize = 48;

  // surface at 55% / 35% / 90% — the poster wall's dimming stops.
  static const Color _overlayTop = Color(0x8C0B0B0D);
  static const Color _overlayMid = Color(0x590B0B0D);
  static const Color _overlayLow = Color(0xE60B0B0D);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Scaffold, not ColoredBox — this is now a self-contained "screen"
    // (OnboardingFlow no longer wraps the active step in a Scaffold of
    // its own, see onboarding_scaffold.dart's doc comment), and without
    // a Material ancestor every Text here would fall back to Flutter's
    // debug style the same way splash_screen.dart's own did.
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PosterWall(posterUrls: posterUrls),
          // Overlay from the design: dimmed poster wall at the top, 90%
          // dark by 62% of the height, solid from 78%.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.3, 0.62, 0.78],
                colors: [
                  _overlayTop,
                  _overlayMid,
                  _overlayLow,
                  AppColors.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              // CustomScrollView + SliverFillRemaining(hasScrollBody:
              // false) — same reasoning as name_step_form.dart: fills
              // at least the available height (so "end" alignment still
              // anchors content to the bottom on a normal device) but
              // scrolls instead of overflowing once a small device or
              // reduced height can't fit it all (CLAUDE.md rule 14).
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const AppWordmark(size: _wordmarkSize),
                        const SizedBox(height: AppSpacing.sm),
                        OverlineLabel(
                          l10n.onboardingWelcomeTagline,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxxl * 2),
                        // TMDB's required wording (same text as C7).
                        Text(
                          l10n.attributionTmdbBody,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: l10n.onboardingWelcomeGetStarted,
                          onTap: onGetStarted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
