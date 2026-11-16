import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/onboarding_cubit.dart';
import 'intro_slide_specs.dart';
import 'onboarding_intro_slide.dart';

export 'intro_slide_specs.dart' show OnboardingIntroKind;

/// One of A2's two intro slides, wired to [OnboardingCubit]: "Next" is `next()`,
/// "Skip" is `skipIntro()`. Both slides are the same [OnboardingIntroSlide]
/// layout fed a different spec ([introSlideSpecs]). Static copy, no Bloc
/// subscription of its own (CLAUDE.md rule 9).
class OnboardingIntroStep extends StatelessWidget {
  const OnboardingIntroStep({super.key, required this.kind});

  final OnboardingIntroKind kind;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final specs = introSlideSpecs(context);
    return OnboardingIntroSlide(
      spec: specs[kind.index],
      siblings: specs,
      onNext: cubit.next,
      onSkip: cubit.skipIntro,
    );
  }
}
