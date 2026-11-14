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
    return '$version ($build)';
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
  String get genreFantasy => 'Fantasy';

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
  String get vibeFantasy => 'Fantasy';

  @override
  String get tvStatusCardLabel => 'Status';

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
  String get mediaSegmentPeople => 'People';

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
  String get discoverSortVotes => 'Most voted';

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
  String get navMatchButton => 'Surprise me and match';

  @override
  String get offlineBannerMessage => 'Offline';

  @override
  String get onboardingSaveError => 'Something went wrong — let\'s try again.';

  @override
  String get onboardingTastesSavedSnackbar => 'Tastes saved · Edit in You';

  @override
  String get onboardingGenreStep3Label => 'Step 3 of 3';

  @override
  String get onboardingLikedEyebrow => 'Make it yours';

  @override
  String get onboardingLikedHeadline => 'What do you like?';

  @override
  String get onboardingLikedHighlight => 'like';

  @override
  String get onboardingLikedBody =>
      'Pick a few genres to personalize Discover. You can fine-tune later in You › My Tastes.';

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
  String get onboardingIntroDiscoverHeadline =>
      'Find what to watch\nin seconds';

  @override
  String get onboardingIntroDiscoverHighlight => 'in seconds';

  @override
  String get onboardingIntroRatingLabel => 'rating';

  @override
  String get onboardingIntroDiscoverBody =>
      'Explore TMDB\'s catalog. It\'s not a streaming app: we tell you where to watch it.';

  @override
  String get onboardingIntroSurpriseHeadline => 'No idea? Surprise me';

  @override
  String get onboardingIntroSurpriseHighlight => 'Surprise me';

  @override
  String get onboardingIntroSurpriseBody =>
      'Answer a few questions or use your tastes and we\'ll suggest what to watch.';

  @override
  String get onboardingWelcomeTagline => 'Find what to watch';

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
  String carouselSectionBecauseYouLikeGenre(String genre) {
    return 'Because you like $genre';
  }

  @override
  String carouselSectionBecauseYouWantVibe(String vibe) {
    return 'Because you want $vibe';
  }

  @override
  String carouselSectionBecauseYouLike(String title) {
    return 'Because you like $title';
  }

  @override
  String get carouselSectionInTheaters => 'In theaters';

  @override
  String get carouselSectionComingSoon => 'Coming soon';

  @override
  String get carouselSectionFinishedShows => 'Finished shows';

  @override
  String get carouselSectionLatestTrailers => 'Latest trailers';

  @override
  String get discoverTasteCardTitle => 'Make Home yours';

  @override
  String get discoverTasteCardBody =>
      'Tell us what you like and we\'ll fill this page with picks for you.';

  @override
  String get sectionListingSortTitle => 'Sort by';

  @override
  String get sectionListingSortTooltip => 'Sort';

  @override
  String get sectionListingSortDefault => 'Default order';

  @override
  String get sectionListingSortNewest => 'Newest first';

  @override
  String get sectionListingAllGenres => 'All genres';

  @override
  String get sectionListingAllPlatforms => 'All platforms';

  @override
  String get sectionListingEmptyTitle => 'Nothing to show here';

  @override
  String get sectionListingEmptyBody => 'Try another genre or platform.';

  @override
  String get sectionListingLoadMoreFailed => 'Couldn\'t load more';

  @override
  String get releaseStatusInTheaters => 'In theaters';

  @override
  String get releaseStatusComingSoon => 'Coming soon';

  @override
  String releaseStatusComingOn(String date) {
    return 'Coming $date';
  }

  @override
  String get whereToWatchNotReleased =>
      'It isn\'t out yet, so it isn\'t on any service.';

  @override
  String whereToWatchNotReleasedOn(String date) {
    return 'It isn\'t out yet. It comes out on $date.';
  }

  @override
  String get whereToWatchInTheaters =>
      'In theaters now, and not on any service yet.';

  @override
  String whereToWatchInTheatersStreamingOn(String date) {
    return 'In theaters now. Expected on streaming on $date.';
  }

  @override
  String trailerPlayLabel(String title) {
    return 'Play the trailer for $title';
  }

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
  String get exploreGenreLabel => 'Genre';

  @override
  String get exploreGenreAll => 'All';

  @override
  String get explorePlatformLabel => 'Platform';

  @override
  String get explorePlatformAll => 'All';

  @override
  String get exploreSectionTopToday => 'Top today';

  @override
  String get exploreSectionPopular => 'Popular';

  @override
  String get exploreSectionComingSoon => 'Coming soon';

  @override
  String get exploreSectionTopRatedSubtitle => 'The best of all time, by score';

  @override
  String get exploreSectionTopRated => 'Top rated';

  @override
  String get exploreSectionNewReleases => 'New releases';

  @override
  String get exploreSectionHiddenGems => 'Hidden gems';

  @override
  String get exploreBrowseEmptyTitle => 'Nothing for these filters';

  @override
  String get exploreBrowseEmptyBody => 'Try another genre or platform.';

  @override
  String get exploreNoResults => 'No results';

  @override
  String get exploreTryAnotherTitle => 'Try another title';

  @override
  String get exploreDefaultResultsTitle => 'Results';

  @override
  String get exploreSearchHint => 'Movies, TV shows, people';

  @override
  String exploreRecentRemove(String query) {
    return 'Remove $query from recent searches';
  }

  @override
  String get exploreRecentSearchesLabel => 'Recent';

  @override
  String get explorePersonLabel => 'Person';

  @override
  String explorePersonMetadata(String department) {
    return '$department · Person';
  }

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
  String myListEpisodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
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
  String get myTastesIntro =>
      'The more we know, the better your recommendations and Surprise me. Everything is saved only on your device.';

  @override
  String get myTastesGenresLikeHint => 'Choose as many as you like.';

  @override
  String get myTastesGenresNeverHint =>
      'We won\'t show them in recommendations.';

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
  String get mediaDetailDuration => 'Duration';

  @override
  String get mediaDetailClassification => 'Classification';

  @override
  String get mediaDetailSynopsis => 'Synopsis';

  @override
  String get commonReadLess => 'Read less';

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
  String get mediaCreatedByLabel => 'Created by ';

  @override
  String get mediaDirectedByLabel => 'Directed by ';

  @override
  String get tvEpisodesSectionTitle => 'Episodes';

  @override
  String tvEpisodeCode(int season, int episode) {
    return 'S$season · E$episode';
  }

  @override
  String tvEpisodeCodeSpecials(int episode) {
    return 'Specials · E$episode';
  }

  @override
  String get tvEpisodeGuestStars => 'Guest stars';

  @override
  String get tvSeasonsLinkLabel => 'Seasons';

  @override
  String tvSeasonsLinkValue(int seasons, int episodes) {
    String _temp0 = intl.Intl.pluralLogic(
      episodes,
      locale: localeName,
      other: '$episodes episodes',
      one: '1 episode',
    );
    return '$seasons · $_temp0';
  }

  @override
  String get tvNextEpisodeCaption => 'Next episode';

  @override
  String get tvLastAiredEpisodeCaption => 'Last aired episode';

  @override
  String get tvNoNextEpisodeTitle => 'No next episode';

  @override
  String get tvNoNextEpisodeUnknown =>
      'No upcoming episode has been announced yet.';

  @override
  String tvEpisodeCodeAndName(int season, int episode, String name) {
    return 'S$season · E$episode · $name';
  }

  @override
  String tvEpisodeCodeSpecialsAndName(int episode, String name) {
    return 'Specials · E$episode · $name';
  }

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
  String get mediaDetailDateLabel => 'Date';

  @override
  String mediaDetailRatingStarLabel(int count) {
    return '$count of 5';
  }

  @override
  String get mediaDetailYourRating => 'Your rating';

  @override
  String get mediaDetailRemoveFromWatched => 'Remove from Watched';

  @override
  String get regionSheetTitle => 'Region';

  @override
  String get regionSheetSubtitle =>
      'Sets which services you see in \"Where to watch\".';

  @override
  String get regionSheetSearchHint => 'Search countries';

  @override
  String get fullCastCastLabel => 'Cast';

  @override
  String get fullCastCrewLabel => 'Crew';

  @override
  String get fullCastSearchHint => 'Search cast and crew';

  @override
  String get mediaSimilarMoviesTitle => 'Similar movies';

  @override
  String get mediaSimilarTvTitle => 'Similar TV shows';

  @override
  String get mediaSimilarTitle => 'Similar';

  @override
  String get mediaDetailShare => 'Share';

  @override
  String get mediaDetailShareFailed => 'Couldn\'t share';

  @override
  String get mediaDetailActionTrailer => 'Trailer';

  @override
  String get mediaDetailActionSeeSimilar => 'See similar';

  @override
  String get mediaDetailActionFavorite => 'Favorite';

  @override
  String get whereToWatchTitle => 'Where to watch';

  @override
  String get whereToWatchTapHint => 'Tap a service to open it in JustWatch';

  @override
  String whereToWatchNoProviders(String region) {
    return 'Not available to stream, rent or buy in $region. Try another country.';
  }

  @override
  String whereToWatchChangeRegion(String region) {
    return 'Country: $region. Change country';
  }

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

  @override
  String personAgeLivedYears(int age) {
    return 'Lived $age years';
  }

  @override
  String personAgeYearsOld(int age) {
    return '$age years old';
  }

  @override
  String get personBiographyInEnglish => 'Biography in English';

  @override
  String get personFilmographyComingSoon => 'Coming soon';

  @override
  String get personKnownForTitle => 'Known for';

  @override
  String get personFilmographyLinkLabel => 'View full filmography';

  @override
  String personFilmographyTitleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String get personFilmographyTitle => 'Filmography';

  @override
  String get quizExcludeWatchedToggle => 'Exclude what I\'ve already watched';

  @override
  String get quizGenreStepHeadline =>
      'Pick up to 3 you\'re NOT in the mood for';

  @override
  String quizSelectionCounter(int selected, int max) {
    return '$selected of $max';
  }

  @override
  String get quizMaxSeasonsLabel => 'Max seasons';

  @override
  String get quizSearchButton => 'Search';

  @override
  String get quizVibeStepHeadline => 'Now pick 3 you ARE in the mood for';

  @override
  String get quizYearStepHeadline => 'How far back do you want to go?';

  @override
  String get surpriseErrorMessage => 'Couldn\'t find a match. Try again.';

  @override
  String get chooseTypeHeadline => 'What are you in the mood for today?';

  @override
  String get surpriseNoMoreSuggestionsTitle => 'That\'s all for now';

  @override
  String get surpriseNoMoreSuggestionsBody =>
      'We\'re out of suggestions from this search — try again for a fresh pick.';

  @override
  String get surpriseSearchAgain => 'Search again';

  @override
  String get surpriseNoMatchTitle => 'Couldn\'t find a match';

  @override
  String get chooseTypeMovieLabel => 'A movie';

  @override
  String get chooseTypeTvShowLabel => 'A TV show';

  @override
  String get surpriseYourSuggestionTitle => 'Your suggestion';

  @override
  String get surpriseSearchingLabel => 'Searching…';

  @override
  String get surpriseViewDetailsLink => 'View details';

  @override
  String get surpriseSourceProfile => 'Based on your tastes';

  @override
  String get surpriseSourceInferredList => 'Based on your list';

  @override
  String get surpriseSourceQuiz => 'Based on your answers';

  @override
  String get surpriseRelaxedSearchNote =>
      'We broadened the search a bit to find this match.';

  @override
  String get surpriseAddToWatchLater => 'Add to Watch later';

  @override
  String get surpriseAnotherSuggestion => 'Another suggestion';

  @override
  String get surpriseAddedToWatchLaterSnackbar => 'Added to Watch later';

  @override
  String get surpriseChooseSourceTitle => 'Find something to watch';

  @override
  String get surpriseUseMyTastes => 'Use my tastes';

  @override
  String get surpriseAnswerQuizInstead => 'Answer the quiz instead';

  @override
  String get matchHubTitle => 'Match';

  @override
  String get matchHubSurpriseMeTitle => 'Surprise me';

  @override
  String get matchHubSurpriseMeSubtitle => 'A suggestion just for you';

  @override
  String get matchHubWithFriendsTitle => 'Match with friends';

  @override
  String get matchHubWithFriendsSubtitle => 'Decide together in seconds';

  @override
  String get matchHubSoonPill => 'Soon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferencesHeader => 'Preferences';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get settingsDataHeader => 'Data';

  @override
  String get settingsExportMyList => 'Export My List';

  @override
  String get settingsDeleteMyListLabel => 'Delete My List';

  @override
  String get settingsDeleteMyTastesLabel => 'Delete My Tastes';

  @override
  String get settingsExportFailedSnackbar => 'Couldn\'t export My List';

  @override
  String get settingsMyListDeletedSnackbar => 'My List deleted';

  @override
  String get settingsDeleteMyListFailedSnackbar => 'Couldn\'t delete My List';

  @override
  String get settingsMyTastesDeletedSnackbar => 'My Tastes deleted';

  @override
  String get settingsDeleteMyTastesFailedSnackbar =>
      'Couldn\'t delete My Tastes';

  @override
  String get settingsDeleteListDialogTitle => 'Delete your list?';

  @override
  String get settingsDeleteTastesDialogTitle => 'Delete your tastes?';

  @override
  String settingsDeleteDialogBody(String itemsPhrase) {
    return 'This will remove $itemsPhrase. This can\'t be undone.';
  }

  @override
  String settingsDataDeleteSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selections',
      one: '1 selection',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingsBuildNumberCopiedSnackbar => 'Build number copied';

  @override
  String get settingsAboutHeader => 'About';

  @override
  String get settingsVersionLabel => 'Version';

  @override
  String get settingsSourceCodeLabel => 'Source code';

  @override
  String get settingsAttributionLabel => 'Attribution and credits';

  @override
  String get attributionTitle => 'Attribution and credits';

  @override
  String get attributionTmdbBody =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get attributionTmdbDetail =>
      'Posters, images, synopses, cast and ratings.';

  @override
  String get attributionJustWatchBody =>
      'Streaming availability data is provided by JustWatch.';

  @override
  String get attributionJustWatchDetail =>
      'Streaming, rent and buy options for your region.';

  @override
  String get attributionFooter =>
      'PakoTV is a free personal project. All trademarks belong to their respective owners.';

  @override
  String get settingsLicensesLabel => 'Licenses';

  @override
  String get editProfileSheetTitle => 'Edit profile';
}
