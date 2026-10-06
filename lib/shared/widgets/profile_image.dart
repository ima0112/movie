import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/data/tmdb/tmdb_configuration_service.dart';
import '../../core/data/tmdb/tmdb_image_urls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A person's profile photo, resolved from TMDB's own raw `profile_path`
/// (e.g. `/abc123.jpg`), never a pre-built URL — same "`/configuration`
/// for sizes" rule `PosterImage`/`StillImage` already follow, just for
/// [TmdbImageKind.profile]. The one widget every `profilePath` consumer
/// uses: `person_detail_header.dart`'s header, `full_cast_sheet.dart`'s
/// rows, and D1/D2's own cast circle (`media_cast_circle.dart` — that
/// one used to paint `Image.network(profilePath, ...)` directly, treating
/// the raw TMDB path as if it were already a full URL, so a photo never
/// actually loaded).
///
/// When there's no photo to show — [profilePath] is `null`, or the
/// resolved URL fails to load — shows [name]'s first letter over
/// [AppColors.surfaceRaised] rather than an empty circle. [name] is
/// optional only so a hypothetical future caller without one still gets
/// a sensible (plain) fallback; every current caller has a name and
/// passes it. Not circular by itself — same as `PosterImage` not being
/// poster-shaped by itself — the caller clips it (`ClipOval`).
class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.profilePath,
    this.name,
    this.size = TmdbImageSizes.profileMedium,
  });

  final String? profilePath;
  final String? name;
  final String size;

  @override
  Widget build(BuildContext context) {
    final path = profilePath;
    if (path == null) return _Placeholder(name: name);

    final config = getIt.isRegistered<TmdbConfigurationService>()
        ? _loadAndGetConfig()
        : const TmdbImagesConfig.fallback();

    final url = buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.profile,
      path: path,
      size: size,
    );
    if (url == null) return _Placeholder(name: name);

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _Placeholder(name: name),
    );
  }

  static TmdbImagesConfig _loadAndGetConfig() {
    final service = getIt<TmdbConfigurationService>();
    service.load();
    return service.current;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = name;
    return ColoredBox(
      color: AppColors.surfaceRaised,
      child: initial == null || initial.isEmpty
          ? null
          : Center(
              child: Text(
                initial[0].toUpperCase(),
                style: AppTextStyles.h3.copyWith(color: AppColors.ink),
              ),
            ),
    );
  }
}
