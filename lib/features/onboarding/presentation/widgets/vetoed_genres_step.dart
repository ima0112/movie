import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import 'onboarding_genre_page.dart';
import 'onboarding_pager_dots.dart';

/// "And which ones never?" — `docs/SCREENS.md` A2, the last screen: the genres
/// you'd rather not see. A picked chip is red and struck through, as in
/// "Genres you avoid" (My Tastes); the genres you liked on the previous screen
/// ([liked]) are dimmed and inert, so one can't be both liked and avoided (the
/// body says so). "Skip" and the amber "Get started" button both finish the
/// flow. All the layout is [OnboardingGenrePage]'s.
class VetoedGenresStep extends StatelessWidget {
  const VetoedGenresStep({
    super.key,
    required this.selected,
    required this.liked,
    required this.onToggle,
    required this.onFinish,
  });

  final Set<Genre> selected;
  final Set<Genre> liked;
  final ValueChanged<Genre> onToggle;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingGenrePage(
      eyebrow: l10n.onboardingLikedEyebrow,
      headline: l10n.onboardingGenreStep3Headline,
      highlightWord: l10n.onboardingGenreStep3HighlightWord,
      highlightColor: AppColors.danger,
      body: l10n.onboardingVetoedBody,
      selected: selected,
      disabled: liked,
      selectedState: ChipState.vetoed,
      onToggle: onToggle,
      dot: OnboardingPagerDots.vetoedDot,
      buttonLabel: l10n.onboardingVetoedCta,
      onSkip: onFinish,
      onNext: onFinish,
    );
  }
}
