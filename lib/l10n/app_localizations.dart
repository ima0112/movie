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

  /// Settings (C6) → About's Version row VALUE only — the row's own label is the separate settingsVersionLabel key ("Version"), so this doesn't bake that word in too. {version} is the app's own semantic version (e.g. 1.0.0); {build} is the platform build number. Not wired up to any call site until this branch — safe to reshape.
  ///
  /// In en, this message translates to:
  /// **'{version} ({build})'**
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
  /// **'Something failed while connecting to the server. Try again in a few seconds.'**
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

  /// No description provided for @genreFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genreFantasy;

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

  /// No description provided for @genreWar.
  ///
  /// In en, this message translates to:
  /// **'War'**
  String get genreWar;

  /// No description provided for @genreWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get genreWestern;

  /// On TV, TMDB has one genre that combines action and adventure; this is the chip's name for TV shows.
  ///
  /// In en, this message translates to:
  /// **'Action & Adventure'**
  String get genreActionAdventure;

  /// On TV, TMDB has one genre that combines science fiction and fantasy; this is the chip's name for TV shows.
  ///
  /// In en, this message translates to:
  /// **'Sci-Fi & Fantasy'**
  String get genreSciFiFantasy;

  /// On TV, TMDB's war genre is 'War & Politics'; this is the war chip's name for TV shows.
  ///
  /// In en, this message translates to:
  /// **'War & Politics'**
  String get genreWarPolitics;

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

  /// No description provided for @vibeTimeTravel.
  ///
  /// In en, this message translates to:
  /// **'Time Travel'**
  String get vibeTimeTravel;

  /// No description provided for @vibeComingOfAge.
  ///
  /// In en, this message translates to:
  /// **'Coming of Age'**
  String get vibeComingOfAge;

  /// No description provided for @vibeDystopia.
  ///
  /// In en, this message translates to:
  /// **'Dystopia'**
  String get vibeDystopia;

  /// No description provided for @vibeSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get vibeSurvival;

  /// No description provided for @vibeRevenge.
  ///
  /// In en, this message translates to:
  /// **'Revenge'**
  String get vibeRevenge;

  /// No description provided for @vibeMartialArts.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get vibeMartialArts;

  /// No description provided for @vibeHeist.
  ///
  /// In en, this message translates to:
  /// **'Heist'**
  String get vibeHeist;

  /// D2's Status stat card label above Airing / Ended / Cancelled (docs/SCREENS.md D2).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tvStatusCardLabel;

  /// D2's Status card, and DiscoverTvStatus.airing in H8's filter/the TV status toggle.
  ///
  /// In en, this message translates to:
  /// **'Airing'**
  String get tvStatusAiring;

  /// D2's Status card, and DiscoverTvStatus.ended in H8's filter/the TV status toggle.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get tvStatusEnded;

  /// D2's Status card only — the raw-TMDB-string branch for "Canceled"; DiscoverTvStatus (the H8 filter enum) has no cancelled value.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tvStatusCancelled;

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

  /// B2's fourth segment, narrowing search results to people (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get mediaSegmentPeople;

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

  /// No description provided for @discoverSortVotes.
  ///
  /// In en, this message translates to:
  /// **'Most voted'**
  String get discoverSortVotes;

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

  /// B4's fourth tab: the people saved from a person's page (D3).
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get myListTabPeople;

  /// No description provided for @myListEmptyPeopleHeadline.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get myListEmptyPeopleHeadline;

  /// No description provided for @myListEmptyPeopleBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a person\'s page to keep them here.'**
  String get myListEmptyPeopleBody;

  /// H1 (the three-dot sheet of a My List row): opens H2 for a title that isn't watched yet.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get myListActionMarkWatched;

  /// No description provided for @myListActionEditWatched.
  ///
  /// In en, this message translates to:
  /// **'Edit rating and date'**
  String get myListActionEditWatched;

  /// No description provided for @myListActionAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get myListActionAddFavorite;

  /// No description provided for @myListActionRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get myListActionRemoveFavorite;

  /// No description provided for @myListActionAddWatchLater.
  ///
  /// In en, this message translates to:
  /// **'Add to Watch later'**
  String get myListActionAddWatchLater;

  /// No description provided for @myListActionRemoveWatchLater.
  ///
  /// In en, this message translates to:
  /// **'Remove from Watch later'**
  String get myListActionRemoveWatchLater;

  /// No description provided for @myListActionRemoveWatched.
  ///
  /// In en, this message translates to:
  /// **'Remove from Watched'**
  String get myListActionRemoveWatched;

  /// No description provided for @myListActionRemovePerson.
  ///
  /// In en, this message translates to:
  /// **'Remove from People'**
  String get myListActionRemovePerson;

  /// Accessibility label of the three-dot button at the end of a My List row (opens H1).
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get myListRowActionsLabel;

  /// The coral panel a swipe-to-delete row reveals while it is being dragged.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get swipeDelete;

  /// The same panel once the drag has gone far enough that letting go deletes the row.
  ///
  /// In en, this message translates to:
  /// **'Release to delete'**
  String get swipeReleaseToDelete;

  /// Snackbar after a Favorites / Watch later toggle turned on (D1/D2, H1, Home's save button). {title} is the title's name; {tabName} that list's localized label.
  ///
  /// In en, this message translates to:
  /// **'{title} added to {tabName}'**
  String libraryAddedToTab(String title, String tabName);

  /// Snackbar after H2's Save on a title that wasn't watched.
  ///
  /// In en, this message translates to:
  /// **'{title} marked as watched'**
  String libraryMarkedWatched(String title);

  /// The same snackbar when the title was in Watch later (marking watched takes it out; docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'{title} marked as watched · Removed from Watch later'**
  String libraryMarkedWatchedLeftWatchLater(String title);

  /// My List's remove snackbar (swipe, or the sheet's red row). {title} is the entry's name; {tabName} is that tab's own localized label (myListTabFavorites/WatchLater/Watched/People).
  ///
  /// In en, this message translates to:
  /// **'{title} removed from {tabName}'**
  String myListRemovedFromTab(String title, String tabName);

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

  /// Snackbar when the system can't open an external link (TMDB, YouTube, GitHub…).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that link'**
  String get commonCouldntOpenLink;

  /// Headline of the offline state (OfflineStateView): a load failed because there is no connection.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineStateTitle;

  /// No description provided for @offlineStateBody.
  ///
  /// In en, this message translates to:
  /// **'Discovering and searching need internet. Your list is still available.'**
  String get offlineStateBody;

  /// The text link under the offline state's Retry on the root tabs Home and Explore; opens My List, which works offline.
  ///
  /// In en, this message translates to:
  /// **'Go to My List'**
  String get offlineGoToMyList;

  /// ErrorStateView's fixed CTA label (docs/SCREENS.md G: "Error: same layout with 'Retry'.").
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// A step/form's "move forward" button — onboarding's NameStep and GenreStep (liked step) both use this exact word.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// OnboardingScaffold's header skip link, shown on any step that allows skipping.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @navTabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navTabDiscover;

  /// No description provided for @navTabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navTabExplore;

  /// No description provided for @navTabMyList.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get navTabMyList;

  /// The bottom bar's 4th tab label — also referenced by onboardingTastesSavedSnackbar's own "Edit in You" wording, so keep both in sync if either changes.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navTabYou;

  /// Accessibility label of the center sparkle button in the bottom bar, which opens the Match hub.
  ///
  /// In en, this message translates to:
  /// **'Surprise me and match'**
  String get navMatchButton;

  /// OfflineBanner's persistent top banner text (docs/SCREENS.md G).
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineBannerMessage;

  /// A2's finish() snackbar when saving the onboarding profile fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong — let\'s try again.'**
  String get onboardingSaveError;

  /// A2's exit snackbar when finish() succeeds and at least one genre was picked (docs/SCREENS.md A2). "You" here is the same word as navTabYou — keep them matching.
  ///
  /// In en, this message translates to:
  /// **'Tastes saved · Edit in You'**
  String get onboardingTastesSavedSnackbar;

  /// No description provided for @onboardingLikedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get onboardingLikedEyebrow;

  /// No description provided for @onboardingLikedHeadline.
  ///
  /// In en, this message translates to:
  /// **'What do you like?'**
  String get onboardingLikedHeadline;

  /// The word inside onboardingLikedHeadline rendered in amber — found by a literal substring search, so a translation MUST keep this exact word as a substring of its own translated headline.
  ///
  /// In en, this message translates to:
  /// **'like'**
  String get onboardingLikedHighlight;

  /// No description provided for @onboardingLikedBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a few genres to personalize Discover. You can fine-tune later in You › My Tastes.'**
  String get onboardingLikedBody;

  /// No description provided for @onboardingGenreStep3Headline.
  ///
  /// In en, this message translates to:
  /// **'And which ones never?'**
  String get onboardingGenreStep3Headline;

  /// The single word inside onboardingGenreStep3Headline that GenreStepHeadline renders in amber — it's found by a literal substring search (text.indexOf(word)), so a translation MUST keep this exact word as a literal substring of its own translated onboardingGenreStep3Headline, not just a loose paraphrase.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get onboardingGenreStep3HighlightWord;

  /// No description provided for @onboardingVetoedBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the ones you\'d rather not see and we\'ll keep them out of your recommendations.'**
  String get onboardingVetoedBody;

  /// The last onboarding screen's button (docs/SCREENS.md A2) — it finishes the flow.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingVetoedCta;

  /// No description provided for @onboardingNameHeadline.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get onboardingNameHeadline;

  /// No description provided for @onboardingNameEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get onboardingNameEyebrow;

  /// The word inside onboardingNameHeadline rendered in amber — found by a literal substring search, so a translation MUST keep this exact word as a substring of the headline.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get onboardingNameHighlight;

  /// The name step's button (docs/SCREENS.md A2) — disabled until the name is valid.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNameContinue;

  /// No description provided for @onboardingNameBody.
  ///
  /// In en, this message translates to:
  /// **'That\'s what you\'ll be called in the app, and how others will see you in rooms.'**
  String get onboardingNameBody;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameHint;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get profileColorLabel;

  /// No description provided for @onboardingIntroDiscoverHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find what to watch\nin seconds'**
  String get onboardingIntroDiscoverHeadline;

  /// The phrase inside onboardingIntroDiscoverHeadline rendered in amber — found by a literal substring search, so a translation MUST keep this exact phrase as a substring of its own translated headline.
  ///
  /// In en, this message translates to:
  /// **'in seconds'**
  String get onboardingIntroDiscoverHighlight;

  /// No description provided for @onboardingIntroRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get onboardingIntroRatingLabel;

  /// No description provided for @onboardingIntroDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Explore TMDB\'s catalog. It\'s not a streaming app: we tell you where to watch it.'**
  String get onboardingIntroDiscoverBody;

  /// No description provided for @onboardingIntroSurpriseHeadline.
  ///
  /// In en, this message translates to:
  /// **'No idea? Surprise me'**
  String get onboardingIntroSurpriseHeadline;

  /// The phrase inside onboardingIntroSurpriseHeadline rendered in amber — found by a literal substring search, so a translation MUST keep this exact phrase as a substring of its own translated headline.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get onboardingIntroSurpriseHighlight;

  /// No description provided for @onboardingIntroSurpriseBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions or use your tastes and we\'ll suggest what to watch.'**
  String get onboardingIntroSurpriseBody;

  /// No description provided for @onboardingWelcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Find what to watch'**
  String get onboardingWelcomeTagline;

  /// No description provided for @onboardingWelcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingWelcomeGetStarted;

  /// TMDB attribution caption — used as the footer of the movie, TV and person detail screens (it began on the welcome step). "TMDB" stays untranslated in every locale, same as PakoTV's own name.
  ///
  /// In en, this message translates to:
  /// **'Data from TMDB'**
  String get onboardingWelcomeTmdbAttribution;

  /// Shared inline/section error title — Discover's per-section error row, Explore's search error, and C1's own error state all use this exact wording (docs/SCREENS.md B1/B2/C1).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load'**
  String get commonCouldntLoad;

  /// C1's empty-filtered-state CTA and H8's filter sheet reset button (docs/SCREENS.md C1/H8) — same word, same action, in both places.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// B2's search field "×"/Cancel control (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// B2's "Recent" searches chip row clear-all action (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

  /// B2's own "Genres" grid section header and H8's "Genres" filter-sheet section label — same word in both places.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get commonGenres;

  /// No description provided for @carouselSectionForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get carouselSectionForYou;

  /// No description provided for @carouselSectionPopularThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get carouselSectionPopularThisWeek;

  /// B1's All tab: 'Because you like X' where X is one of the collections (Turkish series, Anime…) in the user's taste profile (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Because you like {collection}'**
  String carouselSectionBecauseYouLikeCollection(String collection);

  /// B1's All tab: 'Because you like X' where X is one of the genres in the user's taste profile (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Because you like {genre}'**
  String carouselSectionBecauseYouLikeGenre(String genre);

  /// B1's All tab: 'Because you like X' where X is one of the vibes in the user's taste profile (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Because you like {vibe}'**
  String carouselSectionBecauseYouLikeVibe(String vibe);

  /// B1's Movies tab: 'Because you like X' where X is a person (actor, director…) the user saved from D3 and appears in the movies of the carousel.
  ///
  /// In en, this message translates to:
  /// **'Because you like {person}'**
  String carouselSectionBecauseYouLikePerson(String person);

  /// B1's Movies/TV Shows 'Because you saved X' carousel header (docs/SCREENS.md B1) — X is the day's seed title, a real UserMediaEntry.title the user saved (a favorite, a well-rated watch, or in Watch later), never a genre.
  ///
  /// In en, this message translates to:
  /// **'Because you saved {title}'**
  String carouselSectionBecauseYouSaved(String title);

  /// No description provided for @carouselSectionInTheaters.
  ///
  /// In en, this message translates to:
  /// **'In theaters'**
  String get carouselSectionInTheaters;

  /// No description provided for @carouselSectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get carouselSectionComingSoon;

  /// No description provided for @carouselSectionFinishedShows.
  ///
  /// In en, this message translates to:
  /// **'Finished shows'**
  String get carouselSectionFinishedShows;

  /// No description provided for @carouselSectionLatestTrailers.
  ///
  /// In en, this message translates to:
  /// **'Latest trailers'**
  String get carouselSectionLatestTrailers;

  /// No description provided for @carouselSectionRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get carouselSectionRecentlyViewed;

  /// Title of B1's taste-completion card, shown on the All tab while there is no taste profile and My List is empty (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Recommendations tailored to you'**
  String get discoverTasteCardTitle;

  /// No description provided for @discoverTasteCardEyebrow.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get discoverTasteCardEyebrow;

  /// No description provided for @discoverTasteCardCta.
  ///
  /// In en, this message translates to:
  /// **'Choose my tastes'**
  String get discoverTasteCardCta;

  /// Title of the sheet that re-sorts a See all listing (docs/SCREENS.md C1b).
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sectionListingSortTitle;

  /// No description provided for @sectionListingSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sectionListingSortTooltip;

  /// C1b's first sort option: the order the section previewed.
  ///
  /// In en, this message translates to:
  /// **'Default order'**
  String get sectionListingSortDefault;

  /// No description provided for @sectionListingSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sectionListingSortNewest;

  /// No description provided for @sectionListingAllGenres.
  ///
  /// In en, this message translates to:
  /// **'All genres'**
  String get sectionListingAllGenres;

  /// No description provided for @sectionListingAllPlatforms.
  ///
  /// In en, this message translates to:
  /// **'All platforms'**
  String get sectionListingAllPlatforms;

  /// No description provided for @sectionListingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show here'**
  String get sectionListingEmptyTitle;

  /// No description provided for @sectionListingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another genre or platform.'**
  String get sectionListingEmptyBody;

  /// No description provided for @sectionListingLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more'**
  String get sectionListingLoadMoreFailed;

  /// D1's header tag for a movie that is in cinemas but not yet on streaming/digital (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'In theaters'**
  String get releaseStatusInTheaters;

  /// D1/D2's header tag for a title that isn't out yet and has no known release date.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get releaseStatusComingSoon;

  /// D1/D2's header tag for a title that isn't out yet, with its release date (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'Coming {date}'**
  String releaseStatusComingOn(String date);

  /// D1/D2's Where to watch card for a title that isn't released and has no date.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t out yet, so it isn\'t on any service.'**
  String get whereToWatchNotReleased;

  /// D1/D2's Where to watch card for an unreleased title with a release date.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t out yet. It comes out on {date}.'**
  String whereToWatchNotReleasedOn(String date);

  /// D1's Where to watch card for a movie that is in cinemas only.
  ///
  /// In en, this message translates to:
  /// **'In theaters now, and not on any service yet.'**
  String get whereToWatchInTheaters;

  /// D1's Where to watch card for a movie in cinemas whose digital release date is known.
  ///
  /// In en, this message translates to:
  /// **'In theaters now. Expected on streaming on {date}.'**
  String whereToWatchInTheatersStreamingOn(String date);

  /// Accessibility label of a Latest trailers card (docs/SCREENS.md B1); opens the trailer in YouTube.
  ///
  /// In en, this message translates to:
  /// **'Play the trailer for {title}'**
  String trailerPlayLabel(String title);

  /// No description provided for @carouselSectionTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get carouselSectionTrending;

  /// No description provided for @carouselSectionTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get carouselSectionTopRated;

  /// No description provided for @carouselSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get carouselSectionUpcoming;

  /// No description provided for @carouselSectionAiringNow.
  ///
  /// In en, this message translates to:
  /// **'Airing now'**
  String get carouselSectionAiringNow;

  /// CarouselSection.popular — TV Shows segment only (docs/SCREENS.md B1). CarouselSection.watchLater reuses myListTabWatchLater instead of its own key.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get carouselSectionPopular;

  /// No description provided for @collectionTurkishSeries.
  ///
  /// In en, this message translates to:
  /// **'Turkish series'**
  String get collectionTurkishSeries;

  /// No description provided for @collectionSpanishSeries.
  ///
  /// In en, this message translates to:
  /// **'Spanish series'**
  String get collectionSpanishSeries;

  /// No description provided for @collectionLatinAmericanSeries.
  ///
  /// In en, this message translates to:
  /// **'Latin American series'**
  String get collectionLatinAmericanSeries;

  /// No description provided for @collectionKDramas.
  ///
  /// In en, this message translates to:
  /// **'K-dramas'**
  String get collectionKDramas;

  /// No description provided for @collectionBritishSeries.
  ///
  /// In en, this message translates to:
  /// **'British series'**
  String get collectionBritishSeries;

  /// No description provided for @collectionSpanishCinema.
  ///
  /// In en, this message translates to:
  /// **'Spanish-language cinema'**
  String get collectionSpanishCinema;

  /// No description provided for @collectionKoreanCinema.
  ///
  /// In en, this message translates to:
  /// **'Korean cinema'**
  String get collectionKoreanCinema;

  /// No description provided for @collectionBollywood.
  ///
  /// In en, this message translates to:
  /// **'Bollywood'**
  String get collectionBollywood;

  /// No description provided for @collectionSoaps.
  ///
  /// In en, this message translates to:
  /// **'Soap operas'**
  String get collectionSoaps;

  /// No description provided for @collectionAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get collectionAnime;

  /// No description provided for @collectionRealityShows.
  ///
  /// In en, this message translates to:
  /// **'Reality shows'**
  String get collectionRealityShows;

  /// No description provided for @collectionKids.
  ///
  /// In en, this message translates to:
  /// **'For kids'**
  String get collectionKids;

  /// B2's overline above the genre pill row at rest (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get exploreGenreLabel;

  /// B2's first genre pill: no genre filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exploreGenreAll;

  /// The small caps label above B2's streaming-platform pills.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get explorePlatformLabel;

  /// The "no platform filter" pill (feminine in Spanish, like "Plataformas").
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get explorePlatformAll;

  /// B2 body section: the most popular titles right now, numbered.
  ///
  /// In en, this message translates to:
  /// **'Top today'**
  String get exploreSectionTopToday;

  /// B2 body section: the most voted titles of all time (the classics).
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get exploreSectionPopular;

  /// B2 body section: titles releasing in the next three months.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get exploreSectionComingSoon;

  /// The supporting line under B2's "Top rated" heading, the section that gets the most weight.
  ///
  /// In en, this message translates to:
  /// **'The best of all time, by score'**
  String get exploreSectionTopRatedSubtitle;

  /// B2 body section: the best rated titles.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get exploreSectionTopRated;

  /// B2 body section: titles released in the last two months.
  ///
  /// In en, this message translates to:
  /// **'New releases'**
  String get exploreSectionNewReleases;

  /// B2 body section: well rated titles few people have voted on.
  ///
  /// In en, this message translates to:
  /// **'Hidden gems'**
  String get exploreSectionHiddenGems;

  /// B2 body empty state when the chosen genre/platform leaves every section empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing for these filters'**
  String get exploreBrowseEmptyTitle;

  /// Body of exploreBrowseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Try another genre or platform.'**
  String get exploreBrowseEmptyBody;

  /// No description provided for @exploreNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get exploreNoResults;

  /// B2's no-results state under the search field: names what was searched (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find anything for “{query}”. Try another title, show or person.'**
  String exploreNoResultsBody(String query);

  /// No description provided for @exploreFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exploreFilterTooltip;

  /// The no-results state's button: empties the search field and goes back to B2 at rest.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get exploreClearSearch;

  /// C1's page title fallback when B1/B2 open it without a more specific name (docs/SCREENS.md C1: "title ('In theaters' / 'Horror' / 'Results')").
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get exploreDefaultResultsTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Movies, TV shows, people'**
  String get exploreSearchHint;

  /// Tooltip/accessibility label of the × on a recent search row (docs/SCREENS.md B2).
  ///
  /// In en, this message translates to:
  /// **'Remove {query} from recent searches'**
  String exploreRecentRemove(String query);

  /// No description provided for @exploreRecentSearchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get exploreRecentSearchesLabel;

  /// B2's search result row metadata for a person with no known department (docs/SCREENS.md B2: "'Department · Person'").
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get explorePersonLabel;

  /// B2's search result row metadata for a person (docs/SCREENS.md B2: "'Department · Person'"). {department} is TMDB's own known-for department text ("Acting", "Directing"), already in the content language.
  ///
  /// In en, this message translates to:
  /// **'{department} · Person'**
  String explorePersonMetadata(String department);

  /// B2's search result row metadata line (docs/SCREENS.md B2: "'Year · Movie/TV Show'"). {typeLabel} is MediaType's own localized singular (mediaTypeMovieSingular/TvShowSingular).
  ///
  /// In en, this message translates to:
  /// **'{year} · {typeLabel}'**
  String exploreResultMetadata(int year, String typeLabel);

  /// C1's active-filter chip for a year range, e.g. "1950–2024" (no spaces around the dash — distinct from discoverRangeFiltersYearRange's own spaced dash).
  ///
  /// In en, this message translates to:
  /// **'{from}–{to}'**
  String filteredListYearRangeChip(int from, int to);

  /// C1's active-filter chip for a minimum-rating filter, e.g. "7.5+ rating". {rating} arrives already formatted to one decimal place.
  ///
  /// In en, this message translates to:
  /// **'{rating}+ rating'**
  String filteredListMinRatingChip(String rating);

  /// C1's active-filter chip for a max-runtime filter, e.g. "Under 120 min".
  ///
  /// In en, this message translates to:
  /// **'Under {minutes} min'**
  String filteredListMaxRuntimeChip(int minutes);

  /// C1's empty-filtered-state headline (docs/SCREENS.md C1: "empty ('Nothing matches these filters' + 'Reset')").
  ///
  /// In en, this message translates to:
  /// **'Nothing with those filters'**
  String get filteredListEmptyTitle;

  /// No description provided for @filteredListClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filteredListClearFilters;

  /// No description provided for @filteredListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try fewer filters or a lower minimum rating.'**
  String get filteredListEmptyBody;

  /// C1's own count/sort line (docs/SCREENS.md C1: "line '312 results · Popularity'"). {sortLabel} is DiscoverSortBy's own localized label. Deliberately not ICU-pluralized in English — "1 results" is this control's existing (if ungrammatical) behavior, preserved as-is by this mechanical migration; a locale introducing this string for the first time (e.g. Spanish) is free to pluralize correctly since there's no prior behavior of its own to preserve.
  ///
  /// In en, this message translates to:
  /// **'{count} results · {sortLabel}'**
  String filteredListCountLine(int count, String sortLabel);

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterSheetTitle;

  /// H8's header button that resets every filter (amber text, shown only while something is set).
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterSheetClear;

  /// No description provided for @filterSheetSectionStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming on'**
  String get filterSheetSectionStreaming;

  /// No description provided for @filterSheetSortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get filterSheetSortPopular;

  /// No description provided for @filterSheetSortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get filterSheetSortTopRated;

  /// No description provided for @filterSheetSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get filterSheetSortNewest;

  /// No description provided for @filterSheetSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get filterSheetSortOldest;

  /// H8's minimum-rating slider value, shown next to a star, e.g. "7.0 or more".
  ///
  /// In en, this message translates to:
  /// **'{rating} or more'**
  String filterSheetMinRatingValue(String rating);

  /// No description provided for @filterSheetMinRatingAny.
  ///
  /// In en, this message translates to:
  /// **'Any rating'**
  String get filterSheetMinRatingAny;

  /// H8's apply button while the live count is 0 (disabled).
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get filterSheetNoResults;

  /// No description provided for @filterSheetYearFrom.
  ///
  /// In en, this message translates to:
  /// **'From year'**
  String get filterSheetYearFrom;

  /// No description provided for @filterSheetYearTo.
  ///
  /// In en, this message translates to:
  /// **'To year'**
  String get filterSheetYearTo;

  /// No description provided for @filterSheetPresetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get filterSheetPresetComingSoon;

  /// No description provided for @filterSheetPresetInTheaters.
  ///
  /// In en, this message translates to:
  /// **'In theaters'**
  String get filterSheetPresetInTheaters;

  /// No description provided for @filterSheetPresetFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get filterSheetPresetFinished;

  /// No description provided for @filterSheetPresetAiringNow.
  ///
  /// In en, this message translates to:
  /// **'Airing now'**
  String get filterSheetPresetAiringNow;

  /// No description provided for @filterSheetSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get filterSheetSectionLanguage;

  /// No description provided for @filterSheetLanguageAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterSheetLanguageAny;

  /// H8's rating range slider value, shown next to a star, e.g. "4.5 – 8.0".
  ///
  /// In en, this message translates to:
  /// **'{min} – {max}'**
  String filterSheetRatingRangeValue(String min, String max);

  /// C1's active-filter chip for a rating range, e.g. "Rating 4.5–8.0".
  ///
  /// In en, this message translates to:
  /// **'Rating {min}–{max}'**
  String filteredListRatingRangeChip(String min, String max);

  /// H8's section for the curated collections (Turkish series, Anime, For kids…), single select, shown for the kinds of title that have them.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get filterSheetSectionCollection;

  /// No description provided for @filterSheetSectionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterSheetSectionType;

  /// No description provided for @filterSheetSectionYear.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get filterSheetSectionYear;

  /// No description provided for @filterSheetSectionMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get filterSheetSectionMinRating;

  /// No description provided for @filterSheetSectionRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get filterSheetSectionRating;

  /// No description provided for @filterSheetSectionMaxRuntime.
  ///
  /// In en, this message translates to:
  /// **'Max runtime'**
  String get filterSheetSectionMaxRuntime;

  /// No description provided for @filterSheetSectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterSheetSectionStatus;

  /// No description provided for @filterSheetSectionSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSheetSectionSortBy;

  /// H8's apply button: it just says "See results" (no number; it turns into filterSheetNoResults, disabled, when nothing matches).
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get filterSheetSeeResultsLoading;

  /// H8's year-range slider's own live value display, e.g. "1950 – 2024" (spaces around the dash — distinct from filteredListYearRangeChip's own unspaced dash).
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String discoverRangeFiltersYearRange(int from, int to);

  /// A range slider's far end meaning "no upper bound" — matches A2 (onboarding/quiz)'s own wording for the same control, per this file's own cross-reference comment.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get discoverRangeFiltersNoLimit;

  /// A runtime slider's own live value display, e.g. "120 min".
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String discoverRangeFiltersMinutes(int value);

  /// No description provided for @libraryRowAddedToday.
  ///
  /// In en, this message translates to:
  /// **'Added today'**
  String get libraryRowAddedToday;

  /// No description provided for @libraryRowAddedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Added yesterday'**
  String get libraryRowAddedYesterday;

  /// A Favorites / Watch later row's line, for 2–6 days after the title was added (docs/SCREENS.md B4). Never called with 1 (that is libraryRowAddedYesterday).
  ///
  /// In en, this message translates to:
  /// **'Added {count} days ago'**
  String libraryRowAddedDaysAgo(int count);

  /// The same line for 1–4 weeks after the title was added.
  ///
  /// In en, this message translates to:
  /// **'Added {count, plural, =1{1 week} other{{count} weeks}} ago'**
  String libraryRowAddedWeeksAgo(int count);

  /// The same line once more than 4 weeks have passed. {date} is the app's full date (12 Jan, 2026).
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String libraryRowAddedOn(String date);

  /// B4's swipe-to-remove SnackBarAction label, next to the tab-specific myListRemovedFromTab message.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get myListUndoAction;

  /// B4's empty-state body line when a whole tab has zero entries (MyListEmptyState.otherTabsNote).
  ///
  /// In en, this message translates to:
  /// **'Explore to add movies and shows here.'**
  String get myListBodyOtherTabsNote;

  /// B4's own filtered-empty-state headline when no type filter is active. Deliberately distinct from C1's filteredListEmptyTitle ("Nothing matches these filters") — different screen, different exact wording in the existing code, preserved as its own key rather than merged.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your filters'**
  String get myListBodyEmptyFilterTitle;

  /// A TV show row's metadata line (B4) — season count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 season} other{{count} seasons}}'**
  String myListSeasonsCount(int count);

  /// My List's own TV show row metadata line (B4) — episode count, from UserMediaEntry.episodeCount (the persisted snapshot has no season count).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String myListEpisodesCount(int count);

  /// A movie row's metadata line (B4) — runtime, for anything an hour or longer.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String myListRuntimeHoursMinutes(int hours, int minutes);

  /// Same as myListRuntimeHoursMinutes, for a runtime under an hour.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String myListRuntimeMinutesOnly(int minutes);

  /// No description provided for @myListSortTitleAz.
  ///
  /// In en, this message translates to:
  /// **'Title A–Z'**
  String get myListSortTitleAz;

  /// B4's sort-by chip — "TMDB" stays untranslated in every locale, only "rating" translates.
  ///
  /// In en, this message translates to:
  /// **'TMDB rating'**
  String get myListSortTmdbRating;

  /// No description provided for @myListSortMyRating.
  ///
  /// In en, this message translates to:
  /// **'My rating'**
  String get myListSortMyRating;

  /// No description provided for @myListSortDateWatched.
  ///
  /// In en, this message translates to:
  /// **'Date watched'**
  String get myListSortDateWatched;

  /// No description provided for @myListFilterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort and filter'**
  String get myListFilterSheetTitle;

  /// B4's own filter sheet "Apply" button — a generic enough verb other sheets may reuse later.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @myListHideWatchedToggle.
  ///
  /// In en, this message translates to:
  /// **'Hide what I\'ve watched'**
  String get myListHideWatchedToggle;

  /// Shared across three spots: MyTastesCard's own header (B5), MyTastesInvitation's button label, and C5's AppBar title — same word, same screen, in all three.
  ///
  /// In en, this message translates to:
  /// **'My Tastes'**
  String get myTastesTitle;

  /// MyTastesCard's summary line (docs/SCREENS.md B5: "3 vibes · since 1990 · never Horror"), first fragment. Deliberately not ICU-pluralized in English — always says "vibes", even at count == 1 — preserving this control's existing behavior exactly; Spanish, which has no prior behavior of its own, pluralizes correctly.
  ///
  /// In en, this message translates to:
  /// **'{count} vibes'**
  String myTastesSummaryVibeCount(int count);

  /// No description provided for @myTastesInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your taste profile'**
  String get myTastesInvitationTitle;

  /// No description provided for @myTastesInvitationBody.
  ///
  /// In en, this message translates to:
  /// **'Get picks that actually match what you like.'**
  String get myTastesInvitationBody;

  /// No description provided for @youHeaderGreetingNoProfile.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get youHeaderGreetingNoProfile;

  /// No description provided for @youHeaderTapToSetName.
  ///
  /// In en, this message translates to:
  /// **'Tap to set your name'**
  String get youHeaderTapToSetName;

  /// You's header once a profile name exists.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String youHeaderGreetingWithName(String name);

  /// You's stats card: the hours watched expressed in whole days (shown from one day on).
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{≈ 1 day of screen time} other{≈ {days} days of screen time}}'**
  String youStatsDaysOfScreen(int days);

  /// You's stats card: consecutive weeks with something watched.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week} other{{weeks} weeks}} streak'**
  String youStatsStreak(int weeks);

  /// You's stats card: titles watched this calendar month.
  ///
  /// In en, this message translates to:
  /// **'{count} this month'**
  String youStatsThisMonth(int count);

  /// The label over Surprise me's mini summary in B5's stats card (shown in capitals): the feature's name.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get youStatsSurpriseTitle;

  /// Under the number of Surprise me sessions in B5's stats card.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get youStatsSurpriseSessions;

  /// Under the number of titles chosen in Surprise me in B5's stats card.
  ///
  /// In en, this message translates to:
  /// **'Picks'**
  String get youStatsSurprisePicks;

  /// No description provided for @youStatsLast12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get youStatsLast12Months;

  /// Legend of the movies / TV shows split bar on You.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie} other{{count} movies}}'**
  String youStatsMovies(int count);

  /// Legend of the movies / TV shows split bar on You.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 TV show} other{{count} TV shows}}'**
  String youStatsShows(int count);

  /// The line under the user's name on You (docs/SCREENS.md B5), from their watch history: fewer than 5 titles watched. The viewer* keys are all this one line.
  ///
  /// In en, this message translates to:
  /// **'Just getting started'**
  String get viewerNewcomer;

  /// No description provided for @viewerSeriesBinger.
  ///
  /// In en, this message translates to:
  /// **'Series binger'**
  String get viewerSeriesBinger;

  /// No description provided for @viewerExigentCritic.
  ///
  /// In en, this message translates to:
  /// **'Tough critic'**
  String get viewerExigentCritic;

  /// No description provided for @viewerEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'Enthusiastic viewer'**
  String get viewerEnthusiast;

  /// A genre makes up a big share of what the user watches. {genre} is its localized name.
  ///
  /// In en, this message translates to:
  /// **'Fan of {genre}'**
  String viewerGenreFan(String genre);

  /// No description provided for @viewerCinephile.
  ///
  /// In en, this message translates to:
  /// **'Movie buff'**
  String get viewerCinephile;

  /// No description provided for @viewerExplorer.
  ///
  /// In en, this message translates to:
  /// **'A bit of everything'**
  String get viewerExplorer;

  /// Heading of You's row of the last titles marked as watched (docs/SCREENS.md B5).
  ///
  /// In en, this message translates to:
  /// **'Recently watched'**
  String get youRecentlyWatchedTitle;

  /// The My Tastes row's summary on You: the two named liked genres and how many more there are.
  ///
  /// In en, this message translates to:
  /// **'{names} +{count}'**
  String myTastesRowGenresMore(String names, int count);

  /// The My Tastes row's summary when a taste profile exists but has no liked genres or vibes yet.
  ///
  /// In en, this message translates to:
  /// **'Genres, vibes, platforms and more'**
  String get myTastesRowFallback;

  /// No description provided for @yourActivityHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get yourActivityHoursLabel;

  /// No description provided for @yourActivitySeeStats.
  ///
  /// In en, this message translates to:
  /// **'See stats'**
  String get yourActivitySeeStats;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsActivityStripTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity over the last 12 months'**
  String get statsActivityStripTitle;

  /// No description provided for @statsPeriodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsPeriodAllTime;

  /// No description provided for @statsPeriodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get statsPeriodThisYear;

  /// No description provided for @statsPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsPeriodThisMonth;

  /// C4's lead card: how many titles were watched in the period.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 title} other{{count} titles}}'**
  String statsTitlesCount(int count);

  /// No description provided for @statsVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get statsVsLastMonth;

  /// No description provided for @statsVsLastYear.
  ///
  /// In en, this message translates to:
  /// **'vs last year'**
  String get statsVsLastYear;

  /// C4's comparison chip, e.g. "+4 vs last month". {delta} is signed; {previous} says what it is compared to.
  ///
  /// In en, this message translates to:
  /// **'{delta} {previous}'**
  String statsDelta(String delta, String previous);

  /// No description provided for @statsEmptyPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing watched in this period'**
  String get statsEmptyPeriodTitle;

  /// No description provided for @statsEmptyPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Try another period, or mark something as watched.'**
  String get statsEmptyPeriodBody;

  /// No description provided for @statsHighlightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get statsHighlightsTitle;

  /// No description provided for @statsBusiestMonth.
  ///
  /// In en, this message translates to:
  /// **'Busiest month'**
  String get statsBusiestMonth;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @statsNoStreak.
  ///
  /// In en, this message translates to:
  /// **'No streak now'**
  String get statsNoStreak;

  /// A span of weeks in C4's streak highlight.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String statsWeeks(int count);

  /// C4's streak card detail; {weeks} is statsWeeks.
  ///
  /// In en, this message translates to:
  /// **'Best: {weeks}'**
  String statsBestStreak(String weeks);

  /// No description provided for @statsLongestMovie.
  ///
  /// In en, this message translates to:
  /// **'Longest movie'**
  String get statsLongestMovie;

  /// No description provided for @statsLongestShow.
  ///
  /// In en, this message translates to:
  /// **'Longest show'**
  String get statsLongestShow;

  /// No description provided for @statsBestRated.
  ///
  /// In en, this message translates to:
  /// **'Your top rated'**
  String get statsBestRated;

  /// C4's top-rated card detail: the user's rating.
  ///
  /// In en, this message translates to:
  /// **'★ {stars} of 5'**
  String statsStarsOfFive(int stars);

  /// No description provided for @statsBacklog.
  ///
  /// In en, this message translates to:
  /// **'Watch later'**
  String get statsBacklog;

  /// C4's Watch later card detail; {hours} is already formatted ("30 h").
  ///
  /// In en, this message translates to:
  /// **'≈ {hours} to watch'**
  String statsBacklogHours(String hours);

  /// No description provided for @statsActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get statsActivityTitle;

  /// No description provided for @statsActivityLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsActivityLess;

  /// No description provided for @statsActivityMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsActivityMore;

  /// No description provided for @statsRatingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your ratings'**
  String get statsRatingsTitle;

  /// C4 ratings card: the user's average rating.
  ///
  /// In en, this message translates to:
  /// **'{value} average'**
  String statsRatingAverage(String value);

  /// C4 ratings card: TMDB's average over the same titles.
  ///
  /// In en, this message translates to:
  /// **'TMDB: {value}'**
  String statsRatingTmdb(String value);

  /// C4: how much more generous the user rates than TMDB.
  ///
  /// In en, this message translates to:
  /// **'You rate {gap} ★ above TMDB on average'**
  String statsRatingHigher(String gap);

  /// C4: how much harsher the user rates than TMDB.
  ///
  /// In en, this message translates to:
  /// **'You rate {gap} ★ below TMDB on average'**
  String statsRatingLower(String gap);

  /// No description provided for @statsRatingInLine.
  ///
  /// In en, this message translates to:
  /// **'You rate in line with TMDB'**
  String get statsRatingInLine;

  /// No description provided for @statsDisagreementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where you differ from TMDB'**
  String get statsDisagreementsTitle;

  /// C4 disagreement row: the user's stars vs TMDB's.
  ///
  /// In en, this message translates to:
  /// **'You ★ {user} · TMDB ★ {tmdb}'**
  String statsDisagreement(String user, String tmdb);

  /// C4 genres list: expands it to every genre.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String statsGenresShowAll(int count);

  /// No description provided for @statsGenresShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get statsGenresShowLess;

  /// A genre's share of the genres counted.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsGenrePercent(int percent);

  /// No description provided for @statsDecadesTitle.
  ///
  /// In en, this message translates to:
  /// **'By decade'**
  String get statsDecadesTitle;

  /// C4 decades chart label: 1990 -> '1990s'.
  ///
  /// In en, this message translates to:
  /// **'{decade}s'**
  String statsDecadeLabel(int decade);

  /// C4's always-visible data-coverage note: how many watched titles have genres, year and duration saved.
  ///
  /// In en, this message translates to:
  /// **'Based on {complete} of {total, plural, one{1 title} other{{total} titles}} with full data.'**
  String statsCoverage(int complete, int total);

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark something as watched or try Surprise me to see your stats'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your numbers will show up here once you do.'**
  String get statsEmptyBody;

  /// No description provided for @statsGenreBarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Genres you watch most'**
  String get statsGenreBarsTitle;

  /// No description provided for @statsMoviesWatchedLabel.
  ///
  /// In en, this message translates to:
  /// **'Movies watched'**
  String get statsMoviesWatchedLabel;

  /// No description provided for @statsHoursOfMoviesLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours of movies'**
  String get statsHoursOfMoviesLabel;

  /// No description provided for @statsTvShowsWatchedLabel.
  ///
  /// In en, this message translates to:
  /// **'TV shows watched'**
  String get statsTvShowsWatchedLabel;

  /// No description provided for @statsEstimatedTvHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated TV hours'**
  String get statsEstimatedTvHoursLabel;

  /// C5's section title for liked collections (Turkish series, Anime, Soap operas…); For kids is not offered here.
  ///
  /// In en, this message translates to:
  /// **'Collections you like'**
  String get myTastesCollectionsTitle;

  /// No description provided for @myTastesCollectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Series from a country, anime, soaps… the places and formats you come back to.'**
  String get myTastesCollectionsHint;

  /// No description provided for @myTastesVibesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite vibes'**
  String get myTastesVibesTitle;

  /// C5's hint under "Favorite vibes"; {max} is how many can be picked.
  ///
  /// In en, this message translates to:
  /// **'Up to {max}. They set the tone of what we suggest.'**
  String myTastesVibesHint(int max);

  /// Label of the first card of a release-year range picker (shown in capitals), over the first year.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get releaseRangeFrom;

  /// No description provided for @releaseRangeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get releaseRangeTo;

  /// A release range's open end: the current year, shown as a word.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get releaseRangeToday;

  /// No description provided for @releaseRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get releaseRangeAll;

  /// No description provided for @releaseRange2020s.
  ///
  /// In en, this message translates to:
  /// **'2020s'**
  String get releaseRange2020s;

  /// No description provided for @releaseRange2010s.
  ///
  /// In en, this message translates to:
  /// **'2010s'**
  String get releaseRange2010s;

  /// No description provided for @releaseRange2000s.
  ///
  /// In en, this message translates to:
  /// **'2000s'**
  String get releaseRange2000s;

  /// Release-range preset: everything before the 2010s.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get releaseRangeEarlier;

  /// No description provided for @myTastesErasTitle.
  ///
  /// In en, this message translates to:
  /// **'Eras'**
  String get myTastesErasTitle;

  /// No description provided for @myTastesErasHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a release range'**
  String get myTastesErasHint;

  /// The chip in C5's "My platforms" that opens the picker of the region's streaming services.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get myTastesPlatformsAdd;

  /// No description provided for @myTastesPlatformsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add platforms'**
  String get myTastesPlatformsSheetTitle;

  /// No description provided for @myTastesPlatformsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search platforms'**
  String get myTastesPlatformsSearchHint;

  /// Accessibility label of a picked platform's logo in My platforms; tapping it removes the service. {name} is the service's name.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String myTastesPlatformRemove(String name);

  /// No description provided for @myTastesPlatformsTitle.
  ///
  /// In en, this message translates to:
  /// **'My platforms'**
  String get myTastesPlatformsTitle;

  /// No description provided for @myTastesPlatformsHint.
  ///
  /// In en, this message translates to:
  /// **'We prioritize what you can already watch in your region.'**
  String get myTastesPlatformsHint;

  /// No description provided for @myTastesGenresLikeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose as many as you like.'**
  String get myTastesGenresLikeHint;

  /// No description provided for @myTastesGenresNeverHint.
  ///
  /// In en, this message translates to:
  /// **'We won\'t show them in recommendations.'**
  String get myTastesGenresNeverHint;

  /// No description provided for @myTastesGenresLikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Genres you like'**
  String get myTastesGenresLikeTitle;

  /// No description provided for @myTastesGenresNeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Genres you avoid'**
  String get myTastesGenresNeverTitle;

  /// No description provided for @myTastesSavedIndicator.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get myTastesSavedIndicator;

  /// StatsMetricGrid's own hours-value format, e.g. "312 h" (docs/SCREENS.md C4's own example). {hours} is already locale-formatted (LocalizedCount.localizedCount) before being substituted in.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String statsHoursValue(String hours);

  /// D1's stat card label above the movie's runtime (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get mediaDetailDuration;

  /// D1's stat card label above the movie's age certification ("PG-13", "R"…), not the TMDB score (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get mediaDetailClassification;

  /// The small caption above D1/D2's synopsis text; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get mediaDetailSynopsis;

  /// The tap-to-collapse link shown after an expanded synopsis (the opposite of commonReadMore).
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get commonReadLess;

  /// The tap-to-expand link at the end of a folded synopsis/biography (docs/SCREENS.md D1: "Synopsis folded to 4 lines with an amber 'Read more'") — shared by D1/D2's synopsis, D3's biography, and H4's episode overview.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get commonReadMore;

  /// D2's "Seasons" row and H4's own title both show a season's episode count (docs/SCREENS.md D2).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String tvEpisodeCount(int count);

  /// D2's creator credit under the Cast heading (docs/SCREENS.md D2) — trailing space is deliberate, it precedes the first tappable name with no separator of its own.
  ///
  /// In en, this message translates to:
  /// **'Created by '**
  String get mediaCreatedByLabel;

  /// D1's director credit under the Cast heading (the film's counterpart of D2's Created by) - trailing space is deliberate, same as mediaCreatedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Directed by '**
  String get mediaDirectedByLabel;

  /// H4b's caption over the episode name (e.g. "S1 · E4").
  ///
  /// In en, this message translates to:
  /// **'S{season} · E{episode}'**
  String tvEpisodeCode(int season, int episode);

  /// H4b's caption for an episode of season 0 (TMDB's specials).
  ///
  /// In en, this message translates to:
  /// **'Specials · E{episode}'**
  String tvEpisodeCodeSpecials(int episode);

  /// The episode sheet's Previous button when there is no previous episode (it is dimmed).
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get tvEpisodePrevious;

  /// The episode sheet's Previous button, with the previous episode's number, e.g. "Previous · E1".
  ///
  /// In en, this message translates to:
  /// **'Previous · E{episode}'**
  String tvEpisodePreviousWithCode(int episode);

  /// The episode sheet's Next button when there is no next episode (it is dimmed).
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tvEpisodeNext;

  /// The episode sheet's Next button, with the next episode's number, e.g. "Next · E2".
  ///
  /// In en, this message translates to:
  /// **'Next · E{episode}'**
  String tvEpisodeNextWithCode(int episode);

  /// No description provided for @tvEpisodeGuestStars.
  ///
  /// In en, this message translates to:
  /// **'Guest stars'**
  String get tvEpisodeGuestStars;

  /// No description provided for @tvSeasonsLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get tvSeasonsLinkLabel;

  /// D2's Seasons card value, e.g. "5 · 62 episodes" — season count, a dot, then the total episodes with their word (pluralised).
  ///
  /// In en, this message translates to:
  /// **'{seasons} · {episodes, plural, =1{1 episode} other{{episodes} episodes}}'**
  String tvSeasonsLinkValue(int seasons, int episodes);

  /// D2b's timeline card: the label of the next-episode node (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tvTimelineNext;

  /// D2b's timeline card: the label of the last-aired-episode node (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Last aired'**
  String get tvTimelineLast;

  /// No description provided for @tvNoNextEpisodeTitle.
  ///
  /// In en, this message translates to:
  /// **'No next episode'**
  String get tvNoNextEpisodeTitle;

  /// No description provided for @tvNoNextEpisodeUnknown.
  ///
  /// In en, this message translates to:
  /// **'No upcoming episode has been announced yet.'**
  String get tvNoNextEpisodeUnknown;

  /// No description provided for @tvNoNextEpisodeEnded.
  ///
  /// In en, this message translates to:
  /// **'This series has ended.'**
  String get tvNoNextEpisodeEnded;

  /// No description provided for @tvNoNextEpisodeCancelled.
  ///
  /// In en, this message translates to:
  /// **'This series was cancelled.'**
  String get tvNoNextEpisodeCancelled;

  /// D2b's episode card title, e.g. "S5 · E16 · Felina".
  ///
  /// In en, this message translates to:
  /// **'S{season} · E{episode} · {name}'**
  String tvEpisodeCodeAndName(int season, int episode, String name);

  /// D2b's episode card title for season 0 (TMDB's specials).
  ///
  /// In en, this message translates to:
  /// **'Specials · E{episode} · {name}'**
  String tvEpisodeCodeSpecialsAndName(int episode, String name);

  /// No description provided for @tvSeasonsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get tvSeasonsSectionTitle;

  /// D2's "Seasons" row and H4's own title, for season 0 specifically — shown instead of "Season 0".
  ///
  /// In en, this message translates to:
  /// **'Specials'**
  String get tvSpecialsLabel;

  /// The short tag on a season's poster in D2b's grid ("S1" / "T1"); the specials season uses tvSpecialsLabel instead.
  ///
  /// In en, this message translates to:
  /// **'S{number}'**
  String tvSeasonBadge(int number);

  /// D2's "Seasons" row and H4's own title, for any season other than 0 (see tvSpecialsLabel).
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String tvSeasonLabel(int number);

  /// H4's own episode row — number + title (docs/SCREENS.md H4).
  ///
  /// In en, this message translates to:
  /// **'{number}. {name}'**
  String tvEpisodeRowTitle(int number, String name);

  /// H4's episode row air date, for an episode with no air date yet ("To Be Announced").
  ///
  /// In en, this message translates to:
  /// **'TBA'**
  String get tvEpisodeTba;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// H3 (full cast) and H6 (region)'s own searchable-list empty state — deliberately distinct wording from exploreNoResults ("No results"), a different control with its own existing copy.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get commonNoMatches;

  /// H2's own "Save" button (docs/SCREENS.md H2).
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// H2's own heading for a TV show specifically (docs/SCREENS.md H2) — a movie uses mediaDetailMarkAsWatched instead.
  ///
  /// In en, this message translates to:
  /// **'Have you finished {title}?'**
  String mediaDetailHaveYouFinished(String title);

  /// H2's own heading for a movie (docs/SCREENS.md H2).
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get mediaDetailMarkAsWatched;

  /// No description provided for @mediaDetailDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mediaDetailDateLabel;

  /// Accessibility label of one of H2's five rating stars (e.g. "4 of 5").
  ///
  /// In en, this message translates to:
  /// **'{count} of 5'**
  String mediaDetailRatingStarLabel(int count);

  /// No description provided for @mediaDetailYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get mediaDetailYourRating;

  /// H2's own link, shown only when re-opening the sheet for an already-watched entry (docs/SCREENS.md H2).
  ///
  /// In en, this message translates to:
  /// **'Remove from Watched'**
  String get mediaDetailRemoveFromWatched;

  /// H6's own title (docs/SCREENS.md H6).
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionSheetTitle;

  /// No description provided for @regionSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sets which services you see in \"Where to watch\".'**
  String get regionSheetSubtitle;

  /// No description provided for @regionSheetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get regionSheetSearchHint;

  /// No description provided for @fullCastCastLabel.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get fullCastCastLabel;

  /// No description provided for @fullCastCrewLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get fullCastCrewLabel;

  /// No description provided for @fullCastSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cast and crew'**
  String get fullCastSearchHint;

  /// No description provided for @mediaSimilarMoviesTitle.
  ///
  /// In en, this message translates to:
  /// **'Similar movies'**
  String get mediaSimilarMoviesTitle;

  /// No description provided for @mediaSimilarTvTitle.
  ///
  /// In en, this message translates to:
  /// **'Similar TV shows'**
  String get mediaSimilarTvTitle;

  /// D1/D2's own "Similar" carousel header (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get mediaSimilarTitle;

  /// D3's heart button: saves the person to My List's People tab (it is a toggle: pressed means saved).
  ///
  /// In en, this message translates to:
  /// **'Save to My List'**
  String get personDetailSave;

  /// No description provided for @mediaDetailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get mediaDetailShare;

  /// No description provided for @mediaDetailShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share'**
  String get mediaDetailShareFailed;

  /// The small label under the number in D1/D2's rating ring: where the rating comes from (a brand name, the same in every language).
  ///
  /// In en, this message translates to:
  /// **'TMDB'**
  String get mediaDetailRatingSource;

  /// Accessibility label of D1/D2's rating ring.
  ///
  /// In en, this message translates to:
  /// **'Rating {value} out of 10'**
  String mediaDetailRatingSemantics(String value);

  /// D1/D2's primary action button when a trailer exists (docs/SCREENS.md D1) — mediaDetailActionSeeSimilar replaces it when there's no trailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get mediaDetailActionTrailer;

  /// No description provided for @mediaDetailActionSeeSimilar.
  ///
  /// In en, this message translates to:
  /// **'See similar'**
  String get mediaDetailActionSeeSimilar;

  /// D1/D2's own Favorite toggle (docs/SCREENS.md D1: "Favorite · Watch later · Watched"). The other two reuse myListTabWatchLater/myListTabWatched — same words, same meaning.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get mediaDetailActionFavorite;

  /// D1/D2's own section title (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'Where to watch'**
  String get whereToWatchTitle;

  /// No description provided for @whereToWatchTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a service to open it in JustWatch'**
  String get whereToWatchTapHint;

  /// D1/D2's Where to watch card when JustWatch has no service for the chosen country; the country pill above stays so the user can pick another.
  ///
  /// In en, this message translates to:
  /// **'Not available to stream, rent or buy in {region}. Try another country.'**
  String whereToWatchNoProviders(String region);

  /// Accessibility label of the country pill in Where to watch (opens the country picker).
  ///
  /// In en, this message translates to:
  /// **'Country: {region}. Change country'**
  String whereToWatchChangeRegion(String region);

  /// No description provided for @whereToWatchSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get whereToWatchSubscription;

  /// No description provided for @whereToWatchRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get whereToWatchRent;

  /// No description provided for @whereToWatchBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get whereToWatchBuy;

  /// D1/D2's mandatory footer (docs/SCREENS.md D1) — "JustWatch" stays untranslated in every locale, same as "TMDB"/"PakoTV".
  ///
  /// In en, this message translates to:
  /// **'Data from JustWatch'**
  String get whereToWatchJustWatchAttribution;

  /// D1/D2's own "+N" chip once a provider row exceeds its max shown (docs/SCREENS.md D1).
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String whereToWatchOverflowChip(int count);

  /// D3's header age line once PersonDetail.deathday is set (docs/SCREENS.md D3).
  ///
  /// In en, this message translates to:
  /// **'Lived {age} years'**
  String personAgeLivedYears(int age);

  /// D3's header age line while the person is still alive (docs/SCREENS.md D3).
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String personAgeYearsOld(int age);

  /// D3's own note shown above the biography when TMDB has no translation in the user's language.
  ///
  /// In en, this message translates to:
  /// **'Biography in English'**
  String get personBiographyInEnglish;

  /// D3's filmography year-group header for undated credits (docs/SCREENS.md D3) — FilmographyYearGroup.year is null for this group; domain never carries the label text itself (CLAUDE.md rule 15), only presentation maps null to this string.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get personFilmographyComingSoon;

  /// D3's own carousel header (docs/SCREENS.md D3).
  ///
  /// In en, this message translates to:
  /// **'Known for'**
  String get personKnownForTitle;

  /// No description provided for @personFilmographyLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'View full filmography'**
  String get personFilmographyLinkLabel;

  /// D3's filmography card: how many titles the full list has (e.g. "64 titles").
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 title} other{{count} titles}}'**
  String personFilmographyTitleCount(int count);

  /// D3's own section header (docs/SCREENS.md D3).
  ///
  /// In en, this message translates to:
  /// **'Filmography'**
  String get personFilmographyTitle;

  /// E2 step 4's own discreet toggle (docs/SCREENS.md E2) — deliberately its own key, not myListHideWatchedToggle ("Hide what I've watched"), since the two controls use different wording in the existing code.
  ///
  /// In en, this message translates to:
  /// **'Exclude what I\'ve already watched'**
  String get quizExcludeWatchedToggle;

  /// E2 step 1's headline, three parts so one word can be coloured (red): before + accent + after = "What are you NOT in the mood for today?".
  ///
  /// In en, this message translates to:
  /// **'What are you '**
  String get quizGenreHeadlineBefore;

  /// No description provided for @quizGenreHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'NOT'**
  String get quizGenreHeadlineAccent;

  /// No description provided for @quizGenreHeadlineAfter.
  ///
  /// In en, this message translates to:
  /// **' in the mood for today?'**
  String get quizGenreHeadlineAfter;

  /// No description provided for @quizGenreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skip up to 3 genres, or none'**
  String get quizGenreSubtitle;

  /// E2's final-step button, replacing commonNext (docs/SCREENS.md E2: "Final button 'Search'").
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get quizSearchButton;

  /// E2 step 1's headline, three parts so one word can be coloured (amber): before + accent + after = "Where should it come from?" — the collection (Turkish series, Anime, For kids…) the results come from.
  ///
  /// In en, this message translates to:
  /// **'Where should it '**
  String get quizCollectionHeadlineBefore;

  /// No description provided for @quizCollectionHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'come from'**
  String get quizCollectionHeadlineAccent;

  /// No description provided for @quizCollectionHeadlineAfter.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get quizCollectionHeadlineAfter;

  /// No description provided for @quizCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one, or skip to see everything'**
  String get quizCollectionSubtitle;

  /// No description provided for @quizCollectionGroupWorld.
  ///
  /// In en, this message translates to:
  /// **'From the world'**
  String get quizCollectionGroupWorld;

  /// No description provided for @quizCollectionGroupFormat.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get quizCollectionGroupFormat;

  /// No description provided for @quizCollectionGroupOccasion.
  ///
  /// In en, this message translates to:
  /// **'For everyone'**
  String get quizCollectionGroupOccasion;

  /// E2 step 2's headline, three parts so "vibes" can be coloured (amber): before + accent + after.
  ///
  /// In en, this message translates to:
  /// **'Which '**
  String get quizVibeHeadlineBefore;

  /// No description provided for @quizVibeHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'vibes'**
  String get quizVibeHeadlineAccent;

  /// No description provided for @quizVibeHeadlineAfter.
  ///
  /// In en, this message translates to:
  /// **' are you in the mood for today?'**
  String get quizVibeHeadlineAfter;

  /// No description provided for @quizVibeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up to 3 vibes, or none'**
  String get quizVibeSubtitle;

  /// E2 step 3's headline, three parts so "platforms" can be coloured: before + accent + after = "Which platforms shall we search?".
  ///
  /// In en, this message translates to:
  /// **'Which '**
  String get quizPlatformHeadlineBefore;

  /// No description provided for @quizPlatformHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'platforms'**
  String get quizPlatformHeadlineAccent;

  /// No description provided for @quizPlatformHeadlineAfter.
  ///
  /// In en, this message translates to:
  /// **' shall we search?'**
  String get quizPlatformHeadlineAfter;

  /// E2 step 3's switch, on while no service is picked: the search covers every streaming service of the user's region.
  ///
  /// In en, this message translates to:
  /// **'All platforms'**
  String get quizPlatformAll;

  /// No description provided for @quizPlatformRentBuy.
  ///
  /// In en, this message translates to:
  /// **'Include rent and buy'**
  String get quizPlatformRentBuy;

  /// No description provided for @quizPlatformNone.
  ///
  /// In en, this message translates to:
  /// **'No streaming services are listed for your region, so the search will not filter by platform.'**
  String get quizPlatformNone;

  /// E2 step 4's headline, three parts so "years" can be coloured: before + accent + after = "Which years?".
  ///
  /// In en, this message translates to:
  /// **'Which '**
  String get quizYearHeadlineBefore;

  /// No description provided for @quizYearHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get quizYearHeadlineAccent;

  /// No description provided for @quizYearHeadlineAfter.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get quizYearHeadlineAfter;

  /// No description provided for @quizYearSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a release range'**
  String get quizYearSubtitle;

  /// No description provided for @quizLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get quizLimitsTitle;

  /// No description provided for @quizMaxDuration.
  ///
  /// In en, this message translates to:
  /// **'Max duration'**
  String get quizMaxDuration;

  /// A whole number of hours, the max-duration slider's value ("2 h").
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String quizDurationHours(int hours);

  /// Hours and minutes, the max-duration slider's value ("2 h 30 min").
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String quizDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @quizStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get quizStatusLabel;

  /// No description provided for @quizStatusAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get quizStatusAny;

  /// No description provided for @quizStatusNotCanceled.
  ///
  /// In en, this message translates to:
  /// **'Not cancelled'**
  String get quizStatusNotCanceled;

  /// No description provided for @quizStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get quizStatusFinished;

  /// E2's "next step" button (the last step's is quizSearchButton).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quizContinueButton;

  /// E3's SurpriseError body — no exact copy is given in docs/SCREENS.md for this (E3 only describes the state, "error with 'Retry'"), so this is a plain, generic line.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a match. Try again.'**
  String get surpriseErrorMessage;

  /// E1's headline (docs/SCREENS.md E1), first part, in white. Followed by a space and chooseTypeHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'What are you in the mood for'**
  String get chooseTypeHeadlineLead;

  /// E1's headline, the word in the accent color; a white "?" follows it.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get chooseTypeHeadlineAccent;

  /// E3's SurpriseError title — distinct from surpriseErrorMessage (the body), even though the wording overlaps in English.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a match'**
  String get surpriseNoMatchTitle;

  /// No description provided for @chooseTypeMovieLabel.
  ///
  /// In en, this message translates to:
  /// **'A movie'**
  String get chooseTypeMovieLabel;

  /// No description provided for @chooseTypeTvShowLabel.
  ///
  /// In en, this message translates to:
  /// **'A TV show'**
  String get chooseTypeTvShowLabel;

  /// No description provided for @chooseTypeMovieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A plan for a couple of hours'**
  String get chooseTypeMovieSubtitle;

  /// No description provided for @chooseTypeTvShowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To get hooked over several nights'**
  String get chooseTypeTvShowSubtitle;

  /// A Surprise-me card's affinity tag: the engine's score scaled to 60-98 — a relative affinity, not a probability.
  ///
  /// In en, this message translates to:
  /// **'{percent} % for you'**
  String surpriseCardAffinity(int percent);

  /// A Surprise-me series card's season count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 season} other{{count} seasons}}'**
  String surpriseCardSeasons(int count);

  /// A series still airing: the year it started.
  ///
  /// In en, this message translates to:
  /// **'since {year}'**
  String surpriseCardSince(int year);

  /// How many services a Surprise-me card's title is on (shown when it is on three or fewer).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 platform} other{{count} platforms}}'**
  String surpriseCardPlatforms(int count);

  /// A Surprise-me card on more than three services: how many beyond the three logos shown.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String surpriseCardPlatformsMore(int count);

  /// A Surprise-me card's full label for a screen reader. {platforms} is empty or already starts with a comma.
  ///
  /// In en, this message translates to:
  /// **'Card {number} of {total}: {title}, {type}, {percent} % for you{platforms}'**
  String surpriseCardSemantics(
    int number,
    int total,
    String title,
    String type,
    int percent,
    String platforms,
  );

  /// A thumbnail of the Surprise-me strip, for a screen reader.
  ///
  /// In en, this message translates to:
  /// **'Card {number}'**
  String surpriseThumbnailLabel(int number);

  /// A thumbnail of a card that is in Watch later.
  ///
  /// In en, this message translates to:
  /// **'Card {number}, saved'**
  String surpriseThumbnailSaved(int number);

  /// No description provided for @surpriseRerollButton.
  ///
  /// In en, this message translates to:
  /// **'Ask for another 5'**
  String get surpriseRerollButton;

  /// The fixed button on a title's detail when it was opened from Surprise me's deck: does what the double tap does.
  ///
  /// In en, this message translates to:
  /// **'Choose this'**
  String get surpriseChooseThis;

  /// The label above the chosen card on Surprise me's closing screen; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'Your surprise of the day'**
  String get surpriseChosenLabel;

  /// No description provided for @surpriseChosenInWatchLater.
  ///
  /// In en, this message translates to:
  /// **'In Watch later'**
  String get surpriseChosenInWatchLater;

  /// No description provided for @surpriseNoticeWidened.
  ///
  /// In en, this message translates to:
  /// **'We widened the search a little to find these.'**
  String get surpriseNoticeWidened;

  /// No description provided for @surpriseNoticeNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more surprises with these answers.'**
  String get surpriseNoticeNoMore;

  /// No description provided for @surpriseNoticeOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — couldn\'t ask for more.'**
  String get surpriseNoticeOffline;

  /// E3a (Surprise me, searching): the headline under the shuffling cards.
  ///
  /// In en, this message translates to:
  /// **'Shuffling your 5 surprises'**
  String get surpriseShufflingTitle;

  /// No description provided for @surpriseShufflingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mixing what you like with what you don\'t expect'**
  String get surpriseShufflingSubtitle;

  /// E3's result card link (docs/SCREENS.md E3).
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get surpriseViewDetailsLink;

  /// No description provided for @surpriseSourceProfile.
  ///
  /// In en, this message translates to:
  /// **'Based on your tastes'**
  String get surpriseSourceProfile;

  /// No description provided for @surpriseAddToWatchLater.
  ///
  /// In en, this message translates to:
  /// **'Add to Watch later'**
  String get surpriseAddToWatchLater;

  /// E3's secondary button (docs/SCREENS.md E3: "Secondary button 'Another suggestion'").
  ///
  /// In en, this message translates to:
  /// **'Another suggestion'**
  String get surpriseAnotherSuggestion;

  /// H11's own headline (docs/SCREENS.md H11), shown above the subtitle naming where the suggestion would come from.
  ///
  /// In en, this message translates to:
  /// **'Find something to watch'**
  String get surpriseChooseSourceTitle;

  /// H11 subtitle naming the user's liked genres (up to 3).
  ///
  /// In en, this message translates to:
  /// **'Your tastes: {genres}.'**
  String surpriseSourceProfileGenres(String genres);

  /// Joins a list of genre names: 'Crime, Sci-Fi and Thriller'.
  ///
  /// In en, this message translates to:
  /// **'{rest} and {last}'**
  String surpriseGenresAnd(String rest, String last);

  /// No description provided for @surpriseQuizNote.
  ///
  /// In en, this message translates to:
  /// **'The quiz doesn\'t change your saved tastes.'**
  String get surpriseQuizNote;

  /// H11's primary button (docs/SCREENS.md H11) — launches Surprise me with the already-usable profile/inferred-list signal.
  ///
  /// In en, this message translates to:
  /// **'Use my tastes'**
  String get surpriseUseMyTastes;

  /// H11's secondary button, and E3's own link back to E2 for the profile/inferredList sources (docs/SCREENS.md H11, E3) — same copy, same action, two call sites.
  ///
  /// In en, this message translates to:
  /// **'Answer the quiz instead'**
  String get surpriseAnswerQuizInstead;

  /// B3's own title (docs/SCREENS.md B3) — "Match" is this app's own feature name, left untranslated in every locale, same class of exception as "PakoTV".
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchHubTitle;

  /// No description provided for @matchHubSurpriseMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get matchHubSurpriseMeTitle;

  /// No description provided for @matchHubSurpriseMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A suggestion just for you'**
  String get matchHubSurpriseMeSubtitle;

  /// B3's second card — "Match" stays untranslated, same reason as matchHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Match with friends'**
  String get matchHubWithFriendsTitle;

  /// No description provided for @matchHubWithFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decide together in seconds'**
  String get matchHubWithFriendsSubtitle;

  /// No description provided for @matchHubSoonPill.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get matchHubSoonPill;

  /// C6's own AppBar title (docs/SCREENS.md C6).
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferencesHeader.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesHeader;

  /// C6's own row label and H5's sheet title (docs/SCREENS.md C6/H5) — same word in both places.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// A language's own name in itself (its endonym) — deliberately identical in every locale's ARB file, the same convention every language picker uses (Spanish is always "Español", regardless of the app's current language).
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// Same convention as languageNameSpanish — deliberately identical in every locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @settingsDataHeader.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataHeader;

  /// No description provided for @settingsExportMyList.
  ///
  /// In en, this message translates to:
  /// **'Export My List'**
  String get settingsExportMyList;

  /// No description provided for @settingsDeleteMyListLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete My List'**
  String get settingsDeleteMyListLabel;

  /// C6's Data row that forgets every title Surprise me has shown (the local history that keeps it from repeating itself). "Surprise me" is the feature's name.
  ///
  /// In en, this message translates to:
  /// **'Delete Surprise me history'**
  String get settingsDeleteSurpriseHistoryLabel;

  /// No description provided for @settingsDeleteSurpriseHistoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your Surprise me history?'**
  String get settingsDeleteSurpriseHistoryDialogTitle;

  /// No description provided for @settingsSurpriseHistoryDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Surprise me history deleted'**
  String get settingsSurpriseHistoryDeletedSnackbar;

  /// No description provided for @settingsDeleteSurpriseHistoryFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the Surprise me history'**
  String get settingsDeleteSurpriseHistoryFailedSnackbar;

  /// No description provided for @settingsDeleteMyTastesLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete My Tastes'**
  String get settingsDeleteMyTastesLabel;

  /// No description provided for @settingsExportFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export My List'**
  String get settingsExportFailedSnackbar;

  /// No description provided for @settingsMyListDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'My List deleted'**
  String get settingsMyListDeletedSnackbar;

  /// No description provided for @settingsDeleteMyListFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete My List'**
  String get settingsDeleteMyListFailedSnackbar;

  /// No description provided for @settingsMyTastesDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'My Tastes deleted'**
  String get settingsMyTastesDeletedSnackbar;

  /// No description provided for @settingsDeleteMyTastesFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete My Tastes'**
  String get settingsDeleteMyTastesFailedSnackbar;

  /// No description provided for @settingsDeleteListDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your list?'**
  String get settingsDeleteListDialogTitle;

  /// No description provided for @settingsDeleteTastesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your tastes?'**
  String get settingsDeleteTastesDialogTitle;

  /// I1's own body (docs/SCREENS.md I1), shared by both the My List and My Tastes deletion dialogs. {itemsPhrase} is already a complete, pluralized phrase (e.g. "3 items"/"1 selection") from settingsDataDeleteItemCount or settingsDataDeleteSelectionCount — never a bare count — so this template has no noun of its own to agree in gender/number with across locales.
  ///
  /// In en, this message translates to:
  /// **'This will remove {itemsPhrase}. This can\'t be undone.'**
  String settingsDeleteDialogBody(String itemsPhrase);

  /// I1's own item-count phrase for the My Tastes deletion dialog — settingsDataDeleteItemCount's counterpart for "selection(s)" instead of "item(s)".
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selection} other{{count} selections}}'**
  String settingsDataDeleteSelectionCount(int count);

  /// I1's own destructive confirm button (docs/SCREENS.md I1: "Cancel / Delete (destructive)").
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @settingsBuildNumberCopiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Build number copied'**
  String get settingsBuildNumberCopiedSnackbar;

  /// No description provided for @settingsAboutHeader.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutHeader;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersionLabel;

  /// No description provided for @settingsSourceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingsSourceCodeLabel;

  /// No description provided for @settingsAttributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribution and credits'**
  String get settingsAttributionLabel;

  /// No description provided for @attributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attribution and credits'**
  String get attributionTitle;

  /// C7's TMDB card — TMDB's required attribution wording. "TMDB" stays untranslated in every locale.
  ///
  /// In en, this message translates to:
  /// **'This product uses the TMDB API but is not endorsed or certified by TMDB.'**
  String get attributionTmdbBody;

  /// No description provided for @attributionTmdbDetail.
  ///
  /// In en, this message translates to:
  /// **'Posters, images, synopses, cast and ratings.'**
  String get attributionTmdbDetail;

  /// C7's JustWatch card. "JustWatch" stays untranslated in every locale.
  ///
  /// In en, this message translates to:
  /// **'Streaming availability data is provided by JustWatch.'**
  String get attributionJustWatchBody;

  /// No description provided for @attributionJustWatchDetail.
  ///
  /// In en, this message translates to:
  /// **'Streaming, rent and buy options for your region.'**
  String get attributionJustWatchDetail;

  /// No description provided for @attributionFooter.
  ///
  /// In en, this message translates to:
  /// **'PakoTV is a free personal project. All trademarks belong to their respective owners.'**
  String get attributionFooter;

  /// No description provided for @settingsLicensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsLicensesLabel;

  /// H10's own title (docs/SCREENS.md H10).
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileSheetTitle;

  /// The visible Save control of Surprise me's deck (screen-reader users): puts the card on top in Watch later.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get surpriseControlSave;

  /// The visible Next control of Surprise me's deck: passes to the next card.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get surpriseControlNext;

  /// Screen-reader action on the deck's top card: turns it over to its back (or back to the front).
  ///
  /// In en, this message translates to:
  /// **'Flip card'**
  String get surpriseActionFlip;

  /// Step 1 of Surprise me's first-time tour: how to pass a card.
  ///
  /// In en, this message translates to:
  /// **'Swipe to pass a card'**
  String get surpriseTourSwipeTitle;

  /// No description provided for @surpriseTourSwipeBody.
  ///
  /// In en, this message translates to:
  /// **'Whichever way you like.'**
  String get surpriseTourSwipeBody;

  /// Step 2 of the tour: tapping the card turns it over.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to turn it over'**
  String get surpriseTourFlipTitle;

  /// No description provided for @surpriseTourFlipBody.
  ///
  /// In en, this message translates to:
  /// **'Find more details that help you decide.'**
  String get surpriseTourFlipBody;

  /// Step 3 of the tour: double-tapping chooses the card.
  ///
  /// In en, this message translates to:
  /// **'Double-tap to choose it'**
  String get surpriseTourChooseTitle;

  /// No description provided for @surpriseTourChooseBody.
  ///
  /// In en, this message translates to:
  /// **'If you already know which one you want, double-tap it and that\'s it.'**
  String get surpriseTourChooseBody;

  /// Tour button: leave the tour (counts as seen).
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get surpriseTourSkip;

  /// No description provided for @surpriseTourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get surpriseTourNext;

  /// No description provided for @surpriseTourBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get surpriseTourBack;

  /// Tour button on the last step: finish the tour.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get surpriseTourDone;

  /// Screen-reader label of the tour's progress dots.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String surpriseTourStep(int step, int total);

  /// No description provided for @statsSurpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get statsSurpriseTitle;

  /// No description provided for @statsSurpriseHitRateCaption.
  ///
  /// In en, this message translates to:
  /// **'of your sessions ended with a pick'**
  String get statsSurpriseHitRateCaption;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String statsSurpriseSessions(int count);

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pick} other{{count} picks}}'**
  String statsSurprisePicks(int count);

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session saved something but chose nothing} other{{count} sessions saved something but chose nothing}}'**
  String statsSurpriseSavedOnly(int count);

  /// No description provided for @statsSurpriseBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Which round you decide in'**
  String get statsSurpriseBatchTitle;

  /// No description provided for @statsSurpriseBatchFirst.
  ///
  /// In en, this message translates to:
  /// **'First five'**
  String get statsSurpriseBatchFirst;

  /// No description provided for @statsSurpriseBatchSecond.
  ///
  /// In en, this message translates to:
  /// **'Second five'**
  String get statsSurpriseBatchSecond;

  /// No description provided for @statsSurpriseBatchThird.
  ///
  /// In en, this message translates to:
  /// **'Third or later'**
  String get statsSurpriseBatchThird;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'On average you decide in round {average}'**
  String statsSurpriseBatchAverage(String average);

  /// No description provided for @statsSurpriseAfterTitle.
  ///
  /// In en, this message translates to:
  /// **'What happened to your picks'**
  String get statsSurpriseAfterTitle;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String statsSurpriseOfTotal(int count, int total);

  /// No description provided for @statsSurpriseWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get statsSurpriseWatched;

  /// No description provided for @statsSurpriseWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting in Watch later'**
  String get statsSurpriseWaiting;

  /// No description provided for @statsSurpriseAverageRating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get statsSurpriseAverageRating;

  /// No description provided for @statsSurpriseBestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your best picks'**
  String get statsSurpriseBestTitle;

  /// No description provided for @statsSurpriseNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New to you'**
  String get statsSurpriseNewTitle;

  /// No description provided for @statsSurpriseNewHint.
  ///
  /// In en, this message translates to:
  /// **'Picks with a genre you had not watched before'**
  String get statsSurpriseNewHint;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'New: {genres}'**
  String statsSurpriseNewGenres(String genres);

  /// No description provided for @statsSurpriseGenresTitle.
  ///
  /// In en, this message translates to:
  /// **'Your picks by genre'**
  String get statsSurpriseGenresTitle;

  /// No description provided for @statsSurpriseGenresHint.
  ///
  /// In en, this message translates to:
  /// **'Picked out of those shown'**
  String get statsSurpriseGenresHint;

  /// No description provided for @statsSurpriseAskedTitle.
  ///
  /// In en, this message translates to:
  /// **'What you ask for'**
  String get statsSurpriseAskedTitle;

  /// No description provided for @statsSurpriseCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get statsSurpriseCollections;

  /// No description provided for @statsSurpriseVibes.
  ///
  /// In en, this message translates to:
  /// **'Vibes'**
  String get statsSurpriseVibes;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'asked {asked}× · picked {picked}×'**
  String statsSurpriseAskedRow(int asked, int picked);

  /// No description provided for @statsSurpriseHowYouStart.
  ///
  /// In en, this message translates to:
  /// **'How you start'**
  String get statsSurpriseHowYouStart;

  /// No description provided for @statsSurpriseViaQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get statsSurpriseViaQuiz;

  /// No description provided for @statsSurpriseViaTastes.
  ///
  /// In en, this message translates to:
  /// **'My tastes'**
  String get statsSurpriseViaTastes;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{sessions} · {picks}'**
  String statsSurpriseViaRow(String sessions, String picks);

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session had to widen the search} other{{count} sessions had to widen the search}}'**
  String statsSurpriseRelaxed(int count);

  /// No description provided for @statsSurpriseRelaxLowerVotes.
  ///
  /// In en, this message translates to:
  /// **'fewer votes'**
  String get statsSurpriseRelaxLowerVotes;

  /// No description provided for @statsSurpriseRelaxDropVibes.
  ///
  /// In en, this message translates to:
  /// **'no vibes'**
  String get statsSurpriseRelaxDropVibes;

  /// No description provided for @statsSurpriseRelaxWidenYears.
  ///
  /// In en, this message translates to:
  /// **'earlier years'**
  String get statsSurpriseRelaxWidenYears;

  /// No description provided for @statsSurpriseHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rhythm'**
  String get statsSurpriseHabitTitle;

  /// No description provided for @statsSurpriseByMonth.
  ///
  /// In en, this message translates to:
  /// **'Sessions by month'**
  String get statsSurpriseByMonth;

  /// No description provided for @statsSurpriseByWeekday.
  ///
  /// In en, this message translates to:
  /// **'By day of the week'**
  String get statsSurpriseByWeekday;

  /// C4 Surprise-me statistics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week in a row} other{{count} weeks in a row}}'**
  String statsSurpriseStreak(int count);
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
