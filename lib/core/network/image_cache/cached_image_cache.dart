import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import 'app_image_cache.dart';

/// The real [AppImageCache]: images kept on disk by `cached_network_image`'s
/// provider with its own [CacheManager], limited by [ImageCacheLimits], so a
/// screen visited again shows its posters without downloading them, and the
/// folder doesn't grow without bound.
@real
@LazySingleton(as: AppImageCache)
class CachedImageCache implements AppImageCache {
  CachedImageCache()
    : _manager = CacheManager(
        Config(
          ImageCacheLimits.key,
          stalePeriod: ImageCacheLimits.stalePeriod,
          maxNrOfCacheObjects: ImageCacheLimits.maxObjects,
        ),
      );

  final CacheManager _manager;

  @override
  ImageProvider provider(String url, {int? cacheWidth}) =>
      ResizeImage.resizeIfNeeded(
        cacheWidth,
        null,
        CachedNetworkImageProvider(url, cacheManager: _manager),
      );

  @override
  Future<void> precache(
    BuildContext context,
    String url, {
    int? cacheWidth,
  }) async {
    try {
      // `onError`: without it a failed warm-up is reported as an unhandled error.
      await precacheImage(
        provider(url, cacheWidth: cacheWidth),
        context,
        onError: (error, stackTrace) {},
      );
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    await _manager.emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

/// The `fake` environment's [AppImageCache]: plain `NetworkImage`, no disk.
@fake
@LazySingleton(as: AppImageCache)
class FakeImageCache extends NetworkImageCache {
  const FakeImageCache();
}
