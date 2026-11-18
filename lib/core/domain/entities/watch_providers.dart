/// Where to watch (JustWatch via TMDB). See `docs/DECISIONS.md` section 2.
///
/// Split into its own file per CLAUDE.md rule 13: reused by both
/// `MovieDetail` and `TvShowDetail` (`media_detail.dart`), and likely to
/// grow in v1.2 with the platform filter.
final class WatchProviders {
  const WatchProviders({
    required this.flatrate,
    required this.rent,
    required this.buy,
    required this.link,
    this.logos = const {},
    this.ids = const {},
  });

  final List<String> flatrate;
  final List<String> rent;
  final List<String> buy;
  final String? link;

  /// Provider name → logo URL, for whichever providers TMDB has a logo for.
  /// Optional: a provider missing here simply has no logo to draw.
  final Map<String, String> logos;

  /// Each service's TMDB provider id (what `with_watch_providers` takes), by
  /// the same names as the lists. A service TMDB gave no id for is absent.
  final Map<String, int> ids;

  bool get hasAny => flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;

  static const empty = WatchProviders(
    flatrate: [],
    rent: [],
    buy: [],
    link: null,
  );
}
