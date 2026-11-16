import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import 'genre_step_headline.dart';
import 'intro_slide_spec.dart';
import 'intro_visual.dart';
import 'onboarding_glow_background.dart';
import 'onboarding_pager_dots.dart';

/// The layout of an intro slide (`docs/SCREENS.md` A2) — **one layout for both
/// slides**, fed a different [spec]: "Skip" top right; a centered headline (one
/// phrase in amber) and body; the phone picture ([IntroVisual], scaled to the
/// screen) faded out to transparent over the glow; the pagination dots floating
/// over that faded bottom; and the amber "Next" button.
///
/// **The phone is at the same height on every slide.** The text block reserves
/// room for the longest text of all the [siblings] (measured at this width and
/// text scale, so it holds in any language and at any text size), instead of
/// taking whatever its own copy needs — a one-line headline must not lift the
/// phone above a two-line one. If the copy needs more than half the screen it
/// scrolls.
///
/// Pure presentation — copy and callbacks come in by parameter. A `Scaffold` +
/// `SafeArea` like every screen (CLAUDE.md rule 14).
class OnboardingIntroSlide extends StatelessWidget {
  const OnboardingIntroSlide({
    super.key,
    required this.spec,
    required this.siblings,
    required this.onNext,
    required this.onSkip,
  });

  final IntroSlideSpec spec;

  /// Every slide's spec (this one included), to size the text block.
  final List<IntroSlideSpec> siblings;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  /// How far up from the bottom the phone starts to fade out.
  static const double fadeHeight = 230;

  /// The text block may take up to this much of the screen.
  static const double _textMaxFraction = 0.5;

  static const EdgeInsets _textPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xxl,
  );

  /// The height the longest of [specs]' headline + body needs in [width] px, at
  /// the ambient text scale.
  static double reservedTextHeight(
    BuildContext context,
    List<IntroSlideSpec> specs,
    double width,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double heightOf(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: width);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    return specs
        .map(
          (s) =>
              heightOf(s.headline, AppTextStyles.display) +
              AppSpacing.md +
              heightOf(s.body, AppTextStyles.body),
        )
        .reduce(math.max);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OnboardingGlowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textHeight = math.min(
                reservedTextHeight(
                  context,
                  siblings,
                  constraints.maxWidth - _textPadding.horizontal,
                ),
                constraints.maxHeight * _textMaxFraction,
              );
              return Column(
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
                  SizedBox(
                    height: textHeight,
                    child: SingleChildScrollView(
                      padding: _textPadding,
                      child: Column(
                        children: [
                          GenreStepHeadline(
                            text: spec.headline,
                            highlightWord: spec.highlightWord,
                            style: AppTextStyles.display,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            spec.body,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // The phone ends where the button begins (so no line of it
                  // shows behind or below the button); the dots float over its
                  // faded-out bottom, as in the design.
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ShaderMask(
                            // The phone fades out to **transparent** — not to a
                            // solid color laid over it — so it dissolves into
                            // the glow behind it (a solid fade left a seam).
                            blendMode: BlendMode.dstIn,
                            shaderCallback: _fadeOut,
                            child: IntroVisual(spec: spec),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: OnboardingPagerDots(
                            count: OnboardingPagerDots.total,
                            activeIndex: spec.activeDot,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: AccentButton(label: l10n.commonNext, onTap: onNext),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Opaque down to [fadeHeight] above the bottom (at most 55% of the room),
  /// then to transparent at the bottom edge.
  static Shader _fadeOut(Rect bounds) {
    final fade = math.min(fadeHeight, bounds.height * 0.55);
    final start = (1 - fade / bounds.height).clamp(0.0, 0.95);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [start, 1],
      colors: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
    ).createShader(bounds);
  }
}
