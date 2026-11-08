import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'genre_step.dart';

/// Binds [GenreStep] to `OnboardingCubit` for both step 2 (liked) and
/// step 3 (vetoed) — one widget, like `GenreStep` itself, since the two
/// only differ in copy/which set is which (`docs/SCREENS.md` A2).
///
/// [onFinish] is only used on step 3, where both "Skip" and the main
/// pill button are the flow's last action; step 2's own "Skip" and
/// "Next" both just mean "advance with whatever's selected, even
/// nothing" — the same `OnboardingCubit.next()` call either way, so
/// there's no separate "skip the whole rest of the flow" shortcut here,
/// only "move past *this* step."
class OnboardingGenreStep extends StatelessWidget {
  const OnboardingGenreStep({
    super.key,
    required this.isVetoedStep,
    required this.onFinish,
  });

  final bool isVetoedStep;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocSelector<
      OnboardingCubit,
      OnboardingState,
      (Set<Genre>, Set<Genre>)
    >(
      selector: (state) => (state.likedGenres, state.vetoedGenres),
      builder: (context, data) {
        final (liked, vetoed) = data;
        if (isVetoedStep) {
          return GenreStep(
            stepLabel: 'Step 3 of 3',
            headline: 'And which ones never?',
            highlightWord: 'never',
            selected: vetoed,
            disabledGenres: liked,
            onToggle: cubit.toggleVetoedGenre,
            onSkip: onFinish,
            nextLabel: 'Done',
            onNext: onFinish,
          );
        }
        return GenreStep(
          stepLabel: 'Step 2 of 3',
          headline: 'What genres do you like?',
          selected: liked,
          onToggle: cubit.toggleLikedGenre,
          onSkip: cubit.next,
          nextLabel: 'Next',
          onNext: cubit.next,
        );
      },
    );
  }
}
