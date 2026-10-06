import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/data/tmdb/tmdb_configuration_service.dart';
import '../../core/data/tmdb/tmdb_image_urls.dart';
import '../../core/theme/app_colors.dart';

/// An episode still (H4's episode rows), resolved from TMDB's own raw
/// `still_path` (e.g. `/abc123.jpg`), never a pre-built URL — same
/// "`/configuration` for sizes" rule `PosterImage` already follows, just
/// for [TmdbImageKind.still] instead of `.poster`.
///
/// Shows [AppColors.surfaceRaised2] when [stillPath] is `null` (no still
/// for this episode) and as the `Image.network` fallback if the resolved
/// URL ever fails to load.
class StillImage extends StatelessWidget {
  const StillImage({
    super.key,
    required this.stillPath,
    this.size = TmdbImageSizes.stillMedium,
  });

  final String? stillPath;
  final String size;

  static const _placeholder = ColoredBox(color: AppColors.surfaceRaised2);

  @override
  Widget build(BuildContext context) {
    final path = stillPath;
    if (path == null) return _placeholder;

    // Same fake/real fallback as PosterImage: TmdbConfigurationService
    // only exists in the `real` environment.
    final config = getIt.isRegistered<TmdbConfigurationService>()
        ? _loadAndGetConfig()
        : const TmdbImagesConfig.fallback();

    final url = buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.still,
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

  static TmdbImagesConfig _loadAndGetConfig() {
    final service = getIt<TmdbConfigurationService>();
    service.load();
    return service.current;
  }
}
