import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Discover (B1) — link under a carousel section header that opens the full collection as a filtered list (C1).
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get discoverSeeAll;

  /// Settings (C6) → About's Version row value. {version} is the app's own semantic version (e.g. 1.0.0); {build} is the platform build number.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String settingsAboutVersion(String version, String build);

  /// Settings (C6) → I1 (Confirm deletion) — how many items a deletion removes (e.g. "Delete My List"). {count} is the number of items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String settingsDataDeleteItemCount(int count);

  /// Failure.localizedMessage (FailureReason.network) — the one translation site every network-shaped error goes through, CLAUDE.md rule 15.
  ///
  /// In en, this message translates to:
  /// **'No connection — check your internet and try again.'**
  String get failureNetwork;

  /// Failure.localizedMessage (FailureReason.server).
  ///
  /// In en, this message translates to:
  /// **'TMDB is having trouble right now. Try again in a moment.'**
  String get failureServer;

  /// Failure.localizedMessage (FailureReason.notFound).
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that.'**
  String get failureNotFound;

  /// Failure.localizedMessage (FailureReason.quota).
  ///
  /// In en, this message translates to:
  /// **'Too many requests — try again in a moment.'**
  String get failureQuota;

  /// Failure.localizedMessage (FailureReason.storage) — a local drift/SQLite read or write failure, not network-shaped.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong saving that on your device.'**
  String get failureStorage;

  /// Failure.localizedMessage (FailureReason.unknown) — the generic catch-all.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get failureUnknown;

  /// No description provided for @genreAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genreAction;

  /// No description provided for @genreAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genreAdventure;

  /// No description provided for @genreAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get genreAnimation;

  /// No description provided for @genreComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get genreComedy;

  /// No description provided for @genreCrime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get genreCrime;

  /// No description provided for @genreDocumentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get genreDocumentary;

  /// No description provided for @genreDrama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get genreDrama;

  /// No description provided for @genreFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get genreFamily;

  /// No description provided for @genreHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get genreHistory;

  /// No description provided for @genreHorror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get genreHorror;

  /// No description provided for @genreMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get genreMusic;

  /// No description provided for @genreMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genreMystery;

  /// No description provided for @genreRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreSciFi.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get genreSciFi;

  /// No description provided for @genreThriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genreThriller;

  /// No description provided for @vibeFeelGood.
  ///
  /// In en, this message translates to:
  /// **'Feel Good'**
  String get vibeFeelGood;

  /// No description provided for @vibeIndie.
  ///
  /// In en, this message translates to:
  /// **'Indie'**
  String get vibeIndie;

  /// No description provided for @vibeMonster.
  ///
  /// In en, this message translates to:
  /// **'Monster'**
  String get vibeMonster;

  /// No description provided for @vibeDetective.
  ///
  /// In en, this message translates to:
  /// **'Detective'**
  String get vibeDetective;

  /// No description provided for @vibeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get vibeClassic;

  /// No description provided for @vibeSuperhero.
  ///
  /// In en, this message translates to:
  /// **'Superhero'**
  String get vibeSuperhero;

  /// No description provided for @vibeCult.
  ///
  /// In en, this message translates to:
  /// **'Cult'**
  String get vibeCult;

  /// No description provided for @vibeTearjerker.
  ///
  /// In en, this message translates to:
  /// **'Tearjerker'**
  String get vibeTearjerker;

  /// No description provided for @vibeSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get vibeSports;

  /// No description provided for @vibeDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date Night'**
  String get vibeDateNight;

  /// No description provided for @vibeFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get vibeFuture;

  /// No description provided for @vibeExplosive.
  ///
  /// In en, this message translates to:
  /// **'Explosive'**
  String get vibeExplosive;

  /// No description provided for @vibeGritty.
  ///
  /// In en, this message translates to:
  /// **'Gritty'**
  String get vibeGritty;

  /// No description provided for @vibeTrueStory.
  ///
  /// In en, this message translates to:
  /// **'True Story'**
  String get vibeTrueStory;

  /// No description provided for @vibeGangster.
  ///
  /// In en, this message translates to:
  /// **'Gangster'**
  String get vibeGangster;

  /// No description provided for @vibeMusical.
  ///
  /// In en, this message translates to:
  /// **'Musical'**
  String get vibeMusical;

  /// D2's status pill, and DiscoverTvStatus.airing in H8's filter/the TV status toggle.
  ///
  /// In en, this message translates to:
  /// **'Airing'**
  String get tvStatusAiring;

  /// D2's status pill, and DiscoverTvStatus.ended in H8's filter/the TV status toggle.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get tvStatusEnded;

  /// D2's status pill only — TvStatusPill's own raw-TMDB-string branch for "Canceled"; DiscoverTvStatus (the H8 filter enum) has no cancelled value.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tvStatusCancelled;

  /// E2 step 4's own "Finished | Either" toggle (TV shows) — deliberately its own word, not tvStatusEnded, even though it maps to the same DiscoverTvStatus.ended value.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get quizFinishedToggleFinished;

  /// E2 step 4's own "Finished | Either" toggle — the null/no-filter option.
  ///
  /// In en, this message translates to:
  /// **'Either'**
  String get quizFinishedToggleEither;

  /// A single item's own type, e.g. "2019 · Movie" in a search result row.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get mediaTypeMovieSingular;

  /// A single item's own type, e.g. "2022 · TV Show" in a search result row.
  ///
  /// In en, this message translates to:
  /// **'TV Show'**
  String get mediaTypeTvShowSingular;

  /// A segment/filter/tab label covering every movie, e.g. the Movies segmented control option.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get mediaTypeMoviePlural;

  /// A segment/filter/tab label covering every TV show, e.g. the TV Shows segmented control option.
  ///
  /// In en, this message translates to:
  /// **'TV Shows'**
  String get mediaTypeTvShowPlural;

  /// The small corner tag on a TV show's own poster card, distinguishing it from a movie poster at a glance.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get mediaTypeTvTag;

  /// MediaSegment.all / FilmographySegment.all — the "everything, no type filter" option in a segmented control.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mediaSegmentAll;

  /// D3's filmography segmented control — FilmographySegment.asDirector, only shown once a person has both a cast and a crew credit.
  ///
  /// In en, this message translates to:
  /// **'As director'**
  String get personFilmographyAsDirector;

  /// No description provided for @discoverSortPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get discoverSortPopularity;

  /// No description provided for @discoverSortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get discoverSortRating;

  /// No description provided for @discoverSortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get discoverSortDate;

  /// No description provided for @discoverSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get discoverSortTitle;

  /// No description provided for @myListTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get myListTabFavorites;

  /// No description provided for @myListTabWatchLater.
  ///
  /// In en, this message translates to:
  /// **'Watch later'**
  String get myListTabWatchLater;

  /// No description provided for @myListTabWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get myListTabWatched;

  /// My List's swipe-to-remove snackbar. {tabName} is that LibraryTab's own localized label (myListTabFavorites/WatchLater/Watched).
  ///
  /// In en, this message translates to:
  /// **'Removed from {tabName}'**
  String myListRemovedFromTab(String tabName);

  /// No description provided for @myListEmptyFavoritesHeadline.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get myListEmptyFavoritesHeadline;

  /// No description provided for @myListEmptyWatchLaterHeadline.
  ///
  /// In en, this message translates to:
  /// **'Nothing for later yet'**
  String get myListEmptyWatchLaterHeadline;

  /// No description provided for @myListEmptyWatchedHeadline.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t marked anything as watched yet'**
  String get myListEmptyWatchedHeadline;

  /// My List row title fallback — shown only when MediaRepository.detail hasn't resolved yet for a movie entry. {id} is the TMDB id.
  ///
  /// In en, this message translates to:
  /// **'Movie #{id}'**
  String myListFallbackTitleMovie(int id);

  /// Same as myListFallbackTitleMovie, for a TV show entry.
  ///
  /// In en, this message translates to:
  /// **'TV show #{id}'**
  String myListFallbackTitleTvShow(int id);

  /// C1's active-filter chip for a genre in DiscoverFilter.withoutGenres (H8's "excluded genres"). {genreName} is that genre's own localized display name.
  ///
  /// In en, this message translates to:
  /// **'No {genreName}'**
  String filteredListExcludeGenreChip(String genreName);

  /// B4's filtered-empty state (docs/SCREENS.md B4's own literal example) when a movie-only type filter is what's hiding every entry. Deliberately its own sentence-case key, not composed from mediaTypeMoviePlural ("Movies") — that label's title case doesn't fit mid-sentence here.
  ///
  /// In en, this message translates to:
  /// **'No movies here'**
  String get myListFilteredEmptyMovieTitle;

  /// Same as myListFilteredEmptyMovieTitle, for a TV-show-only type filter — docs/SCREENS.md B4's own literal example.
  ///
  /// In en, this message translates to:
  /// **'No TV shows here'**
  String get myListFilteredEmptyTvShowTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
