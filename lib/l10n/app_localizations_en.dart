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
}
