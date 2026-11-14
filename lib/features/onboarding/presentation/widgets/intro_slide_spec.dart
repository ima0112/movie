import 'package:flutter/widgets.dart';

/// One floating callout of an intro slide, placed over its phone: [child] (an
/// `IntroBadge`) with its top-left corner at ([left], [top]) **in the phone's own
/// design pixels** — the phone frame is `IntroPhoneFrame.width` × `height`, so a
/// negative [left] sticks out on the left and a [left] past the width on the
/// right. The whole phone-plus-callouts composition is scaled together
/// (`IntroVisual`), so these numbers hold on any screen.
class IntroBadgePlacement {
  const IntroBadgePlacement({
    required this.left,
    required this.top,
    required this.child,
  });

  final double left;
  final double top;
  final Widget child;
}

/// Everything that differs between the onboarding's intro slides (they are one
/// layout, `OnboardingIntroSlide`, fed one of these): the copy, the mini
/// screen drawn inside the phone, the callouts over it and which pagination dot
/// is the active one. Pure data — built from the localizations by
/// `OnboardingIntroStep`.
class IntroSlideSpec {
  const IntroSlideSpec({
    required this.headline,
    required this.highlightWord,
    required this.body,
    required this.mock,
    required this.badges,
    required this.activeDot,
  });

  final String headline;
  final String highlightWord;
  final String body;

  /// The mini screen drawn inside the phone frame.
  final Widget mock;
  final List<IntroBadgePlacement> badges;
  final int activeDot;
}
