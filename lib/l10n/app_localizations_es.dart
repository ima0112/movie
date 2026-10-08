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
}
