import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../network/api_client.dart';
import 'tmdb_configuration_dto.dart';
import 'tmdb_image_urls.dart';

/// Loads and caches `GET /configuration` once — `docs/DECISIONS.md` §2:
/// "Image configuration | `GET /configuration` (cache once)".
///
/// [current] is synchronous and always available, starting at
/// [TmdbImagesConfig.fallback] and swapping to the real fetched values
/// once [load] resolves — deliberately not `Future`-only, so a widget
/// like `PosterImage` can build an image URL on its very first frame
/// without a `FutureBuilder`. A failed fetch is swallowed and [current]
/// simply stays on whatever it already was (the fallback, or an earlier
/// successful load); nothing in this app needs to react to *that*
/// failure, so it isn't surfaced as a `Result`/`Failure` (rule 7 is about
/// not leaking exceptions to `presentation`, not about forcing `Result`
/// on every internal cache).
@real
@lazySingleton
class TmdbConfigurationService {
  TmdbConfigurationService(this._apiClient);

  final ApiClient _apiClient;

  TmdbImagesConfig _current = const TmdbImagesConfig.fallback();
  Future<TmdbImagesConfig>? _loading;

  TmdbImagesConfig get current => _current;

  /// Fetches once; every call after the first returns the same memoized
  /// `Future`, including while the first one is still in flight.
  Future<TmdbImagesConfig> load() => _loading ??= _fetch();

  Future<TmdbImagesConfig> _fetch() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/configuration',
      );
      final dto = TmdbConfigurationDto.fromJson(response.data!);
      _current = TmdbImagesConfig(
        secureBaseUrl: dto.images.secureBaseUrl,
        posterSizes: dto.images.posterSizes,
        backdropSizes: dto.images.backdropSizes,
        profileSizes: dto.images.profileSizes,
        stillSizes: dto.images.stillSizes,
      );
    } catch (_) {
      // Keep whatever `_current` already was — see the class doc comment.
    }
    return _current;
  }
}
