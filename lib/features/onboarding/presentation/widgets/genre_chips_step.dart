import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../l10n/l10n_extension.dart';
import 'onboarding_genre_page.dart';
import 'onboarding_pager_dots.dart';

/// "Make it yours" — `docs/SCREENS.md` A2: the genres you like, as wrapping
/// chips (a picked one is amber), the fourth pagination dot and "Next" (it is
/// no longer the last screen). "Skip" and "Next" both just move on with
/// whatever is selected. All the layout is [OnboardingGenrePage]'s.
class GenreChipsStep extends StatelessWidget {
  const GenreChipsStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onSkip,
    required this.onNext,
  });

  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingGenrePage(
      eyebrow: l10n.onboardingLikedEyebrow,
      headline: l10n.onboardingLikedHeadline,
      highlightWord: l10n.onboardingLikedHighlight,
      body: l10n.onboardingLikedBody,
      selected: selected,
      onToggle: onToggle,
      dot: OnboardingPagerDots.likedDot,
      buttonLabel: l10n.commonNext,
      onSkip: onSkip,
      onNext: onNext,
    );
  }
}
