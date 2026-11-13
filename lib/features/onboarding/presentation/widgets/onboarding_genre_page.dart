import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/genre_multi_select_chips.dart';
import 'genre_step_headline.dart';
import 'onboarding_glow_background.dart';
import 'onboarding_pager_dots.dart';
import 'step_transition.dart';

/// The layout both genre steps share (`docs/SCREENS.md` A2): "Make it yours"
/// ([GenreChipsStep], the genres you like) and "And which ones never?"
/// ([VetoedGenresStep], the ones you avoid). On the warm glow: "Skip" top
/// right, then — centered, scrolling if a small phone or a large text size
/// leaves too little room — the amber eyebrow, the headline with its one
/// highlighted word, the body, every genre as a wrapping chip
/// ([GenreMultiSelectChips]), and at the foot the pagination dots and the amber
/// button.
///
/// What differs between the two steps comes in by parameter: the copy, the
/// highlight color, how a picked chip looks ([selectedState] — amber, or red and
/// struck through for the avoided ones, as in My Tastes) and the [disabled]
/// genres (the ones already picked on the other list: dimmed and inert).
///
/// Pure presentation (rule 9) — selection and callbacks come in by parameter;
/// `OnboardingGenreStep` binds it to the Cubit.
class OnboardingGenrePage extends StatelessWidget {
  const OnboardingGenrePage({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.highlightWord,
    this.highlightColor = AppColors.accent,
    required this.body,
    required this.selected,
    this.disabled = const {},
    this.selectedState = ChipState.selected,
    required this.onToggle,
    required this.dot,
    required this.buttonLabel,
    required this.onSkip,
    required this.onNext,
  });

  final String eyebrow;
  final String headline;
  final String highlightWord;
  final Color highlightColor;
  final String body;
  final Set<Genre> selected;
  final Set<Genre> disabled;
  final ChipState selectedState;
  final ValueChanged<Genre> onToggle;

  /// Which pagination dot is the active one.
  final int dot;
  final String buttonLabel;
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
                // Scrolls (and centers when there is room) so a small device,
                // large text or a long Spanish list never overflows
                // (CLAUDE.md rule 14).
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
                              eyebrow.toUpperCase(),
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GenreStepHeadline(
                              text: headline,
                              highlightWord: highlightWord,
                              highlightColor: highlightColor,
                              style: AppTextStyles.display,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              body,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            GenreMultiSelectChips(
                              genres: [for (final (g, _) in genreOptions) g],
                              selected: selected,
                              disabled: disabled,
                              selectedState: selectedState,
                              onToggle: onToggle,
                              alignment: WrapAlignment.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OnboardingPagerDots(
                  count: OnboardingPagerDots.total,
                  activeIndex: dot,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: AccentButton(label: buttonLabel, onTap: onNext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
