import '../../core/data/tmdb/tmdb_image_urls.dart';

/// What an image is for: it decides which of TMDB's size lists
/// (`/configuration`) the image's size is chosen from and how large it may get.
/// `AppNetworkImage` takes one with every URL.
enum ImageUse {
  /// A poster, from a list thumbnail to the hero card. Up to `w780`.
  poster(TmdbImageKind.poster, 'w780'),

  /// A 16:9 backdrop (a detail's header, a carousel slide). Up to `w1280`.
  backdrop(TmdbImageKind.backdrop, 'w1280'),

  /// A person's photo (cast circles, a filmography header).
  profile(TmdbImageKind.profile, 'h632'),

  /// An episode's still. TMDB offers up to `w300` besides the full size.
  still(TmdbImageKind.still, 'w300'),

  /// A streaming service's logo: small and fixed, left at the size it comes in.
  logo(null, null),

  /// Anything else (a YouTube thumbnail): left as it is.
  other(null, null);

  const ImageUse(this.kind, this.maxSize);

  /// Which TMDB size list applies, or `null` when the URL is left untouched.
  final TmdbImageKind? kind;

  /// The largest size token the image may be switched to.
  final String? maxSize;
}
