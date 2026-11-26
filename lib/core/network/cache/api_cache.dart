import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import 'api_cache_policy_interceptor.dart';
import '../../domain/entities/fetch_mode.dart';
import '../../persistence/app_database.dart';
import 'api_cache_stats.dart';
import 'cache_ttl.dart';
import 'drift_cache_store.dart';

/// The cache of TMDB's responses: a store, the policy that drives it and the
/// two interceptors `ApiClient` adds (`docs/DECISIONS.md`, "Caching").
///
/// Two levels: memory (about 24 MB, an entry at most 1 MB — a detail with
/// everything bundled weighs 100–250 KB) in front of the database
/// ([DriftCacheStore], ~30 MB), so answers survive the app closing and lists
/// and details open offline. What is older than the offline horizon
/// ([CacheTtl.staleHorizon], 30 days) is dropped when the app starts.
@real
@LazySingleton()
class ApiCache {
  ApiCache(AppDatabase database) : this.withStore(_twoLevel(database));

  /// A cache over [store], with [now] as its clock (tests move it to age saved
  /// answers).
  ApiCache.withStore(this.store, {this.now}) : _enabled = true;

  /// No caching: every request goes to the network. For tests that don't care.
  ApiCache.off() : store = MemCacheStore(), now = null, _enabled = false;

  static CacheStore _twoLevel(AppDatabase database) {
    final disk = DriftCacheStore(database);
    unawaited(disk.purgeOlderThan(CacheTtl.staleHorizon));
    return BackupCacheStore(
      primary: MemCacheStore(maxSize: _maxSize, maxEntrySize: _maxEntry),
      secondary: disk,
    );
  }

  static const int _maxSize = 24 * 1024 * 1024;
  static const int _maxEntry = 1024 * 1024;

  final CacheStore store;

  /// The clock the TTL is measured with (`null`: the real one).
  final DateTime Function()? now;
  final bool _enabled;

  /// What it has done so far.
  final ApiCacheStats stats = ApiCacheStats();

  /// The policy, then the cache itself — added to Dio **after** the locale
  /// interceptor, so the key holds the language and the region, and after
  /// `NetworkStatus`, which a cache hit therefore can't reach (it must not mark
  /// the network reachable).
  late final List<Interceptor> interceptors = !_enabled
      ? const []
      : [
          ApiCachePolicyInterceptor(
            store: store,
            stats: stats,
            now: now,
            revalidate: _revalidate,
          ),
          DioCacheInterceptor(
            options: CacheOptions(
              store: store,
              policy: CachePolicy.noCache,
              maxStale: null,
            ),
          ),
        ];

  Dio? _dio;
  final Set<String> _revalidating = {};

  /// Gives the cache the client it refreshes old answers with (`ApiClient`
  /// calls this once it has built its `Dio`).
  void attach(Dio dio) => _dio = dio;

  /// Stale-while-revalidate: asks the network again for [options]' answer and
  /// saves it, without anyone waiting and without the UI hearing of it. One
  /// refresh per URL at a time; a failure is swallowed (the old answer stays).
  bool _revalidate(RequestOptions options) {
    final dio = _dio;
    if (dio == null) return false;
    final id = options.uri.toString();
    if (!_revalidating.add(id)) return true; // already on its way
    final request = options.copyWith(
      extra: {
        ...options.extra,
        ApiCachePolicyInterceptor.modeKey: FetchMode.refresh,
      },
    );
    unawaited(
      dio
          .fetch<dynamic>(request)
          .then<void>((_) {}, onError: (Object _) {})
          .whenComplete(() => _revalidating.remove(id)),
    );
    return true;
  }

  /// Forgets every saved response ("Clear cache").
  Future<void> clear() => store.clean();

  /// Forgets the saved responses whose path matches [path] (a regular
  /// expression over the request path, query included).
  Future<void> invalidate(RegExp path) => store.deleteFromPath(path);
}
