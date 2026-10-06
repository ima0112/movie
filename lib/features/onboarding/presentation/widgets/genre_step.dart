import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/quiz_tile.dart';
import 'genre_step_headline.dart';
import 'onboarding_scaffold.dart';
import 'step_transition.dart';

/// Steps 2 and 3 — `docs/SCREENS.md` A2: "Step X of 3"/"Skip", headline,
/// 3-column grid, pill button fixed at the bottom with a 24 px fade over
/// the grid. One widget serves both steps: step 3 passes [disabledGenres]
/// (step 2's own picks, at 30% opacity, inert) and [highlightWord]
/// ("never", in amber). Pure presentation (rule 9) — no Cubit read here.
class GenreStep extends StatelessWidget {
  const GenreStep({
    super.key,
    required this.stepLabel,
    required this.headline,
    this.highlightWord,
    required this.selected,
    this.disabledGenres = const {},
    required this.onToggle,
    required this.onSkip,
    required this.nextLabel,
    required this.onNext,
  });

  final String stepLabel;
  final String headline;
  final String? highlightWord;
  final Set<Genre> selected;
  final Set<Genre> disabledGenres;
  final ValueChanged<Genre> onToggle;
  final VoidCallback onSkip;
  final String nextLabel;
  final VoidCallback onNext;

  static const int _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    return StepTransition(
      child: OnboardingScaffold(
        stepLabel: stepLabel,
        onSkip: onSkip,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            GenreStepHeadline(text: headline, highlightWord: highlightWord),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.xxxl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1,
                ),
                itemCount: genreOptions.length,
                itemBuilder: (context, index) {
                  final (genre, icon) = genreOptions[index];
                  final isSelected = selected.contains(genre);
                  final isDisabled = disabledGenres.contains(genre);
                  return QuizTile(
                    icon: icon,
                    label: genre.name,
                    state: isSelected
                        ? QuizTileState.selected
                        : (isDisabled
                              ? QuizTileState.disabled
                              : QuizTileState.normal),
                    onTap: isDisabled ? null : () => onToggle(genre),
                  );
                },
              ),
            ),
          ],
        ),
        footer: PrimaryButton(label: nextLabel, onTap: onNext),
      ),
    );
  }
}
