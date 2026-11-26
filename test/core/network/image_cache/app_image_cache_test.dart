import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/network/image_cache/app_image_cache.dart';

void main() {
  const cache = NetworkImageCache();

  test('without a width the provider is the plain network image', () {
    expect(cache.provider('https://x/a.jpg'), isA<NetworkImage>());
  });

  test('with a width the image is decoded at that width, keeping its aspect '
      'ratio', () {
    final provider = cache.provider('https://x/a.jpg', cacheWidth: 330);
    expect(provider, isA<ResizeImage>());
    final resize = provider as ResizeImage;
    expect(resize.width, 330);
    expect(resize.height, isNull);
    expect(resize.imageProvider, isA<NetworkImage>());
  });

  test('the same url and width are the same provider key, so a precache '
      'warms what the widget will show', () {
    expect(
      cache.provider('https://x/a.jpg', cacheWidth: 330),
      cache.provider('https://x/a.jpg', cacheWidth: 330),
    );
    expect(
      cache.provider('https://x/a.jpg', cacheWidth: 330),
      isNot(cache.provider('https://x/a.jpg', cacheWidth: 660)),
    );
  });

  test('the disk limits: 500 images, 30 days', () {
    expect(ImageCacheLimits.maxObjects, 500);
    expect(ImageCacheLimits.stalePeriod, const Duration(days: 30));
    // Under TMDB's six-month cap on keeping its data.
    expect(ImageCacheLimits.stalePeriod, lessThan(const Duration(days: 180)));
  });

  test('the fake environment registers the plain network cache', () {
    configureDependencies(fake.name);
    expect(getIt<AppImageCache>(), isA<NetworkImageCache>());
    getIt.reset();
  });
}
