import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'genre_chips_step.dart';
import 'vetoed_genres_step.dart';

/// Binds step 2 (liked, "Make it yours" — [GenreChipsStep]) and step 3
/// (vetoed, "And which ones never?" — [VetoedGenresStep]) to `OnboardingCubit`
/// (`docs/SCREENS.md` A2).
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
          return VetoedGenresStep(
            selected: vetoed,
            liked: liked,
            onToggle: cubit.toggleVetoedGenre,
            onFinish: onFinish,
          );
        }
        return GenreChipsStep(
          selected: liked,
          onToggle: cubit.toggleLikedGenre,
          onSkip: cubit.next,
          onNext: cubit.next,
        );
      },
    );
  }
}
