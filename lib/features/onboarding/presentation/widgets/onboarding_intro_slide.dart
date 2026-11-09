import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import 'genre_step_headline.dart';
import 'intro_phone_frame.dart';
import 'onboarding_pager_dots.dart';

/// Layout of one intro slide (`docs/SCREENS.md` A2): "Skip" top right, a
/// centered headline (one phrase in amber) and body, a phone illustration
/// ([visual], clipped at the bottom and faded out), pagination dots and a
/// "Next" button.
///
/// Pure presentation — copy and callbacks come in by parameter. A
/// `Scaffold` + `SafeArea` like every screen (CLAUDE.md rule 14); the
/// headline/body scroll if large text leaves too little room.
class OnboardingIntroSlide extends StatelessWidget {
  const OnboardingIntroSlide({
    super.key,
    required this.headline,
    required this.highlightWord,
    required this.body,
    required this.visual,
    required this.activeDot,
    required this.onNext,
    required this.onSkip,
  });

  final String headline;
  final String highlightWord;
  final String body;
  final Widget visual;
  final int activeDot;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  /// Four dots in the design: the two slides, the name step, the genres.
  static const int dotCount = 4;

  static const double _fadeHeight = 160;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 1.1,
            colors: [AppColors.accentDeep, AppColors.surface],
            stops: [0, 0.7],
          ),
        ),
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      GenreStepHeadline(
                        text: headline,
                        highlightWord: highlightWord,
                        style: AppTextStyles.display,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: IntroPhoneFrame.height + AppSpacing.xxl,
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xxl),
                            child: visual,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _fadeHeight,
                      child: IgnorePointer(child: _BottomFade()),
                    ),
                  ],
                ),
              ),
              OnboardingPagerDots(count: dotCount, activeIndex: activeDot),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: PrimaryButton(label: l10n.commonNext, onTap: onNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomFade extends StatelessWidget {
  const _BottomFade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.55],
          colors: [Colors.transparent, AppColors.surface],
        ),
      ),
    );
  }
}
