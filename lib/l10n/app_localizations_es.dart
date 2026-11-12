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
  String get vibeFantasy => 'Fantasía';

  @override
  String get tvStatusCardLabel => 'Estado';

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
  String get discoverSortVotes => 'Más votadas';

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
  String get navMatchButton => 'Sorpréndeme y emparejar';

  @override
  String get offlineBannerMessage => 'Sin conexión';

  @override
  String get onboardingSaveError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get onboardingTastesSavedSnackbar =>
      'Gustos guardados · Edítalos en Tú';

  @override
  String get onboardingGenreStep3Label => 'Paso 3 de 3';

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
  String get onboardingGenreStep3NextLabel => 'Listo';

  @override
  String get onboardingNameHeadline => '¿Cómo te llamas?';

  @override
  String get onboardingNameBody =>
      'Así te llamaré, y así te verán los demás en las salas.';

  @override
  String get onboardingNameHint => 'Tu nombre';

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
  String carouselSectionBecauseYouLike(String title) {
    return 'Porque te gusta $title';
  }

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
  String get exploreTryAnotherTitle => 'Prueba con otro título';

  @override
  String get exploreDefaultResultsTitle => 'Resultados';

  @override
  String get exploreSearchHint => 'Películas, series, personas';

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
  String get myTastesIntro =>
      'Cuanto más sepamos, mejores serán tus recomendaciones y el modo Sorpréndeme. Todo se guarda solo en tu dispositivo.';

  @override
  String get myTastesGenresLikeHint => 'Elige los que quieras.';

  @override
  String get myTastesGenresNeverHint => 'No los mostramos en recomendaciones.';

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
  String get tvEpisodesSectionTitle => 'Episodios';

  @override
  String tvEpisodeCode(int season, int episode) {
    return 'T$season · E$episode';
  }

  @override
  String tvEpisodeCodeSpecials(int episode) {
    return 'Especiales · E$episode';
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
  String get tvNextEpisodeCaption => 'Próximo episodio';

  @override
  String get tvLastAiredEpisodeCaption => 'Último episodio emitido';

  @override
  String get tvNoNextEpisodeTitle => 'Sin próximo episodio';

  @override
  String get tvNoNextEpisodeUnknown =>
      'Aún no se ha anunciado ningún episodio próximo.';

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
  String get mediaDetailShare => 'Compartir';

  @override
  String get mediaDetailShareFailed => 'No se pudo compartir';

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
  String get quizExcludeWatchedToggle => 'Excluir lo que ya he visto';

  @override
  String get quizGenreStepHeadline => 'Elige hasta 3 que NO te apetezcan';

  @override
  String quizSelectionCounter(int selected, int max) {
    return '$selected de $max';
  }

  @override
  String get quizMaxSeasonsLabel => 'Temporadas máximas';

  @override
  String get quizSearchButton => 'Buscar';

  @override
  String get quizVibeStepHeadline => 'Ahora elige 3 que SÍ te apetezcan';

  @override
  String get quizYearStepHeadline => '¿Hasta cuándo quieres retroceder?';

  @override
  String get surpriseErrorMessage =>
      'No hemos encontrado nada. Inténtalo de nuevo.';

  @override
  String get chooseTypeHeadline => '¿Qué te apetece hoy?';

  @override
  String get surpriseNoMoreSuggestionsTitle => 'Eso es todo por ahora';

  @override
  String get surpriseNoMoreSuggestionsBody =>
      'Se nos acabaron las sugerencias de esta búsqueda — inténtalo de nuevo para encontrar algo nuevo.';

  @override
  String get surpriseSearchAgain => 'Buscar de nuevo';

  @override
  String get surpriseNoMatchTitle => 'No hemos encontrado nada';

  @override
  String get chooseTypeMovieLabel => 'Una película';

  @override
  String get chooseTypeTvShowLabel => 'Una serie';

  @override
  String get surpriseYourSuggestionTitle => 'Tu sugerencia';

  @override
  String get surpriseSearchingLabel => 'Buscando…';

  @override
  String get surpriseViewDetailsLink => 'Ver detalles';

  @override
  String get surpriseSourceProfile => 'Según tus gustos';

  @override
  String get surpriseSourceInferredList => 'Según tu lista';

  @override
  String get surpriseSourceQuiz => 'Según tus respuestas';

  @override
  String get surpriseRelaxedSearchNote =>
      'Ampliamos un poco la búsqueda para encontrar esta coincidencia.';

  @override
  String get surpriseAddToWatchLater => 'Añadir a ver después';

  @override
  String get surpriseAnotherSuggestion => 'Otra sugerencia';

  @override
  String get surpriseAddedToWatchLaterSnackbar => 'Añadido a ver después';

  @override
  String get surpriseChooseSourceTitle => 'Encuentra algo para ver';

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
}
