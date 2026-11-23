// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get discoverSeeAll => 'Ver todo';

  @override
  String settingsAboutVersion(String version, String build) {
    return '$version ($build)';
  }

  @override
  String settingsDataDeleteItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get failureNetwork =>
      'Sin conexión — revisa tu internet e inténtalo de nuevo.';

  @override
  String get failureServer =>
      'Algo falló al conectar con el servidor. Inténtalo de nuevo en unos segundos.';

  @override
  String get failureNotFound => 'No hemos podido encontrar esto.';

  @override
  String get failureQuota =>
      'Demasiadas solicitudes — inténtalo de nuevo en un momento.';

  @override
  String get failureStorage =>
      'Algo salió mal al guardar esto en tu dispositivo.';

  @override
  String get failureUnknown => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get genreAction => 'Acción';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreAnimation => 'Animación';

  @override
  String get genreComedy => 'Comedia';

  @override
  String get genreCrime => 'Crimen';

  @override
  String get genreDocumentary => 'Documental';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreFamily => 'Familiar';

  @override
  String get genreFantasy => 'Fantasía';

  @override
  String get genreHistory => 'Historia';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genreMusic => 'Música';

  @override
  String get genreMystery => 'Misterio';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreSciFi => 'Ciencia ficción';

  @override
  String get genreThriller => 'Suspense';

  @override
  String get genreWar => 'Bélica';

  @override
  String get genreWestern => 'Oeste';

  @override
  String get genreActionAdventure => 'Acción y aventura';

  @override
  String get genreSciFiFantasy => 'Ciencia ficción y fantasía';

  @override
  String get genreWarPolitics => 'Bélica y política';

  @override
  String get vibeFeelGood => 'Para sentirse bien';

  @override
  String get vibeIndie => 'Indie';

  @override
  String get vibeMonster => 'Monstruos';

  @override
  String get vibeClassic => 'Clásico';

  @override
  String get vibeSuperhero => 'Superhéroes';

  @override
  String get vibeTearjerker => 'Lágrimas';

  @override
  String get vibeSports => 'Deportes';

  @override
  String get vibeDateNight => 'Noche romántica';

  @override
  String get vibeGritty => 'Crudo';

  @override
  String get vibeTrueStory => 'Historia real';

  @override
  String get vibeGangster => 'Gánsteres';

  @override
  String get vibeMusical => 'Musical';

  @override
  String get vibeTimeTravel => 'Viajes en el tiempo';

  @override
  String get vibeComingOfAge => 'Crecer';

  @override
  String get vibeDystopia => 'Distopía';

  @override
  String get vibeSurvival => 'Supervivencia';

  @override
  String get vibeRevenge => 'Venganza';

  @override
  String get vibeMartialArts => 'Artes marciales';

  @override
  String get vibeHeist => 'Atracos';

  @override
  String get tvStatusCardLabel => 'Estado';

  @override
  String get tvStatusAiring => 'En emisión';

  @override
  String get tvStatusEnded => 'Finalizada';

  @override
  String get tvStatusCancelled => 'Cancelada';

  @override
  String get mediaTypeMovieSingular => 'Película';

  @override
  String get mediaTypeTvShowSingular => 'Serie';

  @override
  String get mediaTypeMoviePlural => 'Películas';

  @override
  String get mediaTypeTvShowPlural => 'Series';

  @override
  String get mediaTypeTvTag => 'TV';

  @override
  String get mediaSegmentPeople => 'Personas';

  @override
  String get mediaSegmentAll => 'Todo';

  @override
  String get personFilmographyAsDirector => 'Como director';

  @override
  String get discoverSortPopularity => 'Popularidad';

  @override
  String get discoverSortRating => 'Valoración';

  @override
  String get discoverSortDate => 'Fecha';

  @override
  String get discoverSortTitle => 'Título';

  @override
  String get discoverSortVotes => 'Más votadas';

  @override
  String get myListTabFavorites => 'Favoritos';

  @override
  String get myListTabWatchLater => 'Ver después';

  @override
  String get myListTabWatched => 'Vistos';

  @override
  String get myListTabPeople => 'Personas';

  @override
  String get myListEmptyPeopleHeadline => 'Aún no hay personas';

  @override
  String get myListEmptyPeopleBody =>
      'Toca el corazón en la página de una persona para tenerla aquí.';

  @override
  String get myListActionMarkWatched => 'Marcar como vista';

  @override
  String get myListActionEditWatched => 'Editar valoración y fecha';

  @override
  String get myListActionAddFavorite => 'Añadir a favoritas';

  @override
  String get myListActionRemoveFavorite => 'Quitar de favoritas';

  @override
  String get myListActionAddWatchLater => 'Añadir a Ver después';

  @override
  String get myListActionRemoveWatchLater => 'Quitar de Ver después';

  @override
  String get myListActionRemoveWatched => 'Quitar de vistas';

  @override
  String get myListActionRemovePerson => 'Quitar de Personas';

  @override
  String get myListRowActionsLabel => 'Más acciones';

  @override
  String get swipeDelete => 'Borrar';

  @override
  String get swipeReleaseToDelete => 'Suelta para borrar';

  @override
  String libraryAddedToTab(String title, String tabName) {
    return '$title añadida a $tabName';
  }

  @override
  String libraryMarkedWatched(String title) {
    return '$title marcada como vista';
  }

  @override
  String libraryMarkedWatchedLeftWatchLater(String title) {
    return '$title marcada como vista · Quitada de Ver después';
  }

  @override
  String myListRemovedFromTab(String title, String tabName) {
    return '$title eliminada de $tabName';
  }

  @override
  String get myListEmptyFavoritesHeadline => 'Todavía no tienes favoritos';

  @override
  String get myListEmptyWatchLaterHeadline => 'Nada para ver después todavía';

  @override
  String get myListEmptyWatchedHeadline => 'Aún no has marcado nada como visto';

  @override
  String myListFallbackTitleMovie(int id) {
    return 'Película n.º $id';
  }

  @override
  String myListFallbackTitleTvShow(int id) {
    return 'Serie n.º $id';
  }

  @override
  String filteredListExcludeGenreChip(String genreName) {
    return 'Sin $genreName';
  }

  @override
  String get myListFilteredEmptyMovieTitle => 'No hay películas aquí';

  @override
  String get myListFilteredEmptyTvShowTitle => 'No hay series aquí';

  @override
  String get commonCouldntOpenLink => 'No se pudo abrir ese enlace';

  @override
  String get offlineStateTitle => 'Estás sin conexión';

  @override
  String get offlineStateBody =>
      'Para descubrir y buscar necesitas internet. Tu lista sigue disponible.';

  @override
  String get offlineGoToMyList => 'Ir a Mi lista';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get navTabDiscover => 'Descubrir';

  @override
  String get navTabExplore => 'Explorar';

  @override
  String get navTabMyList => 'Mi lista';

  @override
  String get navTabYou => 'Tú';

  @override
  String get navMatchButton => 'Sorpréndeme y emparejar';

  @override
  String get offlineBannerMessage => 'Sin conexión a internet';

  @override
  String get onboardingSaveError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get onboardingTastesSavedSnackbar =>
      'Gustos guardados · Edítalos en Tú';

  @override
  String get onboardingLikedEyebrow => 'Hazla tuya';

  @override
  String get onboardingLikedHeadline => '¿Qué te gusta?';

  @override
  String get onboardingLikedHighlight => 'gusta';

  @override
  String get onboardingLikedBody =>
      'Elige algunos géneros para personalizar Descubrir. Podrás afinar más en Tú › Mis gustos.';

  @override
  String get onboardingGenreStep3Headline => '¿Y cuáles nunca?';

  @override
  String get onboardingGenreStep3HighlightWord => 'nunca';

  @override
  String get onboardingVetoedBody =>
      'Elige los que prefieres no ver y los dejaremos fuera de tus recomendaciones.';

  @override
  String get onboardingVetoedCta => 'Empezar';

  @override
  String get onboardingNameHeadline => '¿Cómo te llamas?';

  @override
  String get onboardingNameEyebrow => 'Tu perfil';

  @override
  String get onboardingNameHighlight => 'llamas';

  @override
  String get onboardingNameContinue => 'Continuar';

  @override
  String get onboardingNameBody =>
      'Así te llamarás en la app, y así te verán los demás en las salas.';

  @override
  String get onboardingNameHint => 'Tu nombre';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profileColorLabel => 'Color';

  @override
  String get onboardingIntroDiscoverHeadline =>
      'Encuentra qué ver\nen segundos';

  @override
  String get onboardingIntroDiscoverHighlight => 'en segundos';

  @override
  String get onboardingIntroRatingLabel => 'valoración';

  @override
  String get onboardingIntroDiscoverBody =>
      'Explora el catálogo de TMDB. No es una app de streaming: te decimos dónde verlo.';

  @override
  String get onboardingIntroSurpriseHeadline => '¿Sin idea? Sorpréndeme';

  @override
  String get onboardingIntroSurpriseHighlight => 'Sorpréndeme';

  @override
  String get onboardingIntroSurpriseBody =>
      'Responde unas preguntas o usa tus gustos y te sugerimos qué ver.';

  @override
  String get onboardingWelcomeTagline => 'Encuentra qué ver';

  @override
  String get onboardingWelcomeGetStarted => 'Empezar';

  @override
  String get onboardingWelcomeTmdbAttribution => 'Datos de TMDB';

  @override
  String get commonCouldntLoad => 'No pudimos cargar';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClearAll => 'Borrar todo';

  @override
  String get commonGenres => 'Géneros';

  @override
  String get carouselSectionForYou => 'Para ti';

  @override
  String get carouselSectionPopularThisWeek => 'Popular esta semana';

  @override
  String carouselSectionBecauseYouLikeCollection(String collection) {
    return 'Porque te gusta $collection';
  }

  @override
  String carouselSectionBecauseYouLikeGenre(String genre) {
    return 'Porque te gusta $genre';
  }

  @override
  String carouselSectionBecauseYouLikeVibe(String vibe) {
    return 'Porque te gusta $vibe';
  }

  @override
  String carouselSectionBecauseYouLikePerson(String person) {
    return 'Porque te gusta $person';
  }

  @override
  String carouselSectionBecauseYouSaved(String title) {
    return 'Porque guardaste $title';
  }

  @override
  String get carouselSectionInTheaters => 'En cartelera';

  @override
  String get carouselSectionComingSoon => 'Próximamente';

  @override
  String get carouselSectionFinishedShows => 'Series finalizadas';

  @override
  String get carouselSectionLatestTrailers => 'Últimos tráilers';

  @override
  String get carouselSectionRecentlyViewed => 'Vistos recientemente';

  @override
  String get discoverTasteCardTitle => 'Recomendaciones a tu medida';

  @override
  String get discoverTasteCardEyebrow => 'Para ti';

  @override
  String get discoverTasteCardCta => 'Elegir mis gustos';

  @override
  String get sectionListingSortTitle => 'Ordenar por';

  @override
  String get sectionListingSortTooltip => 'Ordenar';

  @override
  String get sectionListingSortDefault => 'Orden predeterminado';

  @override
  String get sectionListingSortNewest => 'Más recientes primero';

  @override
  String get sectionListingAllGenres => 'Todos los géneros';

  @override
  String get sectionListingAllPlatforms => 'Todas las plataformas';

  @override
  String get sectionListingEmptyTitle => 'No hay nada que mostrar';

  @override
  String get sectionListingEmptyBody => 'Prueba con otro género o plataforma.';

  @override
  String get sectionListingLoadMoreFailed => 'No se pudo cargar más';

  @override
  String get releaseStatusInTheaters => 'En cines';

  @override
  String get releaseStatusComingSoon => 'Próximamente';

  @override
  String releaseStatusComingOn(String date) {
    return 'Estreno $date';
  }

  @override
  String get whereToWatchNotReleased =>
      'Aún no se ha estrenado, así que no está en ningún servicio.';

  @override
  String whereToWatchNotReleasedOn(String date) {
    return 'Aún no se ha estrenado. Sale el $date.';
  }

  @override
  String get whereToWatchInTheaters =>
      'En cines ahora y todavía no en ningún servicio.';

  @override
  String whereToWatchInTheatersStreamingOn(String date) {
    return 'En cines ahora. Se espera en plataformas el $date.';
  }

  @override
  String trailerPlayLabel(String title) {
    return 'Ver el tráiler de $title';
  }

  @override
  String get carouselSectionTrending => 'Tendencias';

  @override
  String get carouselSectionTopRated => 'Mejor valoradas';

  @override
  String get carouselSectionUpcoming => 'Próximamente';

  @override
  String get carouselSectionAiringNow => 'En emisión ahora';

  @override
  String get carouselSectionPopular => 'Populares';

  @override
  String get collectionTurkishSeries => 'Series turcas';

  @override
  String get collectionSpanishSeries => 'Series españolas';

  @override
  String get collectionLatinAmericanSeries => 'Series latinoamericanas';

  @override
  String get collectionKDramas => 'K-dramas';

  @override
  String get collectionBritishSeries => 'Series británicas';

  @override
  String get collectionSpanishCinema => 'Cine en español';

  @override
  String get collectionKoreanCinema => 'Cine coreano';

  @override
  String get collectionBollywood => 'Bollywood';

  @override
  String get collectionSoaps => 'Novelas';

  @override
  String get collectionAnime => 'Anime';

  @override
  String get collectionRealityShows => 'Realities';

  @override
  String get collectionKids => 'Para niños';

  @override
  String get exploreGenreLabel => 'Género';

  @override
  String get exploreGenreAll => 'Todos';

  @override
  String get explorePlatformLabel => 'Plataforma';

  @override
  String get explorePlatformAll => 'Todas';

  @override
  String get exploreSectionTopToday => 'Top de hoy';

  @override
  String get exploreSectionPopular => 'Popular';

  @override
  String get exploreSectionComingSoon => 'Próximamente';

  @override
  String get exploreSectionTopRatedSubtitle =>
      'Lo mejor de todos los tiempos, por nota';

  @override
  String get exploreSectionTopRated => 'Mejor valoradas';

  @override
  String get exploreSectionNewReleases => 'Estrenos';

  @override
  String get exploreSectionHiddenGems => 'Joyas ocultas';

  @override
  String get exploreBrowseEmptyTitle => 'Nada con estos filtros';

  @override
  String get exploreBrowseEmptyBody =>
      'Prueba con otro género u otra plataforma.';

  @override
  String get exploreNoResults => 'Sin resultados';

  @override
  String exploreNoResultsBody(String query) {
    return 'No encontramos nada para «$query». Prueba con otro título, serie o persona.';
  }

  @override
  String get exploreFilterTooltip => 'Filtros';

  @override
  String get exploreClearSearch => 'Limpiar búsqueda';

  @override
  String get exploreDefaultResultsTitle => 'Resultados';

  @override
  String get exploreSearchHint => 'Películas, series, personas';

  @override
  String exploreRecentRemove(String query) {
    return 'Quitar $query de las búsquedas recientes';
  }

  @override
  String get exploreRecentSearchesLabel => 'Recientes';

  @override
  String get explorePersonLabel => 'Persona';

  @override
  String explorePersonMetadata(String department) {
    return '$department · Persona';
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
    return 'Valoración $rating+';
  }

  @override
  String filteredListMaxRuntimeChip(int minutes) {
    return 'Menos de $minutes min';
  }

  @override
  String get filteredListEmptyTitle => 'Nada con esos filtros';

  @override
  String get filteredListClearFilters => 'Limpiar filtros';

  @override
  String get filteredListEmptyBody =>
      'Prueba con menos filtros o una nota mínima más baja.';

  @override
  String filteredListCountLine(int count, String sortLabel) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0 · $sortLabel';
  }

  @override
  String get filterSheetTitle => 'Filtros';

  @override
  String get filterSheetClear => 'Limpiar';

  @override
  String get filterSheetSectionStreaming => 'Streaming en';

  @override
  String get filterSheetSortPopular => 'Populares';

  @override
  String get filterSheetSortTopRated => 'Mejor valoradas';

  @override
  String get filterSheetSortNewest => 'Más recientes';

  @override
  String get filterSheetSortOldest => 'Más antiguas';

  @override
  String filterSheetMinRatingValue(String rating) {
    return '$rating o más';
  }

  @override
  String get filterSheetMinRatingAny => 'Cualquier nota';

  @override
  String get filterSheetNoResults => 'Sin resultados';

  @override
  String get filterSheetYearFrom => 'Desde el año';

  @override
  String get filterSheetYearTo => 'Hasta el año';

  @override
  String get filterSheetPresetComingSoon => 'Próximamente';

  @override
  String get filterSheetPresetInTheaters => 'En cines';

  @override
  String get filterSheetPresetFinished => 'Finalizadas';

  @override
  String get filterSheetPresetAiringNow => 'En emisión';

  @override
  String get filterSheetSectionLanguage => 'Idioma original';

  @override
  String get filterSheetLanguageAny => 'Cualquiera';

  @override
  String filterSheetRatingRangeValue(String min, String max) {
    return '$min – $max';
  }

  @override
  String filteredListRatingRangeChip(String min, String max) {
    return 'Nota $min–$max';
  }

  @override
  String get filterSheetSectionCollection => 'Colección';

  @override
  String get filterSheetSectionType => 'Tipo';

  @override
  String get filterSheetSectionYear => 'Años';

  @override
  String get filterSheetSectionMinRating => 'Nota mínima';

  @override
  String get filterSheetSectionRating => 'Nota';

  @override
  String get filterSheetSectionMaxRuntime => 'Duración máxima';

  @override
  String get filterSheetSectionStatus => 'Estado';

  @override
  String get filterSheetSectionSortBy => 'Ordenar por';

  @override
  String get filterSheetSeeResultsLoading => 'Ver resultados';

  @override
  String discoverRangeFiltersYearRange(int from, int to) {
    return '$from – $to';
  }

  @override
  String get discoverRangeFiltersNoLimit => 'Sin límite';

  @override
  String discoverRangeFiltersMinutes(int value) {
    return '$value min';
  }

  @override
  String get libraryRowAddedToday => 'Añadida hoy';

  @override
  String get libraryRowAddedYesterday => 'Añadida ayer';

  @override
  String libraryRowAddedDaysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String libraryRowAddedWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return 'Hace $_temp0';
  }

  @override
  String libraryRowAddedOn(String date) {
    return 'Añadida $date';
  }

  @override
  String get myListUndoAction => 'Deshacer';

  @override
  String get myListBodyOtherTabsNote =>
      'Explora para añadir películas y series aquí.';

  @override
  String get myListBodyEmptyFilterTitle => 'Nada coincide con tus filtros';

  @override
  String myListSeasonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temporadas',
      one: '1 temporada',
    );
    return '$_temp0';
  }

  @override
  String myListEpisodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
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
  String get myListSortTitleAz => 'Título A-Z';

  @override
  String get myListSortTmdbRating => 'Valoración de TMDB';

  @override
  String get myListSortMyRating => 'Mi valoración';

  @override
  String get myListSortDateWatched => 'Fecha de visionado';

  @override
  String get myListFilterSheetTitle => 'Ordenar y filtrar';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get myListHideWatchedToggle => 'Ocultar lo que he visto';

  @override
  String get myTastesTitle => 'Mis gustos';

  @override
  String myTastesSummaryVibeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vibes',
      one: '1 vibe',
    );
    return '$_temp0';
  }

  @override
  String get myTastesInvitationTitle => 'Crea tu perfil de gustos';

  @override
  String get myTastesInvitationBody =>
      'Recibe recomendaciones que de verdad encajen con lo que te gusta.';

  @override
  String get youHeaderGreetingNoProfile => 'Hola';

  @override
  String get youHeaderTapToSetName => 'Toca para poner tu nombre';

  @override
  String youHeaderGreetingWithName(String name) {
    return 'Hola, $name';
  }

  @override
  String youStatsDaysOfScreen(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '≈ $days días de pantalla',
      one: '≈ 1 día de pantalla',
    );
    return '$_temp0';
  }

  @override
  String youStatsStreak(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semanas',
      one: '1 semana',
    );
    return 'Racha de $_temp0';
  }

  @override
  String youStatsThisMonth(int count) {
    return '$count este mes';
  }

  @override
  String get youStatsSurpriseTitle => 'Sorpréndeme';

  @override
  String get youStatsSurpriseSessions => 'Sesiones';

  @override
  String get youStatsSurprisePicks => 'Elecciones';

  @override
  String get youStatsLast12Months => 'Últimos 12 meses';

  @override
  String youStatsMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas',
      one: '1 película',
    );
    return '$_temp0';
  }

  @override
  String youStatsShows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String get viewerNewcomer => 'Recién llegado';

  @override
  String get viewerSeriesBinger => 'Maratonista de series';

  @override
  String get viewerExigentCritic => 'Crítico exigente';

  @override
  String get viewerEnthusiast => 'Espectador entusiasta';

  @override
  String viewerGenreFan(String genre) {
    return 'Fan de $genre';
  }

  @override
  String get viewerCinephile => 'Cinéfilo';

  @override
  String get viewerExplorer => 'De todo un poco';

  @override
  String get youRecentlyWatchedTitle => 'Vistas recientemente';

  @override
  String myTastesRowGenresMore(String names, int count) {
    return '$names +$count';
  }

  @override
  String get myTastesRowFallback => 'Géneros, vibes, plataformas y más';

  @override
  String get yourActivityHoursLabel => 'Horas';

  @override
  String get yourActivitySeeStats => 'Ver estadísticas';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsActivityStripTitle => 'Actividad de los últimos 12 meses';

  @override
  String get statsPeriodAllTime => 'Todo';

  @override
  String get statsPeriodThisYear => 'Este año';

  @override
  String get statsPeriodThisMonth => 'Este mes';

  @override
  String statsTitlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count títulos',
      one: '1 título',
    );
    return '$_temp0';
  }

  @override
  String get statsVsLastMonth => 'vs mes pasado';

  @override
  String get statsVsLastYear => 'vs año pasado';

  @override
  String statsDelta(String delta, String previous) {
    return '$delta $previous';
  }

  @override
  String get statsEmptyPeriodTitle => 'Nada visto en este periodo';

  @override
  String get statsEmptyPeriodBody =>
      'Prueba otro periodo o marca algo como visto.';

  @override
  String get statsHighlightsTitle => 'Destacados';

  @override
  String get statsBusiestMonth => 'Mes más activo';

  @override
  String get statsStreak => 'Racha';

  @override
  String get statsNoStreak => 'Sin racha ahora';

  @override
  String statsWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String statsBestStreak(String weeks) {
    return 'Mejor: $weeks';
  }

  @override
  String get statsLongestMovie => 'Película más larga';

  @override
  String get statsLongestShow => 'Serie más larga';

  @override
  String get statsBestRated => 'Tu mejor valorada';

  @override
  String statsStarsOfFive(int stars) {
    return '★ $stars de 5';
  }

  @override
  String get statsBacklog => 'Ver después';

  @override
  String statsBacklogHours(String hours) {
    return '≈ $hours por ver';
  }

  @override
  String get statsActivityTitle => 'Actividad';

  @override
  String get statsActivityLess => 'Menos';

  @override
  String get statsActivityMore => 'Más';

  @override
  String get statsRatingsTitle => 'Tus valoraciones';

  @override
  String statsRatingAverage(String value) {
    return '$value de promedio';
  }

  @override
  String statsRatingTmdb(String value) {
    return 'TMDB: $value';
  }

  @override
  String statsRatingHigher(String gap) {
    return 'Valoras $gap ★ por encima de TMDB en promedio';
  }

  @override
  String statsRatingLower(String gap) {
    return 'Valoras $gap ★ por debajo de TMDB en promedio';
  }

  @override
  String get statsRatingInLine => 'Valoras en línea con TMDB';

  @override
  String get statsDisagreementsTitle => 'Dónde difieres de TMDB';

  @override
  String statsDisagreement(String user, String tmdb) {
    return 'Tú ★ $user · TMDB ★ $tmdb';
  }

  @override
  String statsGenresShowAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get statsGenresShowLess => 'Ver menos';

  @override
  String statsGenrePercent(int percent) {
    return '$percent%';
  }

  @override
  String get statsDecadesTitle => 'Por década';

  @override
  String statsDecadeLabel(int decade) {
    return '${decade}s';
  }

  @override
  String statsCoverage(int complete, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total títulos',
      one: '1 título',
    );
    return 'Calculado sobre $complete de $_temp0 con datos completos.';
  }

  @override
  String get statsEmptyTitle =>
      'Marca algo como visto o prueba Sorpréndeme para ver tus estadísticas';

  @override
  String get statsEmptyBody =>
      'Tus números aparecerán aquí en cuanto lo hagas.';

  @override
  String get statsGenreBarsTitle => 'Géneros que más ves';

  @override
  String get statsMoviesWatchedLabel => 'Películas vistas';

  @override
  String get statsHoursOfMoviesLabel => 'Horas de películas';

  @override
  String get statsTvShowsWatchedLabel => 'Series vistas';

  @override
  String get statsEstimatedTvHoursLabel => 'Horas estimadas de series';

  @override
  String get myTastesCollectionsTitle => 'Colecciones que te gustan';

  @override
  String get myTastesCollectionsHint =>
      'Series de un país, anime, novelas… los lugares y formatos a los que vuelves.';

  @override
  String get myTastesVibesTitle => 'Vibes favoritas';

  @override
  String myTastesVibesHint(int max) {
    return 'Hasta $max. Marcan el tono de lo que te sugerimos.';
  }

  @override
  String get releaseRangeFrom => 'Desde';

  @override
  String get releaseRangeTo => 'Hasta';

  @override
  String get releaseRangeToday => 'Hoy';

  @override
  String get releaseRangeAll => 'Todos';

  @override
  String get releaseRange2020s => '2020s';

  @override
  String get releaseRange2010s => '2010s';

  @override
  String get releaseRange2000s => '2000s';

  @override
  String get releaseRangeEarlier => 'Anteriores';

  @override
  String get myTastesErasTitle => 'Épocas';

  @override
  String get myTastesErasHint => 'Elige un rango de estreno';

  @override
  String get myTastesPlatformsAdd => 'Añadir';

  @override
  String get myTastesPlatformsSheetTitle => 'Añadir plataformas';

  @override
  String get myTastesPlatformsSearchHint => 'Buscar plataformas';

  @override
  String myTastesPlatformRemove(String name) {
    return 'Quitar $name';
  }

  @override
  String get myTastesPlatformsTitle => 'Mis plataformas';

  @override
  String get myTastesPlatformsHint =>
      'Priorizamos lo que puedes ver ya en tu región.';

  @override
  String get myTastesGenresLikeHint => 'Elige los que quieras.';

  @override
  String get myTastesGenresNeverHint => 'No los mostramos en recomendaciones.';

  @override
  String get myTastesGenresLikeTitle => 'Géneros que me gustan';

  @override
  String get myTastesGenresNeverTitle => 'Géneros que evito';

  @override
  String get myTastesSavedIndicator => 'Guardado';

  @override
  String statsHoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get mediaDetailDuration => 'Duración';

  @override
  String get mediaDetailClassification => 'Clasificación';

  @override
  String get mediaDetailSynopsis => 'Sinopsis';

  @override
  String get commonReadLess => 'Leer menos';

  @override
  String get commonReadMore => 'Leer más';

  @override
  String tvEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
    );
    return '$_temp0';
  }

  @override
  String get mediaCreatedByLabel => 'Creada por ';

  @override
  String get mediaDirectedByLabel => 'Dirigida por ';

  @override
  String tvEpisodeCode(int season, int episode) {
    return 'T$season · E$episode';
  }

  @override
  String tvEpisodeCodeSpecials(int episode) {
    return 'Especiales · E$episode';
  }

  @override
  String get tvEpisodePrevious => 'Anterior';

  @override
  String tvEpisodePreviousWithCode(int episode) {
    return 'Anterior · E$episode';
  }

  @override
  String get tvEpisodeNext => 'Siguiente';

  @override
  String tvEpisodeNextWithCode(int episode) {
    return 'Siguiente · E$episode';
  }

  @override
  String get tvEpisodeGuestStars => 'Estrellas invitadas';

  @override
  String get tvSeasonsLinkLabel => 'Temporadas';

  @override
  String tvSeasonsLinkValue(int seasons, int episodes) {
    String _temp0 = intl.Intl.pluralLogic(
      episodes,
      locale: localeName,
      other: '$episodes episodios',
      one: '1 episodio',
    );
    return '$seasons · $_temp0';
  }

  @override
  String get tvTimelineNext => 'Próximo';

  @override
  String get tvTimelineLast => 'Último emitido';

  @override
  String get tvNoNextEpisodeTitle => 'Sin próximo episodio';

  @override
  String get tvNoNextEpisodeUnknown =>
      'Aún no se ha anunciado ningún episodio próximo.';

  @override
  String get tvNoNextEpisodeEnded => 'Esta serie ya terminó.';

  @override
  String get tvNoNextEpisodeCancelled => 'Esta serie fue cancelada.';

  @override
  String tvEpisodeCodeAndName(int season, int episode, String name) {
    return 'T$season · E$episode · $name';
  }

  @override
  String tvEpisodeCodeSpecialsAndName(int episode, String name) {
    return 'Especiales · E$episode · $name';
  }

  @override
  String get tvSeasonsSectionTitle => 'Temporadas';

  @override
  String get tvSpecialsLabel => 'Especiales';

  @override
  String tvSeasonBadge(int number) {
    return 'T$number';
  }

  @override
  String tvSeasonLabel(int number) {
    return 'Temporada $number';
  }

  @override
  String tvEpisodeRowTitle(int number, String name) {
    return '$number. $name';
  }

  @override
  String get tvEpisodeTba => 'Por confirmar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonNoMatches => 'Sin coincidencias';

  @override
  String get commonSave => 'Guardar';

  @override
  String mediaDetailHaveYouFinished(String title) {
    return '¿Has terminado $title?';
  }

  @override
  String get mediaDetailMarkAsWatched => 'Marcar como visto';

  @override
  String get mediaDetailDateLabel => 'Fecha';

  @override
  String mediaDetailRatingStarLabel(int count) {
    return '$count de 5';
  }

  @override
  String get mediaDetailYourRating => 'Tu valoración';

  @override
  String get mediaDetailRemoveFromWatched => 'Quitar de Vistos';

  @override
  String get regionSheetTitle => 'Región';

  @override
  String get regionSheetSubtitle =>
      'Define qué plataformas ves en \"Dónde ver\".';

  @override
  String get regionSheetSearchHint => 'Buscar países';

  @override
  String get fullCastCastLabel => 'Reparto';

  @override
  String get fullCastCrewLabel => 'Equipo';

  @override
  String get fullCastSearchHint => 'Buscar en reparto y equipo';

  @override
  String get mediaSimilarMoviesTitle => 'Películas similares';

  @override
  String get mediaSimilarTvTitle => 'Series similares';

  @override
  String get mediaSimilarTitle => 'Similares';

  @override
  String get personDetailSave => 'Guardar en Mi lista';

  @override
  String get mediaDetailShare => 'Compartir';

  @override
  String get mediaDetailShareFailed => 'No se pudo compartir';

  @override
  String get mediaDetailRatingSource => 'TMDB';

  @override
  String mediaDetailRatingSemantics(String value) {
    return 'Valoración $value de 10';
  }

  @override
  String get mediaDetailActionTrailer => 'Tráiler';

  @override
  String get mediaDetailActionSeeSimilar => 'Ver similares';

  @override
  String get mediaDetailActionFavorite => 'Favorito';

  @override
  String get whereToWatchTitle => 'Dónde ver';

  @override
  String get whereToWatchTapHint =>
      'Toca un servicio para abrirlo en JustWatch';

  @override
  String whereToWatchNoProviders(String region) {
    return 'No disponible para ver, alquilar o comprar en $region. Prueba con otro país.';
  }

  @override
  String whereToWatchChangeRegion(String region) {
    return 'País: $region. Cambiar país';
  }

  @override
  String get whereToWatchSubscription => 'Suscripción';

  @override
  String get whereToWatchRent => 'Alquiler';

  @override
  String get whereToWatchBuy => 'Compra';

  @override
  String get whereToWatchJustWatchAttribution => 'Datos de JustWatch';

  @override
  String whereToWatchOverflowChip(int count) {
    return '+$count';
  }

  @override
  String personAgeLivedYears(int age) {
    return 'Vivió $age años';
  }

  @override
  String personAgeYearsOld(int age) {
    return '$age años';
  }

  @override
  String get personBiographyInEnglish => 'Biografía en inglés';

  @override
  String get personFilmographyComingSoon => 'Próximamente';

  @override
  String get personKnownForTitle => 'Conocido por';

  @override
  String get personFilmographyLinkLabel => 'Ver filmografía completa';

  @override
  String personFilmographyTitleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count títulos',
      one: '1 título',
    );
    return '$_temp0';
  }

  @override
  String get personFilmographyTitle => 'Filmografía';

  @override
  String get quizExcludeWatchedToggle => 'Excluir lo que ya vi';

  @override
  String get quizGenreHeadlineBefore => '¿Qué ';

  @override
  String get quizGenreHeadlineAccent => 'NO';

  @override
  String get quizGenreHeadlineAfter => ' te apetece hoy?';

  @override
  String get quizGenreSubtitle => 'Descarta hasta 3 géneros, o ninguno';

  @override
  String get quizSearchButton => 'Buscar';

  @override
  String get quizCollectionHeadlineBefore => '¿De dónde la ';

  @override
  String get quizCollectionHeadlineAccent => 'quieres';

  @override
  String get quizCollectionHeadlineAfter => '?';

  @override
  String get quizCollectionSubtitle => 'Elige una, o sáltalo para verlo todo';

  @override
  String get quizCollectionGroupWorld => 'Del mundo';

  @override
  String get quizCollectionGroupFormat => 'Formatos';

  @override
  String get quizCollectionGroupOccasion => 'Para quién';

  @override
  String get quizVibeHeadlineBefore => '¿Qué ';

  @override
  String get quizVibeHeadlineAccent => 'vibes';

  @override
  String get quizVibeHeadlineAfter => ' te apetecen hoy?';

  @override
  String get quizVibeSubtitle => 'Elige hasta 3 vibes, o ninguna';

  @override
  String get quizPlatformHeadlineBefore => '¿En qué ';

  @override
  String get quizPlatformHeadlineAccent => 'plataformas';

  @override
  String get quizPlatformHeadlineAfter => ' buscamos?';

  @override
  String get quizPlatformAll => 'Todas las plataformas';

  @override
  String get quizPlatformRentBuy => 'Incluir alquiler y compra';

  @override
  String get quizPlatformNone =>
      'No hay plataformas de streaming listadas para tu región, así que la búsqueda no filtrará por plataforma.';

  @override
  String get quizYearHeadlineBefore => '¿De qué ';

  @override
  String get quizYearHeadlineAccent => 'años';

  @override
  String get quizYearHeadlineAfter => '?';

  @override
  String get quizYearSubtitle => 'Elige un rango de estreno';

  @override
  String get quizLimitsTitle => 'Límites';

  @override
  String get quizMaxDuration => 'Duración máxima';

  @override
  String quizDurationHours(int hours) {
    return '$hours h';
  }

  @override
  String quizDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get quizStatusLabel => 'Estado';

  @override
  String get quizStatusAny => 'Cualquiera';

  @override
  String get quizStatusNotCanceled => 'No canceladas';

  @override
  String get quizStatusFinished => 'Finalizada';

  @override
  String get quizContinueButton => 'Continuar';

  @override
  String get surpriseErrorMessage =>
      'No hemos encontrado nada. Inténtalo de nuevo.';

  @override
  String get chooseTypeHeadlineLead => '¿Qué te apetece ver';

  @override
  String get chooseTypeHeadlineAccent => 'hoy';

  @override
  String get surpriseNoMatchTitle => 'No hemos encontrado nada';

  @override
  String get chooseTypeMovieLabel => 'Una película';

  @override
  String get chooseTypeTvShowLabel => 'Una serie';

  @override
  String get chooseTypeMovieSubtitle => 'Un plan de un par de horas';

  @override
  String get chooseTypeTvShowSubtitle => 'Para engancharte varias noches';

  @override
  String surpriseCardAffinity(int percent) {
    return '$percent % para ti';
  }

  @override
  String surpriseCardSeasons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temporadas',
      one: '1 temporada',
    );
    return '$_temp0';
  }

  @override
  String surpriseCardSince(int year) {
    return 'desde $year';
  }

  @override
  String surpriseCardPlatforms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plataformas',
      one: '1 plataforma',
    );
    return '$_temp0';
  }

  @override
  String surpriseCardPlatformsMore(int count) {
    return '+$count';
  }

  @override
  String surpriseCardSemantics(
    int number,
    int total,
    String title,
    String type,
    int percent,
    String platforms,
  ) {
    return 'Carta $number de $total: $title, $type, $percent % para ti$platforms';
  }

  @override
  String surpriseThumbnailLabel(int number) {
    return 'Carta $number';
  }

  @override
  String surpriseThumbnailSaved(int number) {
    return 'Carta $number, guardada';
  }

  @override
  String get surpriseRerollButton => 'Volver a pedir otras 5';

  @override
  String get surpriseChooseThis => 'Elegir esta';

  @override
  String get surpriseChosenLabel => 'Tu sorpresa de hoy';

  @override
  String get surpriseChosenInWatchLater => 'En Ver después';

  @override
  String get surpriseNoticeWidened =>
      'Ampliamos un poco la búsqueda para encontrar estas.';

  @override
  String get surpriseNoticeNoMore =>
      'No hay más sorpresas con estas respuestas.';

  @override
  String get surpriseNoticeOffline => 'Sin conexión: no se pudo pedir más.';

  @override
  String get surpriseShufflingTitle => 'Barajando tus 5 sorpresas';

  @override
  String get surpriseShufflingSubtitle =>
      'Mezclando lo que te gusta con lo que no esperas';

  @override
  String get surpriseViewDetailsLink => 'Ver detalles';

  @override
  String get surpriseSourceProfile => 'Según tus gustos';

  @override
  String get surpriseAddToWatchLater => 'Añadir a ver después';

  @override
  String get surpriseAnotherSuggestion => 'Otra sugerencia';

  @override
  String get surpriseChooseSourceTitle => 'Encuentra algo para ver';

  @override
  String surpriseSourceProfileGenres(String genres) {
    return 'Tus gustos: $genres.';
  }

  @override
  String surpriseGenresAnd(String rest, String last) {
    return '$rest y $last';
  }

  @override
  String get surpriseQuizNote =>
      'El cuestionario no cambia tus gustos guardados.';

  @override
  String get surpriseUseMyTastes => 'Usar mis gustos';

  @override
  String get surpriseAnswerQuizInstead => 'Responder el cuestionario';

  @override
  String get matchHubTitle => 'Match';

  @override
  String get matchHubSurpriseMeTitle => 'Sorpréndeme';

  @override
  String get matchHubSurpriseMeSubtitle => 'Una sugerencia solo para ti';

  @override
  String get matchHubWithFriendsTitle => 'Match con amigos';

  @override
  String get matchHubWithFriendsSubtitle => 'Decide con amigos en segundos';

  @override
  String get matchHubSoonPill => 'Pronto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPreferencesHeader => 'Preferencias';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get settingsDataHeader => 'Datos';

  @override
  String get settingsExportMyList => 'Exportar mi lista';

  @override
  String get settingsDeleteMyListLabel => 'Eliminar mi lista';

  @override
  String get settingsDeleteSurpriseHistoryLabel =>
      'Eliminar historial de Sorpréndeme';

  @override
  String get settingsDeleteSurpriseHistoryDialogTitle =>
      '¿Eliminar tu historial de Sorpréndeme?';

  @override
  String get settingsSurpriseHistoryDeletedSnackbar =>
      'Historial de Sorpréndeme eliminado';

  @override
  String get settingsDeleteSurpriseHistoryFailedSnackbar =>
      'No se pudo eliminar el historial de Sorpréndeme';

  @override
  String get settingsDeleteMyTastesLabel => 'Eliminar mis gustos';

  @override
  String get settingsExportFailedSnackbar => 'No se pudo exportar tu lista';

  @override
  String get settingsMyListDeletedSnackbar => 'Lista eliminada';

  @override
  String get settingsDeleteMyListFailedSnackbar =>
      'No se pudo eliminar tu lista';

  @override
  String get settingsMyTastesDeletedSnackbar => 'Gustos eliminados';

  @override
  String get settingsDeleteMyTastesFailedSnackbar =>
      'No se pudieron eliminar tus gustos';

  @override
  String get settingsDeleteListDialogTitle => '¿Eliminar tu lista?';

  @override
  String get settingsDeleteTastesDialogTitle => '¿Eliminar tus gustos?';

  @override
  String settingsDeleteDialogBody(String itemsPhrase) {
    return 'Se eliminarán $itemsPhrase. No podrás deshacerlo.';
  }

  @override
  String settingsDataDeleteSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecciones',
      one: '1 selección',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get settingsBuildNumberCopiedSnackbar =>
      'Número de compilación copiado';

  @override
  String get settingsAboutHeader => 'Acerca de';

  @override
  String get settingsVersionLabel => 'Versión';

  @override
  String get settingsSourceCodeLabel => 'Código fuente';

  @override
  String get settingsAttributionLabel => 'Atribución y créditos';

  @override
  String get attributionTitle => 'Atribución y créditos';

  @override
  String get attributionTmdbBody =>
      'Este producto usa la API de TMDB, pero no está avalado ni certificado por TMDB.';

  @override
  String get attributionTmdbDetail =>
      'Pósters, imágenes, sinopsis, reparto y valoraciones.';

  @override
  String get attributionJustWatchBody =>
      'Los datos de disponibilidad en plataformas los proporciona JustWatch.';

  @override
  String get attributionJustWatchDetail =>
      'Streaming, alquiler y compra según tu región.';

  @override
  String get attributionFooter =>
      'PakoTV es un proyecto personal gratuito. Todas las marcas pertenecen a sus respectivos dueños.';

  @override
  String get settingsLicensesLabel => 'Licencias';

  @override
  String get editProfileSheetTitle => 'Editar perfil';

  @override
  String get surpriseControlSave => 'Guardar';

  @override
  String get surpriseControlNext => 'Siguiente';

  @override
  String get surpriseActionFlip => 'Voltear carta';

  @override
  String get surpriseTourSwipeTitle => 'Desliza para pasar de carta';

  @override
  String get surpriseTourSwipeBody => 'Hacia el lado que quieras.';

  @override
  String get surpriseTourFlipTitle => 'Toca la carta para darle la vuelta';

  @override
  String get surpriseTourFlipBody =>
      'Descubre más detalles que te ayudan a decidir.';

  @override
  String get surpriseTourChooseTitle => 'Toca dos veces para elegirla';

  @override
  String get surpriseTourChooseBody =>
      'Si ya sabes cuál quieres, dale dos toques y listo.';

  @override
  String get surpriseTourSkip => 'Omitir';

  @override
  String get surpriseTourNext => 'Siguiente';

  @override
  String get surpriseTourBack => 'Atrás';

  @override
  String get surpriseTourDone => 'Entendido';

  @override
  String surpriseTourStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get statsSurpriseTitle => 'Sorpréndeme';

  @override
  String get statsSurpriseHitRateCaption =>
      'de tus sesiones terminaron con una elección';

  @override
  String statsSurpriseSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
    );
    return '$_temp0';
  }

  @override
  String statsSurprisePicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elecciones',
      one: '1 elección',
    );
    return '$_temp0';
  }

  @override
  String statsSurpriseSavedOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones guardaron algo pero no eligieron nada',
      one: '1 sesión guardó algo pero no eligió nada',
    );
    return '$_temp0';
  }

  @override
  String get statsSurpriseBatchTitle => 'En qué tanda decides';

  @override
  String get statsSurpriseBatchFirst => 'Las primeras 5';

  @override
  String get statsSurpriseBatchSecond => 'Las segundas 5';

  @override
  String get statsSurpriseBatchThird => 'Tercera o más';

  @override
  String statsSurpriseBatchAverage(String average) {
    return 'De media decides en la tanda $average';
  }

  @override
  String get statsSurpriseAfterTitle => 'Qué pasó con lo que elegiste';

  @override
  String statsSurpriseOfTotal(int count, int total) {
    return '$count de $total';
  }

  @override
  String get statsSurpriseWatched => 'Vistas';

  @override
  String get statsSurpriseWaiting => 'Esperando en Ver después';

  @override
  String get statsSurpriseAverageRating => 'Nota media';

  @override
  String get statsSurpriseBestTitle => 'Tus mejores elecciones';

  @override
  String get statsSurpriseNewTitle => 'Novedades para ti';

  @override
  String get statsSurpriseNewHint =>
      'Elecciones con un género que no habías visto antes';

  @override
  String statsSurpriseNewGenres(String genres) {
    return 'Nuevo: $genres';
  }

  @override
  String get statsSurpriseGenresTitle => 'Tus elecciones por género';

  @override
  String get statsSurpriseGenresHint => 'Elegidas de las mostradas';

  @override
  String get statsSurpriseAskedTitle => 'Lo que pides';

  @override
  String get statsSurpriseCollections => 'Colecciones';

  @override
  String get statsSurpriseVibes => 'Vibes';

  @override
  String statsSurpriseAskedRow(int asked, int picked) {
    return 'pedida $asked× · elegida $picked×';
  }

  @override
  String get statsSurpriseHowYouStart => 'Cómo empiezas';

  @override
  String get statsSurpriseViaQuiz => 'Cuestionario';

  @override
  String get statsSurpriseViaTastes => 'Mis gustos';

  @override
  String statsSurpriseViaRow(String sessions, String picks) {
    return '$sessions · $picks';
  }

  @override
  String statsSurpriseRelaxed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones tuvieron que ampliar la búsqueda',
      one: '1 sesión tuvo que ampliar la búsqueda',
    );
    return '$_temp0';
  }

  @override
  String get statsSurpriseRelaxLowerVotes => 'menos votos';

  @override
  String get statsSurpriseRelaxDropVibes => 'sin vibes';

  @override
  String get statsSurpriseRelaxWidenYears => 'años anteriores';

  @override
  String get statsSurpriseHabitTitle => 'Tu ritmo';

  @override
  String get statsSurpriseByMonth => 'Sesiones por mes';

  @override
  String get statsSurpriseByWeekday => 'Por día de la semana';

  @override
  String statsSurpriseStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas seguidas',
      one: '1 semana seguida',
    );
    return '$_temp0';
  }
}
