import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/data/tmdb/tmdb_configuration_service.dart';
import '../../core/data/tmdb/tmdb_image_urls.dart';
import '../../core/theme/app_colors.dart';

/// A poster, resolved from TMDB's own raw `poster_path` (e.g.
/// `/abc123.jpg`), never a pre-built URL — `docs/STRUCTURE.md`:
/// "`poster_image.dart` uses `/configuration` for sizes."
///
/// Shows [AppColors.surfaceRaised2] when [posterPath] is `null` (no
/// poster for this item) and as the `Image.network` fallback if the
/// resolved URL ever fails to load.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.posterPath,
    this.size = TmdbImageSizes.posterMedium,
  });

  final String? posterPath;

  /// One of TMDB's own poster size tokens (`TmdbImageSizes.poster*` for
  /// the common ones) — callers pick per context (a list row doesn't
  /// need the same resolution as a hero card).
  final String size;

  static const _placeholder = ColoredBox(color: AppColors.surfaceRaised2);

  @override
  Widget build(BuildContext context) {
    final path = posterPath;
    if (path == null) return _placeholder;

    // TmdbConfigurationService only exists in the `real` environment (it
    // needs ApiClient, which the `fake` environment never registers —
    // FakeMediaRepository never produces a posterPath anyway). Fall back
    // to the same well-known-good config the service itself starts at,
    // so this widget works in both.
    final config = getIt.isRegistered<TmdbConfigurationService>()
        ? _loadAndGetConfig()
        : const TmdbImagesConfig.fallback();

    final url = buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.poster,
      path: path,
      size: size,
    );
    if (url == null) return _placeholder;

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder,
    );
  }

  /// Fire-and-forget: memoized internally, so `load()` is a no-op after
  /// the very first call anywhere in the app. [TmdbConfigurationService
  /// .current] is synchronous and already starts at a well-known-good
  /// fallback, so this image never has to wait on it.
  static TmdbImagesConfig _loadAndGetConfig() {
    final service = getIt<TmdbConfigurationService>();
    service.load();
    return service.current;
  }
}
