import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/l10n_extension.dart';
import '../cubit/onboarding_cubit.dart';
import 'intro_phone_frame.dart';
import 'onboarding_intro_slide.dart';

enum OnboardingIntroKind { discover, surprise }

/// One of A2's two intro slides, wired to [OnboardingCubit]: "Next" is
/// `next()`, "Skip" is `skipIntro()`. Static copy, no Bloc subscription of
/// its own (CLAUDE.md rule 9). The phone illustration is a placeholder
/// frame until the mock screens land.
class OnboardingIntroStep extends StatelessWidget {
  const OnboardingIntroStep({super.key, required this.kind});

  final OnboardingIntroKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OnboardingCubit>();
    final isDiscover = kind == OnboardingIntroKind.discover;
    return OnboardingIntroSlide(
      headline: isDiscover
          ? l10n.onboardingIntroDiscoverHeadline
          : l10n.onboardingIntroSurpriseHeadline,
      highlightWord: isDiscover
          ? l10n.onboardingIntroDiscoverHighlight
          : l10n.onboardingIntroSurpriseHighlight,
      body: isDiscover
          ? l10n.onboardingIntroDiscoverBody
          : l10n.onboardingIntroSurpriseBody,
      activeDot: isDiscover ? 0 : 1,
      visual: const IntroPhoneFrame(child: SizedBox.shrink()),
      onNext: cubit.next,
      onSkip: cubit.skipIntro,
    );
  }
}
