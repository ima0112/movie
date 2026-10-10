// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get discoverSeeAll => 'See all';

  @override
  String settingsAboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String settingsDataDeleteItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get failureNetwork =>
      'No connection — check your internet and try again.';

  @override
  String get failureServer =>
      'TMDB is having trouble right now. Try again in a moment.';

  @override
  String get failureNotFound => 'We couldn\'t find that.';

  @override
  String get failureQuota => 'Too many requests — try again in a moment.';

  @override
  String get failureStorage =>
      'Something went wrong saving that on your device.';

  @override
  String get failureUnknown => 'Something went wrong. Try again.';

  @override
  String get genreAction => 'Action';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreAnimation => 'Animation';

  @override
  String get genreComedy => 'Comedy';

  @override
  String get genreCrime => 'Crime';

  @override
  String get genreDocumentary => 'Documentary';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreFamily => 'Family';

  @override
  String get genreHistory => 'History';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreMusic => 'Music';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreSciFi => 'Science Fiction';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get vibeFeelGood => 'Feel Good';

  @override
  String get vibeIndie => 'Indie';

  @override
  String get vibeMonster => 'Monster';

  @override
  String get vibeDetective => 'Detective';

  @override
  String get vibeClassic => 'Classic';

  @override
  String get vibeSuperhero => 'Superhero';

  @override
  String get vibeCult => 'Cult';

  @override
  String get vibeTearjerker => 'Tearjerker';

  @override
  String get vibeSports => 'Sports';

  @override
  String get vibeDateNight => 'Date Night';

  @override
  String get vibeFuture => 'Future';

  @override
  String get vibeExplosive => 'Explosive';

  @override
  String get vibeGritty => 'Gritty';

  @override
  String get vibeTrueStory => 'True Story';

  @override
  String get vibeGangster => 'Gangster';

  @override
  String get vibeMusical => 'Musical';

  @override
  String get tvStatusAiring => 'Airing';

  @override
  String get tvStatusEnded => 'Ended';

  @override
  String get tvStatusCancelled => 'Cancelled';

  @override
  String get quizFinishedToggleFinished => 'Finished';

  @override
  String get quizFinishedToggleEither => 'Either';

  @override
  String get mediaTypeMovieSingular => 'Movie';

  @override
  String get mediaTypeTvShowSingular => 'TV Show';

  @override
  String get mediaTypeMoviePlural => 'Movies';

  @override
  String get mediaTypeTvShowPlural => 'TV Shows';

  @override
  String get mediaTypeTvTag => 'TV';

  @override
  String get mediaSegmentAll => 'All';

  @override
  String get personFilmographyAsDirector => 'As director';

  @override
  String get discoverSortPopularity => 'Popularity';

  @override
  String get discoverSortRating => 'Rating';

  @override
  String get discoverSortDate => 'Date';

  @override
  String get discoverSortTitle => 'Title';

  @override
  String get myListTabFavorites => 'Favorites';

  @override
  String get myListTabWatchLater => 'Watch later';

  @override
  String get myListTabWatched => 'Watched';

  @override
  String myListRemovedFromTab(String tabName) {
    return 'Removed from $tabName';
  }

  @override
  String get myListEmptyFavoritesHeadline => 'No favorites yet';

  @override
  String get myListEmptyWatchLaterHeadline => 'Nothing for later yet';

  @override
  String get myListEmptyWatchedHeadline =>
      'You haven\'t marked anything as watched yet';

  @override
  String myListFallbackTitleMovie(int id) {
    return 'Movie #$id';
  }

  @override
  String myListFallbackTitleTvShow(int id) {
    return 'TV show #$id';
  }

  @override
  String filteredListExcludeGenreChip(String genreName) {
    return 'No $genreName';
  }

  @override
  String get myListFilteredEmptyMovieTitle => 'No movies here';

  @override
  String get myListFilteredEmptyTvShowTitle => 'No TV shows here';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get navTabDiscover => 'Discover';

  @override
  String get navTabExplore => 'Explore';

  @override
  String get navTabMyList => 'My List';

  @override
  String get navTabYou => 'You';

  @override
  String get offlineBannerMessage => 'Offline';

  @override
  String get onboardingSaveError => 'Something went wrong — let\'s try again.';

  @override
  String get onboardingTastesSavedSnackbar => 'Tastes saved · Edit in You';

  @override
  String get onboardingGenreStep2Label => 'Step 2 of 3';

  @override
  String get onboardingGenreStep3Label => 'Step 3 of 3';

  @override
  String get onboardingGenreStep2Headline => 'What genres do you like?';

  @override
  String get onboardingGenreStep3Headline => 'And which ones never?';

  @override
  String get onboardingGenreStep3HighlightWord => 'never';

  @override
  String get onboardingGenreStep3NextLabel => 'Done';

  @override
  String get onboardingNameHeadline => 'What\'s your name?';

  @override
  String get onboardingNameBody =>
      'That\'s what I\'ll call you, and how others will see you in rooms.';

  @override
  String get onboardingNameHint => 'Your name';

  @override
  String get onboardingWelcomeHeadline => 'Hi, I\'m Pako';

  @override
  String get onboardingWelcomeSubtitle =>
      'I\'ll help you find something to watch, alone or with friends.';

  @override
  String get onboardingWelcomeGetStarted => 'Get started';

  @override
  String get onboardingWelcomeTmdbAttribution => 'Data from TMDB';

  @override
  String get commonCouldntLoad => 'Couldn\'t load';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClearAll => 'Clear all';

  @override
  String get commonGenres => 'Genres';

  @override
  String get carouselSectionForYou => 'For You';

  @override
  String get carouselSectionPopularThisWeek => 'Popular this week';

  @override
  String get carouselSectionBecauseYouLike => 'Because you like…';

  @override
  String get carouselSectionInTheaters => 'In theaters';

  @override
  String get carouselSectionTrending => 'Trending';

  @override
  String get carouselSectionTopRated => 'Top rated';

  @override
  String get carouselSectionUpcoming => 'Upcoming';

  @override
  String get carouselSectionAiringNow => 'Airing now';

  @override
  String get carouselSectionPopular => 'Popular';

  @override
  String get exploreNoResults => 'No results';

  @override
  String get exploreTryAnotherTitle => 'Try another title';

  @override
  String get exploreDefaultResultsTitle => 'Results';

  @override
  String get exploreSearchHint => 'Movies, TV shows, people';

  @override
  String get exploreRecentSearchesLabel => 'Recent';

  @override
  String exploreResultMetadata(int year, String typeLabel) {
    return '$year · $typeLabel';
  }

  @override
  String filteredListYearRangeChip(int from, int to) {
    return '$from–$to';
  }

  @override
  String filteredListMinRatingChip(String rating) {
    return '$rating+ rating';
  }

  @override
  String filteredListMaxRuntimeChip(int minutes) {
    return 'Under $minutes min';
  }

  @override
  String get filteredListEmptyTitle => 'Nothing matches these filters';

  @override
  String get filteredListEmptyBody => 'Try adjusting your filters.';

  @override
  String filteredListCountLine(int count, String sortLabel) {
    return '$count results · $sortLabel';
  }

  @override
  String get filterSheetTitle => 'Filters';

  @override
  String get filterSheetSectionType => 'Type';

  @override
  String get filterSheetSectionYear => 'Year';

  @override
  String get filterSheetSectionMinRating => 'Minimum rating';

  @override
  String get filterSheetSectionMaxRuntime => 'Max runtime';

  @override
  String get filterSheetSectionStatus => 'Status';

  @override
  String get filterSheetSectionSortBy => 'Sort by';

  @override
  String get filterSheetSeeResultsLoading => 'See results';

  @override
  String filterSheetSeeResultsCount(int count) {
    return 'See $count results';
  }

  @override
  String discoverRangeFiltersYearRange(int from, int to) {
    return '$from – $to';
  }

  @override
  String get discoverRangeFiltersNoLimit => 'No limit';

  @override
  String discoverRangeFiltersMinutes(int value) {
    return '$value min';
  }

  @override
  String get libraryRowDateToday => 'Today';

  @override
  String get libraryRowDateYesterday => 'Yesterday';

  @override
  String libraryRowDateDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get myListUndoAction => 'Undo';

  @override
  String get myListBodyOtherTabsNote => 'Explore to add movies and shows here.';

  @override
  String get myListBodyEmptyFilterTitle => 'Nothing matches your filters';

  @override
  String myListSeasonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seasons',
      one: '1 season',
    );
    return '$_temp0';
  }

  @override
  String myListRuntimeHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String myListRuntimeMinutesOnly(int minutes) {
    return '$minutes min';
  }

  @override
  String get myListSortRecent => 'Recent';

  @override
  String get myListSortTitleAz => 'Title A–Z';

  @override
  String get myListSortTmdbRating => 'TMDB rating';

  @override
  String get myListSortMyRating => 'My rating';

  @override
  String get myListSortDateWatched => 'Date watched';

  @override
  String get myListFilterSheetTitle => 'Sort and filter';

  @override
  String get commonApply => 'Apply';

  @override
  String get myListHideWatchedToggle => 'Hide what I\'ve watched';

  @override
  String myListSegmentLabelWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get myTastesTitle => 'My Tastes';

  @override
  String myTastesSummaryVibeCount(int count) {
    return '$count vibes';
  }

  @override
  String myTastesSummarySinceYear(int year) {
    return 'since $year';
  }

  @override
  String myTastesSummaryNeverGenre(String genreName) {
    return 'never $genreName';
  }

  @override
  String get myTastesInvitationTitle => 'Build your taste profile';

  @override
  String get myTastesInvitationBody =>
      'Get picks that actually match what you like.';

  @override
  String get youHeaderGreetingNoProfile => 'Hi';

  @override
  String get youHeaderTapToSetName => 'Tap to set your name';

  @override
  String youHeaderGreetingWithName(String name) {
    return 'Hi, $name';
  }

  @override
  String get yourActivityTitle => 'Your Activity';

  @override
  String get yourActivityHoursLabel => 'Hours';

  @override
  String get yourActivitySeeStats => 'See stats';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsActivityStripTitle => 'Activity over the last 12 months';

  @override
  String get statsEmptyTitle => 'Mark something as watched to see your stats';

  @override
  String get statsEmptyBody => 'Your numbers will show up here once you do.';

  @override
  String get statsGenreBarsTitle => 'Genres you watch most';

  @override
  String get statsMoviesWatchedLabel => 'Movies watched';

  @override
  String get statsHoursOfMoviesLabel => 'Hours of movies';

  @override
  String get statsTvShowsWatchedLabel => 'TV shows watched';

  @override
  String get statsEstimatedTvHoursLabel => 'Estimated TV hours';

  @override
  String get myTastesGenresLikeTitle => 'Genres you like';

  @override
  String get myTastesGenresNeverTitle => 'Genres you never want';

  @override
  String get myTastesSavedIndicator => 'Saved';

  @override
  String get myTastesVibesLikeTitle => 'Vibes you like';

  @override
  String get myTastesHowFarBackLabel => 'How far back';

  @override
  String statsHoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get commonReadMore => 'Read more';

  @override
  String tvEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get tvCreatedByLabel => 'Created by ';

  @override
  String get tvSeasonsSectionTitle => 'Seasons';

  @override
  String get tvSpecialsLabel => 'Specials';

  @override
  String tvSeasonLabel(int number) {
    return 'Season $number';
  }

  @override
  String tvEpisodeRowTitle(int number, String name) {
    return '$number. $name';
  }

  @override
  String get tvEpisodeTba => 'TBA';

  @override
  String get commonNoMatches => 'No matches';

  @override
  String get commonSave => 'Save';

  @override
  String mediaDetailHaveYouFinished(String title) {
    return 'Have you finished $title?';
  }

  @override
  String get mediaDetailMarkAsWatched => 'Mark as watched';

  @override
  String get mediaDetailYourRating => 'Your rating';

  @override
  String get mediaDetailRemoveFromWatched => 'Remove from Watched';

  @override
  String get regionSheetTitle => 'Region';

  @override
  String get regionSheetSearchHint => 'Search countries';

  @override
  String get fullCastSheetTitle => 'Full cast';

  @override
  String get fullCastSheetCastLabel => 'Cast';

  @override
  String get fullCastSheetCrewLabel => 'Crew';

  @override
  String get fullCastSheetSearchHint => 'Search cast and crew';

  @override
  String get mediaSimilarTitle => 'Similar';

  @override
  String get mediaDetailActionTrailer => 'Trailer';

  @override
  String get mediaDetailActionSeeSimilar => 'See similar';

  @override
  String get mediaDetailActionFavorite => 'Favorite';

  @override
  String get mediaCastRowSeeFullCast => 'See full cast';

  @override
  String get whereToWatchTitle => 'Where to watch';

  @override
  String get whereToWatchSubscription => 'Subscription';

  @override
  String get whereToWatchRent => 'Rent';

  @override
  String get whereToWatchBuy => 'Buy';

  @override
  String get whereToWatchJustWatchAttribution => 'Data from JustWatch';

  @override
  String whereToWatchOverflowChip(int count) {
    return '+$count';
  }
}
