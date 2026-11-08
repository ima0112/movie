import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_halo.dart';
import '../../../../shared/widgets/pako_state.dart';
import 'poster_wall.dart';

/// Step 0 — `docs/SCREENS.md` A2: poster wall, fade to black from 30%
/// to 62% of the height, amber halo, Pako in `idle` on the fade line,
/// "Hi, I'm Pako", one subtitle line, "Get started", TMDB attribution.
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

  @override
  Widget build(BuildContext context) {
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
          const Align(alignment: Alignment.topCenter, child: AppHalo()),
          // "Fade to black from 30% to 62%" (docs/SCREENS.md A2) plus a
          // short fade at the very top — not in that spec, but without
          // it a poster tile can get hard-clipped right under the
          // status bar/notch with no visual softening at all.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.1, 0.3, 0.62],
                colors: [
                  AppColors.surface,
                  Colors.transparent,
                  Colors.transparent,
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
                        const PakoState(mood: PakoMood.idle, size: 96),
                        const SizedBox(height: AppSpacing.lg),
                        // docs/SCREENS.md A2: "Hi, I'm Pako" at 28 px —
                        // no exact token for 28; h1 (26) is the closest.
                        Text(
                          "Hi, I'm Pako",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "I'll help you find something to watch, alone "
                          'or with friends.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: 'Get started',
                          onTap: onGetStarted,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Data from TMDB',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.inkDim,
                          ),
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
