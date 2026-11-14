import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../l10n/l10n_extension.dart';
import '../cubit/onboarding_cubit.dart';
import 'intro_badge.dart';
import 'intro_discover_mock.dart';
import 'intro_phone_frame.dart';
import 'intro_surprise_mock.dart';
import 'onboarding_intro_slide.dart';
import 'onboarding_pager_dots.dart';

enum OnboardingIntroKind { discover, surprise }

/// One of A2's two intro slides, wired to [OnboardingCubit]: "Next" is
/// `next()`, "Skip" is `skipIntro()`. Static copy, no Bloc subscription of
/// its own (CLAUDE.md rule 9). The phone illustration (mock screen plus
/// floating badges) is drawn from widgets — no image assets.
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
      activeDot: isDiscover
          ? OnboardingPagerDots.introDiscoverDot
          : OnboardingPagerDots.introSurpriseDot,
      visual: isDiscover ? const _DiscoverVisual() : const _SurpriseVisual(),
      onNext: cubit.next,
      onSkip: cubit.skipIntro,
    );
  }
}

/// Phone + mini Discover + the "8,4 rating" badge sticking out of its
/// right edge.
class _DiscoverVisual extends StatelessWidget {
  const _DiscoverVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const IntroPhoneFrame(child: IntroDiscoverMock()),
        Positioned(
          left: 190,
          top: 138,
          child: IntroBadge.circle(
            diameter: 88,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_rating(context, 8.4), style: AppTextStyles.h1),
                Text(
                  context.l10n.onboardingIntroRatingLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Phone + mini result + the "Use my tastes" pill on its left edge and a
/// "7,6" rating circle on its right.
class _SurpriseVisual extends StatelessWidget {
  const _SurpriseVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const IntroPhoneFrame(child: IntroSurpriseMock()),
        Positioned(
          left: -58,
          top: 70,
          child: IntroBadge.pill(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.match, size: 16, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  context.l10n.surpriseUseMyTastes,
                  style: AppTextStyles.bodySmStrong,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 216,
          top: 258,
          child: IntroBadge.circle(
            diameter: 76,
            child: Text(_rating(context, 7.6), style: AppTextStyles.h2),
          ),
        ),
      ],
    );
  }
}

String _rating(BuildContext context, double value) => NumberFormat(
  '0.0',
  Localizations.localeOf(context).toLanguageTag(),
).format(value);
