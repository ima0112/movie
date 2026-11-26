import 'tmdb_image_urls.dart';

/// Swaps the size inside a TMDB image URL for the one a widget really needs.
///
/// TMDB image URLs carry their size: `https://image.tmdb.org/t/p/w342/abc.jpg`
/// (`w342` = 342 px wide). The data layer builds each URL with one fixed size, so
/// a 360 dp hero card used a 342 px poster and a 64 dp avatar could get far more
/// than it shows. [resize] picks, from the sizes TMDB offers for [kind], the
/// smallest one that covers [neededPixels] (never beyond [maxSize]) and writes
/// it into the URL. Pure — it only reads text and the size list — and it knows
/// the URL's shape so no widget has to (CLAUDE.md rule 2).
///
/// ```
/// resize(url: '…/t/p/w342/abc.jpg', kind: poster, neededPixels: 1080,
///        maxSize: 'w780', config: …)  →  '…/t/p/w780/abc.jpg'
/// resize(url: '…/t/p/w342/abc.jpg', kind: poster, neededPixels: 330, …)
///                                    →  '…/t/p/w342/abc.jpg'  (already right)
/// ```
///
/// A URL that isn't a TMDB image URL (a YouTube thumbnail, a bundled asset path)
/// comes back unchanged, and so does one whose wanted size TMDB doesn't list for
/// [kind].
abstract final class TmdbImageResizer {
  /// How much of [neededPixels] a size may fall short by and still count: a
  /// 64 dp avatar on a 3× screen needs 192 px, and `w185` (96%) is close enough.
  static const double tolerance = 0.9;

  static final RegExp _tmdbUrl = RegExp(
    r'^(https?://[^?#]*?/t/p/)([^/?#]+)(/[^?#]+)$',
  );

  static String resize({
    required String url,
    required TmdbImageKind kind,
    required double neededPixels,
    required String maxSize,
    required TmdbImagesConfig config,
  }) {
    final match = _tmdbUrl.firstMatch(url);
    if (match == null) return url;

    final sizes = switch (kind) {
      TmdbImageKind.poster => config.posterSizes,
      TmdbImageKind.backdrop => config.backdropSizes,
      TmdbImageKind.profile => config.profileSizes,
      TmdbImageKind.still => config.stillSizes,
    };
    final cap = _pixels(maxSize) ?? double.infinity;
    // Real, sized options up to the cap, smallest first ("original" is never
    // one: it can weigh several MB).
    final options = [
      for (final size in sizes)
        if (_pixels(size) case final px? when px <= cap) (size, px),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    if (options.isEmpty) return url;

    final wanted = neededPixels * tolerance;
    var chosen = options.last.$1; // none big enough: the largest allowed
    for (final (size, px) in options) {
      if (px >= wanted) {
        chosen = size;
        break;
      }
    }
    return '${match.group(1)}$chosen${match.group(3)}';
  }

  /// `w342` / `h632` → 342 / 632; `original` and anything else → `null`.
  static double? _pixels(String size) {
    final m = RegExp(r'^[wh](\d+)$').firstMatch(size);
    return m == null ? null : double.parse(m.group(1)!);
  }
}
