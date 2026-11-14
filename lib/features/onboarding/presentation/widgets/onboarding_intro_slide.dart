import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import 'genre_step_headline.dart';
import 'intro_phone_frame.dart';
import 'onboarding_glow_background.dart';
import 'onboarding_pager_dots.dart';

/// Layout of one intro slide (`docs/SCREENS.md` A2): "Skip" top right, a
/// centered headline (one phrase in amber) and body, a phone illustration
/// ([visual], clipped at the bottom and faded out to transparent over the glow),
/// the pagination dots and an amber "Next" button.
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

  /// How far up from the bottom the phone starts to fade out.
  static const double _fadeHeight = 230;
  static const double _textMaxFraction = 0.5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OnboardingGlowBackground(
        child: SafeArea(
          // The text block may take up to half the screen (scrolling past
          // that with large text); the phone area gets everything left.
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * _textMaxFraction,
                  ),
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
                      ],
                    ),
                  ),
                ),
                // The phone runs behind the footer, as in the design: the
                // dots and button float over its faded-out bottom.
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        // Clipped at the bottom only: the phone's amber glow
                        // spills above and beside it and must not be cut by a
                        // hard line.
                        child: ClipRect(
                          clipper: const _BottomOnlyClipper(),
                          child: ShaderMask(
                            // The phone fades out to **transparent** — not to a
                            // solid color painted over it — so it dissolves
                            // into the glow behind it, which stays visible
                            // all the way down (a solid fade left a seam
                            // above the home indicator).
                            blendMode: BlendMode.dstIn,
                            shaderCallback: _fadeOut,
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              minWidth: 0,
                              minHeight: 0,
                              maxHeight:
                                  IntroPhoneFrame.height + AppSpacing.xxl,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xxl,
                                ),
                                child: visual,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OnboardingPagerDots(
                              count: OnboardingPagerDots.total,
                              activeIndex: activeDot,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.lg,
                                AppSpacing.xl,
                                AppSpacing.lg,
                              ),
                              child: AccentButton(
                                label: l10n.commonNext,
                                onTap: onNext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Opaque down to where the footer starts, then to transparent at the
  /// bottom edge.
  static Shader _fadeOut(Rect bounds) {
    final fadeStart = (1 - _fadeHeight / bounds.height).clamp(0.0, 0.9);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [fadeStart, 1],
      colors: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
    ).createShader(bounds);
  }
}

/// Clips only the bottom edge: whatever spills over the top and the sides (the
/// phone's glow) stays visible.
class _BottomOnlyClipper extends CustomClipper<Rect> {
  const _BottomOnlyClipper();

  static const double _spill = 1000;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-_spill, -_spill, size.width + _spill, size.height);

  @override
  bool shouldReclip(_BottomOnlyClipper oldClipper) => false;
}
