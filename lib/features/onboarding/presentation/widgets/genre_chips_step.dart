import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_chip.dart';
import 'genre_step_headline.dart';
import 'onboarding_glow_background.dart';
import 'onboarding_pager_dots.dart';
import 'step_transition.dart';

/// Step 2 — the third slide, "Make it yours" (`docs/SCREENS.md` A2): an
/// amber eyebrow, a headline with one amber word, a body line, every genre
/// as a wrapping chip (selected = amber), the fourth pagination dot, and
/// "Next". "Skip" and "Next" both just move on with whatever is selected.
///
/// Pure presentation (rule 9) — selection and callbacks come in by
/// parameter; `OnboardingGenreStep` binds it to the Cubit.
class GenreChipsStep extends StatelessWidget {
  const GenreChipsStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onSkip,
    required this.onNext,
  });

  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StepTransition(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: OnboardingGlowBackground(
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      l10n.commonSkip,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
                // Scrolls (and centers when there is room) so a small
                // device, large text, or a long Spanish list never
                // overflows (CLAUDE.md rule 14).
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.onboardingLikedEyebrow.toUpperCase(),
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GenreStepHeadline(
                              text: l10n.onboardingLikedHeadline,
                              highlightWord: l10n.onboardingLikedHighlight,
                              style: AppTextStyles.display,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l10n.onboardingLikedBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final (genre, _) in genreOptions)
                                  AppChip(
                                    label: genre.localizedName(l10n),
                                    state: selected.contains(genre)
                                        ? ChipState.selected
                                        : ChipState.normal,
                                    onTap: () => onToggle(genre),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const OnboardingPagerDots(
                  count: OnboardingPagerDots.total,
                  activeIndex: OnboardingPagerDots.likedDot,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: PrimaryButton(label: l10n.commonNext, onTap: onNext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
