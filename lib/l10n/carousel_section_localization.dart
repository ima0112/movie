import '../core/domain/repositories/media_repository.dart';
import 'app_localizations.dart';

/// The single mapper from [CarouselSection] to its header text —
/// CLAUDE.md rule 15. [CarouselSection.watchLater] reuses
/// `myListTabWatchLater` rather than its own key — same word, same
/// meaning, in both places.
extension CarouselSectionLocalization on CarouselSection {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    CarouselSection.popularThisWeek => l10n.carouselSectionPopularThisWeek,
    CarouselSection.watchLater => l10n.myListTabWatchLater,
    CarouselSection.inTheaters => l10n.carouselSectionInTheaters,
    CarouselSection.trending => l10n.carouselSectionTrending,
    CarouselSection.topRated => l10n.carouselSectionTopRated,
    CarouselSection.upcoming => l10n.carouselSectionUpcoming,
    CarouselSection.airingNow => l10n.carouselSectionAiringNow,
    CarouselSection.popular => l10n.carouselSectionPopular,
    CarouselSection.comingSoon => l10n.carouselSectionComingSoon,
    CarouselSection.finishedShows => l10n.carouselSectionFinishedShows,
  };
}
