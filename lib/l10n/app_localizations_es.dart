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
    return 'Versión $version ($build)';
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
      'TMDB está teniendo problemas ahora mismo. Inténtalo de nuevo en un momento.';

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
  String get vibeFeelGood => 'Para sentirse bien';

  @override
  String get vibeIndie => 'Indie';

  @override
  String get vibeMonster => 'Monstruos';

  @override
  String get vibeDetective => 'Detectives';

  @override
  String get vibeClassic => 'Clásico';

  @override
  String get vibeSuperhero => 'Superhéroes';

  @override
  String get vibeCult => 'Culto';

  @override
  String get vibeTearjerker => 'Lágrimas';

  @override
  String get vibeSports => 'Deportes';

  @override
  String get vibeDateNight => 'Noche romántica';

  @override
  String get vibeFuture => 'Futuro';

  @override
  String get vibeExplosive => 'Explosivo';

  @override
  String get vibeGritty => 'Crudo';

  @override
  String get vibeTrueStory => 'Historia real';

  @override
  String get vibeGangster => 'Gánsteres';

  @override
  String get vibeMusical => 'Musical';

  @override
  String get tvStatusAiring => 'En emisión';

  @override
  String get tvStatusEnded => 'Finalizada';

  @override
  String get tvStatusCancelled => 'Cancelada';

  @override
  String get quizFinishedToggleFinished => 'Terminada';

  @override
  String get quizFinishedToggleEither => 'Cualquiera';

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
  String get myListTabFavorites => 'Favoritos';

  @override
  String get myListTabWatchLater => 'Ver después';

  @override
  String get myListTabWatched => 'Vistos';

  @override
  String myListRemovedFromTab(String tabName) {
    return 'Eliminado de $tabName';
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
  String get offlineBannerMessage => 'Sin conexión';

  @override
  String get onboardingSaveError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get onboardingTastesSavedSnackbar =>
      'Gustos guardados · Edítalos en Tú';

  @override
  String get onboardingGenreStep2Label => 'Paso 2 de 3';

  @override
  String get onboardingGenreStep3Label => 'Paso 3 de 3';

  @override
  String get onboardingGenreStep2Headline => '¿Qué géneros te gustan?';

  @override
  String get onboardingGenreStep3Headline => '¿Y cuáles nunca?';

  @override
  String get onboardingGenreStep3HighlightWord => 'nunca';

  @override
  String get onboardingGenreStep3NextLabel => 'Listo';

  @override
  String get onboardingNameHeadline => '¿Cómo te llamas?';

  @override
  String get onboardingNameBody =>
      'Así te llamaré, y así te verán los demás en las salas.';

  @override
  String get onboardingNameHint => 'Tu nombre';

  @override
  String get onboardingWelcomeHeadline => 'Hola, soy Pako';

  @override
  String get onboardingWelcomeSubtitle =>
      'Te ayudaré a encontrar algo que ver, solo o con amigos.';

  @override
  String get onboardingWelcomeGetStarted => 'Empezar';

  @override
  String get onboardingWelcomeTmdbAttribution => 'Datos de TMDB';

  @override
  String get commonCouldntLoad => 'No se pudo cargar';

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
  String get carouselSectionBecauseYouLike => 'Porque te gusta…';

  @override
  String get carouselSectionInTheaters => 'En cines';

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
  String get exploreNoResults => 'Sin resultados';

  @override
  String get exploreTryAnotherTitle => 'Prueba con otro título';

  @override
  String get exploreDefaultResultsTitle => 'Resultados';

  @override
  String get exploreSearchHint => 'Películas, series, personas';

  @override
  String get exploreRecentSearchesLabel => 'Recientes';

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
  String get filteredListEmptyTitle => 'Nada coincide con estos filtros';

  @override
  String get filteredListEmptyBody => 'Prueba a ajustar tus filtros.';

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
  String get filterSheetSectionType => 'Tipo';

  @override
  String get filterSheetSectionYear => 'Año';

  @override
  String get filterSheetSectionMinRating => 'Valoración mínima';

  @override
  String get filterSheetSectionMaxRuntime => 'Duración máxima';

  @override
  String get filterSheetSectionStatus => 'Estado';

  @override
  String get filterSheetSectionSortBy => 'Ordenar por';

  @override
  String get filterSheetSeeResultsLoading => 'Ver resultados';

  @override
  String filterSheetSeeResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return 'Ver $_temp0';
  }

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
  String get libraryRowDateToday => 'Hoy';

  @override
  String get libraryRowDateYesterday => 'Ayer';

  @override
  String libraryRowDateDaysAgo(int count) {
    return 'Hace $count días';
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
  String myListRuntimeHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String myListRuntimeMinutesOnly(int minutes) {
    return '$minutes min';
  }

  @override
  String get myListSortRecent => 'Recientes';

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
  String myListSegmentLabelWithCount(String label, int count) {
    return '$label ($count)';
  }

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
  String myTastesSummarySinceYear(int year) {
    return 'desde $year';
  }

  @override
  String myTastesSummaryNeverGenre(String genreName) {
    return 'nunca $genreName';
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
  String get yourActivityTitle => 'Tu actividad';

  @override
  String get yourActivityHoursLabel => 'Horas';

  @override
  String get yourActivitySeeStats => 'Ver estadísticas';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsActivityStripTitle => 'Actividad de los últimos 12 meses';

  @override
  String get statsEmptyTitle =>
      'Marca algo como visto para ver tus estadísticas';

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
  String get myTastesGenresLikeTitle => 'Géneros que te gustan';

  @override
  String get myTastesGenresNeverTitle => 'Géneros que nunca quieres';

  @override
  String get myTastesSavedIndicator => 'Guardado';

  @override
  String get myTastesVibesLikeTitle => 'Vibes que te gustan';

  @override
  String get myTastesHowFarBackLabel => 'Hasta cuándo';

  @override
  String statsHoursValue(String hours) {
    return '$hours h';
  }

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
  String get tvCreatedByLabel => 'Creada por ';

  @override
  String get tvSeasonsSectionTitle => 'Temporadas';

  @override
  String get tvSpecialsLabel => 'Especiales';

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
}
