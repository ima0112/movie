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

  /// No description provided for @vibeFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get vibeFantasy;

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
  /// **'Offline'**
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

  /// B1's All tab: 'Because you like X' where X is one of the genres in the user's taste profile (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Because you like {genre}'**
  String carouselSectionBecauseYouLikeGenre(String genre);

  /// B1's All tab: 'Because you want X' where X is one of the vibes in the user's taste profile (docs/SCREENS.md B1).
  ///
  /// In en, this message translates to:
  /// **'Because you want {vibe}'**
  String carouselSectionBecauseYouWantVibe(String vibe);

  /// B1's "Because you like X" carousel header (docs/SCREENS.md B1) — X is RecommendationBuilder's own deterministic seed title, a real UserMediaEntry.title, never a genre.
  ///
  /// In en, this message translates to:
  /// **'Because you like {title}'**
  String carouselSectionBecauseYouLike(String title);

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

  /// No description provided for @libraryRowDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get libraryRowDateToday;

  /// No description provided for @libraryRowDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get libraryRowDateYesterday;

  /// LibraryRow's relative watched-date, for 2–6 days ago (docs/SCREENS.md B4's "short date"). This control's own switch never produces count == 1 (that's the separate libraryRowDateYesterday branch), so there's deliberately no ICU plural rule here — a locale is still free to inflect {count} itself however it needs within this one template.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String libraryRowDateDaysAgo(int count);

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

  /// MyTastesCard's summary line, second fragment (docs/SCREENS.md B5).
  ///
  /// In en, this message translates to:
  /// **'since {year}'**
  String myTastesSummarySinceYear(int year);

  /// MyTastesCard's summary line, third (optional) fragment (docs/SCREENS.md B5). {genreName} is that Genre's own localized display name.
  ///
  /// In en, this message translates to:
  /// **'never {genreName}'**
  String myTastesSummaryNeverGenre(String genreName);

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

  /// No description provided for @yourActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Activity'**
  String get yourActivityTitle;

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

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark something as watched to see your stats'**
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

  /// No description provided for @myTastesIntro.
  ///
  /// In en, this message translates to:
  /// **'The more we know, the better your recommendations and Surprise me. Everything is saved only on your device.'**
  String get myTastesIntro;

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
  /// **'Genres you never want'**
  String get myTastesGenresNeverTitle;

  /// No description provided for @myTastesSavedIndicator.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get myTastesSavedIndicator;

  /// No description provided for @myTastesVibesLikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibes you like'**
  String get myTastesVibesLikeTitle;

  /// No description provided for @myTastesHowFarBackLabel.
  ///
  /// In en, this message translates to:
  /// **'How far back'**
  String get myTastesHowFarBackLabel;

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

  /// No description provided for @tvEpisodesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get tvEpisodesSectionTitle;

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

  /// No description provided for @tvNextEpisodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Next episode'**
  String get tvNextEpisodeCaption;

  /// No description provided for @tvLastAiredEpisodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Last aired episode'**
  String get tvLastAiredEpisodeCaption;

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

  /// E2 step 1's own headline (docs/SCREENS.md E2).
  ///
  /// In en, this message translates to:
  /// **'Pick up to 3 you\'re NOT in the mood for'**
  String get quizGenreStepHeadline;

  /// E2 steps 1 and 2's own "N of M" counter under each headline (docs/SCREENS.md E2).
  ///
  /// In en, this message translates to:
  /// **'{selected} of {max}'**
  String quizSelectionCounter(int selected, int max);

  /// E2 step 4's own stepper label (docs/SCREENS.md E2) — reuses discoverRangeFiltersNoLimit for its "No limit" value.
  ///
  /// In en, this message translates to:
  /// **'Max seasons'**
  String get quizMaxSeasonsLabel;

  /// E2's final-step button, replacing commonNext (docs/SCREENS.md E2: "Final button 'Search'").
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get quizSearchButton;

  /// E2 step 2's own headline (docs/SCREENS.md E2).
  ///
  /// In en, this message translates to:
  /// **'Now pick 3 you ARE in the mood for'**
  String get quizVibeStepHeadline;

  /// E2 step 3's own headline (docs/SCREENS.md E2).
  ///
  /// In en, this message translates to:
  /// **'How far back do you want to go?'**
  String get quizYearStepHeadline;

  /// E3's SurpriseError body — no exact copy is given in docs/SCREENS.md for this (E3 only describes the state, "error with 'Retry'"), so this is a plain, generic line.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a match. Try again.'**
  String get surpriseErrorMessage;

  /// E1's own headline (docs/SCREENS.md E1).
  ///
  /// In en, this message translates to:
  /// **'What are you in the mood for today?'**
  String get chooseTypeHeadline;

  /// No description provided for @surpriseNoMoreSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'That\'s all for now'**
  String get surpriseNoMoreSuggestionsTitle;

  /// No description provided for @surpriseNoMoreSuggestionsBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re out of suggestions from this search — try again for a fresh pick.'**
  String get surpriseNoMoreSuggestionsBody;

  /// No description provided for @surpriseSearchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get surpriseSearchAgain;

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

  /// E3's own headline (docs/SCREENS.md E3), shown by both the searching and loaded states.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion'**
  String get surpriseYourSuggestionTitle;

  /// No description provided for @surpriseSearchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get surpriseSearchingLabel;

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

  /// No description provided for @surpriseSourceInferredList.
  ///
  /// In en, this message translates to:
  /// **'Based on your list'**
  String get surpriseSourceInferredList;

  /// E3's own subtitle per SurpriseResult.source (docs/SCREENS.md E3) — one line per SuggestionSource value, including the quiz now.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers'**
  String get surpriseSourceQuiz;

  /// No description provided for @surpriseRelaxedSearchNote.
  ///
  /// In en, this message translates to:
  /// **'We broadened the search a bit to find this match.'**
  String get surpriseRelaxedSearchNote;

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

  /// No description provided for @surpriseAddedToWatchLaterSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added to Watch later'**
  String get surpriseAddedToWatchLaterSnackbar;

  /// H11's own headline (docs/SCREENS.md H11), shown above the subtitle naming where the suggestion would come from.
  ///
  /// In en, this message translates to:
  /// **'Find something to watch'**
  String get surpriseChooseSourceTitle;

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
