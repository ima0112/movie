import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/network/image_cache/app_image_cache.dart';
import 'package:movies/shared/widgets/poster_precache.dart';

class _Cache implements AppImageCache {
  final precached = <(String, int?)>[];
  @override
  ImageProvider provider(String url, {int? cacheWidth}) => NetworkImage(url);
  @override
  Future<void> precache(
    BuildContext context,
    String url, {
    int? cacheWidth,
  }) async => precached.add((url, cacheWidth));
  @override
  Future<void> clear() async {}
}

String _url(int i) => 'https://image.tmdb.org/t/p/w342/p$i.jpg';

Widget _host(List<String?> urls) => MediaQuery(
  data: const MediaQueryData(devicePixelRatio: 3),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: PosterPrecache(
      urls: urls,
      logicalWidth: 110,
      child: const SizedBox(key: ValueKey('child')),
    ),
  ),
);

void main() {
  late _Cache cache;
  setUp(() {
    cache = _Cache();
    getIt.registerSingleton<AppImageCache>(cache);
  });
  tearDown(() => getIt.reset());

  testWidgets(
    'it warms the 4 posters after the first 5, at the width the cards '
    'are drawn at, and lays out only its child',
    (tester) async {
      await tester.pumpWidget(_host([for (var i = 0; i < 12; i++) _url(i)]));

      expect(cache.precached, [for (var i = 5; i < 9; i++) (_url(i), 330)]);
      expect(find.byKey(const ValueKey('child')), findsOneWidget);
    },
  );

  testWidgets('a short list, or items with no poster, warms what there is', (
    tester,
  ) async {
    await tester.pumpWidget(_host([_url(0), _url(1)]));
    expect(cache.precached, isEmpty);

    await tester.pumpWidget(
      _host([for (var i = 0; i < 8; i++) i == 6 ? null : _url(i)]),
    );
    expect(cache.precached.map((e) => e.$1), [_url(5), _url(7)]);
  });

  testWidgets('a rebuild with the same list does nothing; a new list warms '
      'only its new posters', (tester) async {
    final urls = [for (var i = 0; i < 12; i++) _url(i)];
    await tester.pumpWidget(_host(urls));
    final first = cache.precached.length;

    await tester.pumpWidget(_host(urls));
    expect(cache.precached, hasLength(first));

    await tester.pumpWidget(_host(['x', ...urls.skip(1), _url(20)]));
    expect(cache.precached, hasLength(first));
  });
}
