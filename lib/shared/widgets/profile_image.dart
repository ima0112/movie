import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/data/tmdb/tmdb_configuration_service.dart';
import '../../core/data/tmdb/tmdb_image_urls.dart';
import '../../core/theme/app_colors.dart';

/// A person's profile photo (D3's header), resolved from TMDB's own raw
/// `profile_path` (e.g. `/abc123.jpg`), never a pre-built URL — same
/// "`/configuration` for sizes" rule `PosterImage`/`StillImage` already
/// follow, just for [TmdbImageKind.profile].
///
/// Shows [AppColors.surfaceRaised2] when [profilePath] is `null` and as
/// the `Image.network` fallback if the resolved URL ever fails to load.
/// Not circular by itself — same as `PosterImage` not being
/// poster-shaped by itself — the caller clips it (`person_detail_header
/// .dart`'s own `ClipOval`).
class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.profilePath,
    this.size = TmdbImageSizes.profileMedium,
  });

  final String? profilePath;
  final String size;

  static const _placeholder = ColoredBox(color: AppColors.surfaceRaised2);

  @override
  Widget build(BuildContext context) {
    final path = profilePath;
    if (path == null) return _placeholder;

    final config = getIt.isRegistered<TmdbConfigurationService>()
        ? _loadAndGetConfig()
        : const TmdbImagesConfig.fallback();

    final url = buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.profile,
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
