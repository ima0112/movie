import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/network/cache/cache_ttl.dart';

void main() {
  Duration? ttl(String path) => CacheTtl.ruleFor(path)?.ttl;

  test('Home\'s fixed lists: 10 minutes', () {
    for (final path in [
      '/trending/all/week',
      '/trending/movie/week',
      '/trending/tv/week',
      '/movie/now_playing',
      '/movie/top_rated',
      '/movie/upcoming',
      '/tv/on_the_air',
      '/tv/top_rated',
      '/tv/popular',
    ]) {
      expect(ttl(path), CacheTtl.homeLists, reason: path);
    }
    expect(CacheTtl.homeLists, const Duration(minutes: 10));
  });

  test('discover: 15 minutes; recommendations: 1 hour', () {
    expect(ttl('/discover/movie'), const Duration(minutes: 15));
    expect(ttl('/discover/tv'), const Duration(minutes: 15));
    expect(ttl('/movie/603/recommendations'), const Duration(hours: 1));
    expect(ttl('/tv/1396/recommendations'), const Duration(hours: 1));
  });

  test('a title, its seasons, videos and where to watch: 6 hours', () {
    for (final path in [
      '/movie/603',
      '/tv/1396',
      '/tv/1396/season/2',
      '/movie/603/videos',
      '/movie/603/watch/providers',
      '/tv/1396/watch/providers',
    ]) {
      expect(ttl(path), const Duration(hours: 6), reason: path);
    }
  });

  test('persons, the platform lists and the configuration: 24 hours', () {
    for (final path in [
      '/person/287',
      '/watch/providers/movie',
      '/watch/providers/tv',
      '/configuration',
    ]) {
      expect(ttl(path), const Duration(hours: 24), reason: path);
    }
  });

  test(
    'a fixed list is not mistaken for a title (and the other way round)',
    () {
      expect(ttl('/movie/now_playing'), isNot(CacheTtl.detail));
      expect(ttl('/movie/603'), isNot(CacheTtl.homeLists));
    },
  );

  test('search is never cached, nor is anything unlisted', () {
    for (final path in [
      '/search/multi',
      '/search/movie',
      '/movie/603/credits',
      '/genre/movie/list',
      '/anything',
      '/movie/603/',
      '',
    ]) {
      expect(CacheTtl.ruleFor(path), isNull, reason: path);
    }
  });

  test('the offline horizon is well under TMDB\'s six months', () {
    expect(CacheTtl.staleHorizon, const Duration(days: 30));
    expect(CacheTtl.staleHorizon, lessThan(const Duration(days: 180)));
  });

  test(
    'SWR windows: lists and discover 24 h, detail 7 days, the rest none',
    () {
      Duration? window(String path) => CacheTtl.ruleFor(path)?.swrWindow;
      expect(window('/trending/all/week'), const Duration(hours: 24));
      expect(window('/discover/movie'), const Duration(hours: 24));
      expect(window('/movie/603'), const Duration(days: 7));
      expect(window('/tv/1396/season/2'), const Duration(days: 7));
      // No window: it equals the TTL, so past it the network is waited for.
      expect(window('/movie/603/recommendations'), const Duration(hours: 1));
      expect(window('/person/287'), const Duration(hours: 24));
      for (final rule in CacheTtl.rules) {
        expect(rule.swrWindow >= rule.ttl, isTrue);
        expect(rule.swrWindow <= CacheTtl.staleHorizon, isTrue);
      }
    },
  );
}
