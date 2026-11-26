import 'package:flutter/widgets.dart';

/// Where the app's network images come from, and how they are kept.
///
/// One service so every image — a poster, a backdrop, a cast photo, a streaming
/// logo — shares one disk cache and one memory policy (`docs/DECISIONS.md`,
/// "Caching"). Widgets never build an `ImageProvider` themselves: they go
/// through `AppNetworkImage`, which asks this for one.
///
/// The `real` environment keeps images on disk ([CachedImageCache]); the `fake`
/// one and tests use Flutter's plain network provider ([NetworkImageCache]), so
/// no test needs a platform plugin.
abstract interface class AppImageCache {
  /// The provider for [url]. With [cacheWidth] the image is **decoded** at that
  /// many pixels wide instead of its full size (the aspect ratio is kept), so a
  /// long scroll of posters doesn't hold full-size bitmaps in memory.
  ImageProvider provider(String url, {int? cacheWidth});

  /// Loads [url] into the cache now (the next posters of a carousel, the title
  /// about to be opened). Uses the same provider, and so the same keys, as the
  /// widget that will show it. Never throws: a failed warm-up just means the
  /// image loads when it is shown.
  Future<void> precache(BuildContext context, String url, {int? cacheWidth});

  /// Forgets every cached image, on disk and in memory (Settings, "Clear
  /// cache").
  Future<void> clear();
}

/// The disk cache's limits, in one place.
abstract final class ImageCacheLimits {
  /// The cache manager's key (its folder and database).
  static const String key = 'pickme_images';

  /// An image not used for this long is deleted. Well under the six months
  /// TMDB's terms allow caching its data for.
  static const Duration stalePeriod = Duration(days: 30);

  /// How many image files to keep: when one more arrives, the least recently
  /// used goes. About 20–40 MB (a `w342` poster weighs 30–45 KB, a `w780`
  /// backdrop 80–120 KB).
  static const int maxObjects = 500;
}

/// [AppImageCache] over Flutter's own `NetworkImage`: no disk cache. The `fake`
/// environment and tests use it, and so does `AppNetworkImage` when no
/// environment is configured.
class NetworkImageCache implements AppImageCache {
  const NetworkImageCache();

  @override
  ImageProvider provider(String url, {int? cacheWidth}) =>
      ResizeImage.resizeIfNeeded(cacheWidth, null, NetworkImage(url));

  @override
  Future<void> precache(
    BuildContext context,
    String url, {
    int? cacheWidth,
  }) async {
    try {
      await precacheImage(provider(url, cacheWidth: cacheWidth), context);
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
