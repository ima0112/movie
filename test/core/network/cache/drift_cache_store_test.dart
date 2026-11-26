import 'dart:convert';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/network/cache/drift_cache_store.dart';
import 'package:movies/core/persistence/app_database.dart';

CacheResponse _response(
  String key, {
  String url = 'https://api.example/movie/1?language=en-US',
  int bytes = 10,
  DateTime? at,
  CachePriority priority = CachePriority.normal,
}) {
  final when = at ?? DateTime(2026, 11, 26, 10);
  return CacheResponse(
    cacheControl: CacheControl(maxAge: 3600),
    content: List.filled(bytes, 7),
    date: when,
    eTag: '"abc"',
    expires: null,
    headers: utf8.encode('{"content-type":["application/json"]}'),
    key: key,
    lastModified: null,
    maxStale: null,
    priority: priority,
    requestDate: when,
    responseDate: when,
    url: url,
    statusCode: 200,
  );
}

void main() {
  late AppDatabase db;
  late DateTime clock;
  late DriftCacheStore store;

  setUp(() {
    clock = DateTime(2026, 11, 26, 10);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = DriftCacheStore(
      db,
      maxBytes: 100,
      maxEntries: 3,
      maxEntryBytes: 50,
      now: () => clock,
    );
  });
  tearDown(() => db.close());

  test('what is saved comes back whole', () async {
    await store.set(_response('a'));

    final saved = await store.get('a');
    expect(saved, isNotNull);
    expect(saved!.content, List.filled(10, 7));
    expect(saved.statusCode, 200);
    expect(saved.eTag, '"abc"');
    expect(saved.url, 'https://api.example/movie/1?language=en-US');
    expect(saved.cacheControl.maxAge, 3600);
    expect(saved.responseDate, DateTime(2026, 11, 26, 10));
    expect(saved.priority, CachePriority.normal);
    expect(utf8.decode(saved.headers!), contains('content-type'));
    expect(await store.exists('a'), isTrue);
    expect(await store.get('missing'), isNull);
  });

  test('saving the same key again replaces it', () async {
    await store.set(_response('a', bytes: 5));
    await store.set(_response('a', bytes: 9));

    expect((await store.get('a'))!.content, hasLength(9));
    expect(await db.select(db.apiResponseCacheTable).get(), hasLength(1));
  });

  test('an answer over the per-entry cap is not stored', () async {
    await store.set(_response('big', bytes: 51));
    expect(await store.exists('big'), isFalse);
  });

  group('the caps', () {
    test('past 3 entries the least recently used goes', () async {
      for (final key in ['a', 'b', 'c']) {
        clock = clock.add(const Duration(minutes: 1));
        await store.set(_response(key));
      }
      clock = clock.add(const Duration(minutes: 1));
      await store.get('a'); // a is now the newest
      clock = clock.add(const Duration(minutes: 1));
      await store.set(_response('d'));

      expect(await store.exists('b'), isFalse); // the oldest untouched
      expect(await store.exists('a'), isTrue);
      expect(await store.exists('c'), isTrue);
      expect(await store.exists('d'), isTrue);
    });

    test('past the byte cap the oldest go until it fits', () async {
      for (final key in ['a', 'b', 'c']) {
        clock = clock.add(const Duration(minutes: 1));
        await store.set(_response(key, bytes: 40));
      }
      // 120 bytes > 100: a (the oldest) went.
      expect(await store.exists('a'), isFalse);
      expect(await store.exists('b'), isTrue);
      expect(await store.exists('c'), isTrue);
    });
  });

  test('purgeOlderThan drops what was received before the horizon', () async {
    await store.set(_response('old', at: DateTime(2026, 10, 1)));
    await store.set(_response('new', at: DateTime(2026, 11, 20)));

    await store.purgeOlderThan(const Duration(days: 30));

    expect(await store.exists('old'), isFalse);
    expect(await store.exists('new'), isTrue);
  });

  group('by path', () {
    setUp(() async {
      await store.set(
        _response('m', url: 'https://api.example/movie/1?language=es'),
      );
      await store.set(
        _response('p', url: 'https://api.example/person/2?language=es'),
      );
    });

    test('getFromPath finds the matching ones', () async {
      final found = await store.getFromPath(RegExp(r'/person/'));
      expect(found.map((r) => r.key), ['p']);
    });

    test('query parameters narrow it', () async {
      expect(
        await store.getFromPath(
          RegExp(r'api\.example'),
          queryParams: {'language': 'es'},
        ),
        hasLength(2),
      );
      expect(
        await store.getFromPath(
          RegExp(r'api\.example'),
          queryParams: {'language': 'en'},
        ),
        isEmpty,
      );
    });

    test('deleteFromPath removes only those', () async {
      await store.deleteFromPath(RegExp(r'/person/'));
      expect(await store.exists('p'), isFalse);
      expect(await store.exists('m'), isTrue);
    });
  });

  test('clean empties everything, or only up to a priority', () async {
    await store.set(_response('low', priority: CachePriority.low));
    await store.set(_response('high', priority: CachePriority.high));

    await store.clean(priorityOrBelow: CachePriority.normal);
    expect(await store.exists('low'), isFalse);
    expect(await store.exists('high'), isTrue);

    await store.clean();
    expect(await db.select(db.apiResponseCacheTable).get(), isEmpty);
  });

  test('delete removes one key', () async {
    await store.set(_response('a'));
    await store.delete('a');
    expect(await store.exists('a'), isFalse);
  });
}
