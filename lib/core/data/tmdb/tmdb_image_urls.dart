/// Plain (non-DTO) shape of TMDB's `/configuration` response — what
/// `TmdbConfigurationService` caches and [buildTmdbImageUrl] consumes.
///
/// [fallback] holds TMDB's own well-known, effectively-constant defaults
/// (unchanged for years in practice) — used until the real
/// `/configuration` fetch resolves, and kept as the standing value if
/// that fetch ever fails, so a flaky request never breaks every image in
/// the app.
class TmdbImagesConfig {
  const TmdbImagesConfig({
    required this.secureBaseUrl,
    required this.posterSizes,
    required this.backdropSizes,
    required this.profileSizes,
  });

  const TmdbImagesConfig.fallback()
    : secureBaseUrl = 'https://image.tmdb.org/t/p/',
      posterSizes = const [
        'w92',
        'w154',
        'w185',
        'w342',
        'w500',
        'w780',
        'original',
      ],
      backdropSizes = const ['w300', 'w780', 'w1280', 'original'],
      profileSizes = const ['w45', 'w185', 'h632', 'original'];

  final String secureBaseUrl;
  final List<String> posterSizes;
  final List<String> backdropSizes;
  final List<String> profileSizes;
}

/// Which of [TmdbImagesConfig]'s three size lists a request validates
/// [size] against.
enum TmdbImageKind { poster, backdrop, profile }

/// A handful of reasonable, commonly-wanted size tokens per [TmdbImageKind]
/// — callers aren't limited to these (any token TMDB actually serves for
/// that kind works), they're just a documented starting point so nobody
/// has to go look up TMDB's own size vocabulary for the common cases.
abstract final class TmdbImageSizes {
  static const posterSmall = 'w185'; // list rows, 110×165 token @~2x
  static const posterMedium = 'w342';
  static const posterLarge = 'w500'; // hero cards (330×440)
  static const backdropMedium = 'w780';
  static const backdropLarge = 'w1280';
  static const profileMedium = 'w185';
}

/// Builds a full TMDB image URL from a raw path (as TMDB's own API
/// returns it, e.g. `/abc123.jpg`) and a requested [size] — CLAUDE.md
/// rule 2: the only thing that knows TMDB's image-URL shape.
///
/// Returns `null` when [path] is `null` (no image for this item) — never
/// when [size] merely isn't one of [config]'s recognized sizes for
/// [kind]; that case falls back to `'original'` instead, so an unusual
/// but valid request still resolves to something.
String? buildTmdbImageUrl({
  required TmdbImagesConfig config,
  required TmdbImageKind kind,
  required String? path,
  required String size,
}) {
  if (path == null) return null;

  final availableSizes = switch (kind) {
    TmdbImageKind.poster => config.posterSizes,
    TmdbImageKind.backdrop => config.backdropSizes,
    TmdbImageKind.profile => config.profileSizes,
  };
  final resolvedSize = availableSizes.contains(size) ? size : 'original';

  return '${config.secureBaseUrl}$resolvedSize$path';
}
