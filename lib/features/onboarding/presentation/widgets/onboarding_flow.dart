import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'onboarding_genre_step.dart';
import 'onboarding_intro_step.dart';
import 'onboarding_name_step.dart';
import 'onboarding_welcome_step.dart';

/// A2's own screen switch, once `OnboardingCubit` is already provided
/// above it (see `onboarding_screen.dart`). Owns the one thing that
/// isn't the Cubit's job: step 0's poster fetch (a plain network read,
/// not form state) and the flow's own exit (`docs/SCREENS.md` A2:
/// "Exits: B1, with a 'Tastes saved · Edit in You' snackbar if any
/// genre was picked").
///
/// `docs/SCREENS.md` A2 doesn't list a back control for any of these 4
/// screens, so none is built here — `OnboardingCubit.back()` stays
/// available for whenever that's actually asked for.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final Future<Result<List<MediaItem>>> _postersFuture;

  @override
  void initState() {
    super.initState();
    _postersFuture = getIt<MediaRepository>().getPosterWallItems();
  }

  Future<void> _finish(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();
    final pickedAGenre =
        cubit.state.likedGenres.isNotEmpty ||
        cubit.state.vetoedGenres.isNotEmpty;

    final result = await cubit.finish();
    if (!context.mounted) return;

    if (result is Failure<void>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.onboardingSaveError)));
      return;
    }
    if (pickedAGenre) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.onboardingTastesSavedSnackbar)),
      );
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    // No Scaffold here — each step below is its own self-contained
    // "screen" (WelcomeView, NameStep and the genre steps via
    // onboarding_scaffold.dart), each with its own Scaffold/SafeArea
    // (CLAUDE.md rule 14). A Scaffold here too would just nest one
    // inside another for no benefit.
    return BlocSelector<OnboardingCubit, OnboardingState, OnboardingStep>(
      selector: (state) => state.step,
      builder: (context, step) {
        return switch (step) {
          OnboardingStep.welcome => OnboardingWelcomeStep(
            postersFuture: _postersFuture,
            onGetStarted: cubit.next,
          ),
          OnboardingStep.name => const OnboardingNameStep(),
          OnboardingStep.introDiscover => const OnboardingIntroStep(
            kind: OnboardingIntroKind.discover,
          ),
          OnboardingStep.introSurprise => const OnboardingIntroStep(
            kind: OnboardingIntroKind.surprise,
          ),
          OnboardingStep.likedGenres => OnboardingGenreStep(
            isVetoedStep: false,
            onFinish: () => _finish(context),
          ),
          OnboardingStep.vetoedGenres => OnboardingGenreStep(
            isVetoedStep: true,
            onFinish: () => _finish(context),
          ),
        };
      },
    );
  }
}
