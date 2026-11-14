import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'intro_badge.dart';
import 'intro_discover_mock.dart';
import 'intro_slide_spec.dart';
import 'intro_surprise_mock.dart';
import 'onboarding_pager_dots.dart';

enum OnboardingIntroKind { discover, surprise }

/// Both intro slides' [IntroSlideSpec]s, in order (index = [OnboardingIntroKind]
/// index). They are built together because each slide reserves room for the
/// longer of the two texts, so their phones start at the same height.
List<IntroSlideSpec> introSlideSpecs(BuildContext context) {
  final l10n = context.l10n;
  return [
    // "Find what to watch in seconds": the mini Discover with an "8.4 rating"
    // circle sticking out of its right edge.
    IntroSlideSpec(
      headline: l10n.onboardingIntroDiscoverHeadline,
      highlightWord: l10n.onboardingIntroDiscoverHighlight,
      body: l10n.onboardingIntroDiscoverBody,
      mock: const IntroDiscoverMock(),
      activeDot: OnboardingPagerDots.introDiscoverDot,
      badges: [
        IntroBadgePlacement(
          left: 190,
          top: 138,
          child: IntroBadge.circle(
            diameter: 88,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_rating(context, 8.4), style: AppTextStyles.h1),
                Text(
                  l10n.onboardingIntroRatingLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    // "No idea? Surprise me": the mini result with the "Use my tastes" pill on
    // its left edge and a "7.6" rating circle on its right.
    IntroSlideSpec(
      headline: l10n.onboardingIntroSurpriseHeadline,
      highlightWord: l10n.onboardingIntroSurpriseHighlight,
      body: l10n.onboardingIntroSurpriseBody,
      mock: const IntroSurpriseMock(),
      activeDot: OnboardingPagerDots.introSurpriseDot,
      badges: [
        IntroBadgePlacement(
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
                  l10n.surpriseUseMyTastes,
                  style: AppTextStyles.bodySmStrong,
                ),
              ],
            ),
          ),
        ),
        IntroBadgePlacement(
          left: 216,
          top: 258,
          child: IntroBadge.circle(
            diameter: 76,
            child: Text(_rating(context, 7.6), style: AppTextStyles.h2),
          ),
        ),
      ],
    ),
  ];
}

String _rating(BuildContext context, double value) => NumberFormat(
  '0.0',
  Localizations.localeOf(context).toLanguageTag(),
).format(value);
