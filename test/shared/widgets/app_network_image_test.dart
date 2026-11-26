import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/network/image_cache/app_image_cache.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/app_network_image.dart';
import 'package:movies/shared/widgets/image_use.dart';

/// A 1x1 transparent PNG.
final Uint8List _png = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xFF,
  0xFF,
  0x3F,
  0x00,
  0x05,
  0xFE,
  0x02,
  0xFE,
  0xDC,
  0xCC,
  0x59,
  0xE7,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _RecordingCache implements AppImageCache {
  final requests = <(String url, int? cacheWidth)>[];
  final precached = <(String url, int? cacheWidth)>[];

  @override
  ImageProvider provider(String url, {int? cacheWidth}) {
    requests.add((url, cacheWidth));
    return MemoryImage(_png);
  }

  @override
  Future<void> precache(
    BuildContext context,
    String url, {
    int? cacheWidth,
  }) async => precached.add((url, cacheWidth));

  @override
  Future<void> clear() async {}
}

Widget _host(Widget child, {double dpr = 3, bool reduceMotion = false}) =>
    MediaQuery(
      data: MediaQueryData(
        devicePixelRatio: dpr,
        disableAnimations: reduceMotion,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );

void main() {
  late _RecordingCache cache;

  setUp(() {
    cache = _RecordingCache();
    getIt.registerSingleton<AppImageCache>(cache);
  });
  tearDown(() => getIt.reset());

  testWidgets('no URL: the flat placeholder tile, nothing is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 150,
          child: AppNetworkImage(url: null, use: ImageUse.poster),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    final box = tester.widget<ColoredBox>(find.byType(ColoredBox).first);
    expect(box.color, AppColors.imagePlaceholder);
    expect(cache.requests, isEmpty);
  });

  testWidgets('a 360 dp hero card on a 3x screen asks for w780 and decodes '
      'at 1080 px', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 360,
          height: 380,
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
            use: ImageUse.poster,
          ),
        ),
      ),
    );

    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w780/abc.jpg',
      1080,
    ));
  });

  testWidgets('a list poster keeps w342; a small avatar gets w185', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 110,
          height: 165,
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
            use: ImageUse.poster,
          ),
        ),
      ),
    );
    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w342/abc.jpg',
      330,
    ));

    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 64,
          height: 64,
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/h632/face.jpg',
            use: ImageUse.profile,
          ),
        ),
      ),
    );
    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w185/face.jpg',
      192,
    ));
  });

  testWidgets('an explicit width wins over the parent\'s', (tester) async {
    await tester.pumpWidget(
      _host(
        const AppNetworkImage(
          url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
          use: ImageUse.poster,
          width: 110,
          height: 165,
        ),
        dpr: 2,
      ),
    );
    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w342/abc.jpg',
      220,
    ));
  });

  testWidgets('a logo and a non-TMDB image keep their URL, and are still '
      'decoded at the size drawn', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 56,
          height: 56,
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/w92/logo.png',
            use: ImageUse.logo,
          ),
        ),
      ),
    );
    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w92/logo.png',
      168,
    ));

    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: AppNetworkImage(
            url: 'https://img.youtube.com/vi/abc/hqdefault.jpg',
            use: ImageUse.other,
          ),
        ),
      ),
    );
    expect(cache.requests.last, (
      'https://img.youtube.com/vi/abc/hqdefault.jpg',
      360,
    ));
  });

  testWidgets('with no width to go by (a loose parent) the URL and the decode '
      'are left whole', (tester) async {
    await tester.pumpWidget(
      _host(
        const UnconstrainedBox(
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
            use: ImageUse.poster,
          ),
        ),
      ),
    );
    expect(cache.requests.last, (
      'https://image.tmdb.org/t/p/w342/abc.jpg',
      null,
    ));
  });

  testWidgets('it fades in over the placeholder, and not at all with reduce '
      'motion', (tester) async {
    const image = SizedBox(
      width: 100,
      height: 100,
      child: AppNetworkImage(
        url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
        use: ImageUse.poster,
      ),
    );
    // Not already in memory (an earlier test decoded the same bytes).
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await tester.pumpWidget(_host(image));
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    await tester.pumpAndSettle();

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await tester.pumpWidget(_host(image, reduceMotion: true));
    expect(find.byType(AnimatedOpacity), findsNothing);
  });

  testWidgets('a failing image falls back to the placeholder, with no '
      'exception', (tester) async {
    getIt.unregister<AppImageCache>();
    getIt.registerSingleton<AppImageCache>(const NetworkImageCache());
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 100,
          child: AppNetworkImage(
            url: 'https://image.tmdb.org/t/p/w342/abc.jpg',
            use: ImageUse.poster,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .any((b) => b.color == AppColors.imagePlaceholder),
      isTrue,
    );
  });

  testWidgets('precache warms the same url and width the widget will use', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) => SizedBox(
            child: Builder(
              builder: (cc) {
                context = cc;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    await AppNetworkImage.precache(
      context,
      'https://image.tmdb.org/t/p/w342/abc.jpg',
      use: ImageUse.poster,
      logicalWidth: 360,
    );
    expect(cache.precached.single, (
      'https://image.tmdb.org/t/p/w780/abc.jpg',
      1080,
    ));

    await AppNetworkImage.precache(context, null, use: ImageUse.poster);
    expect(cache.precached, hasLength(1));
  });
}
