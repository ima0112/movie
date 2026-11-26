import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/fetch_mode.dart';
import 'api_cache_stats.dart';
import 'cache_ttl.dart';

/// Decides, request by request, what `DioCacheInterceptor` (which comes right
/// after it) does with the response cache.
///
/// The package has one threshold — "a saved answer is usable or it isn't" — and
/// the app needs to tell **current** (within the route's TTL) from **old but
/// still better than nothing** (past it, served only if the network fails). So
/// this reads the saved answer's date itself and picks the package's policy:
///
/// | request | saved answer | policy |
/// |---|---|---|
/// | route not in [CacheTtl.rules], or `FetchMode.live` | — | `noCache` (never read, never saved) |
/// | `FetchMode.refresh` | any | `refreshForceCache`: ask the network, save the answer |
/// | `FetchMode.cached` | younger than the TTL | `forceCache`: use it, no request |
/// | `FetchMode.cached` | none, or past the TTL | `refreshForceCache`: ask, save |
///
/// Every cached route also gets `hitCacheOnNetworkFailure`: if the network can't
/// be reached, an old saved answer (up to [CacheTtl.staleHorizon]) is handed back
/// instead of an error. `NetworkStatus` still hears about the failure first, so
/// the offline banner shows.
///
/// The cache key is the package's default — a hash of the **final** URL, path,
/// parameters, `language` and `region` included (`LocaleInterceptor` runs before
/// this), so a change of language or region can't return the previous context's
/// data. It holds no header, so never the bearer token.
class ApiCachePolicyInterceptor extends Interceptor {
  ApiCachePolicyInterceptor({
    required this.store,
    required this.stats,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final CacheStore store;
  final ApiCacheStats stats;
  final DateTime Function() _now;

  /// The `RequestOptions.extra` key the data layer puts the [FetchMode] under.
  static const String modeKey = 'pickme_fetch_mode';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final rule = CacheTtl.ruleFor(options.path);
    final mode = options.extra[modeKey] is FetchMode
        ? options.extra[modeKey] as FetchMode
        : FetchMode.cached;

    final CachePolicy policy;
    if (rule == null || mode == FetchMode.live) {
      stats.bypasses++;
      policy = CachePolicy.noCache;
    } else if (mode == FetchMode.refresh) {
      stats.refreshes++;
      policy = CachePolicy.refreshForceCache;
    } else {
      final saved = await store.get(_keyOf(options));
      final current =
          saved != null && _now().difference(saved.responseDate) < rule.ttl;
      if (current) {
        stats.hits++;
        if (kDebugMode) debugPrint('⚡ cache ${options.uri}');
      } else {
        stats.misses++;
      }
      policy = current ? CachePolicy.forceCache : CachePolicy.refreshForceCache;
    }

    options.extra.addAll(
      CacheOptions(
        store: store,
        policy: policy,
        maxStale: CacheTtl.staleHorizon,
        hitCacheOnNetworkFailure: true,
      ).toExtra(),
    );
    handler.next(options);
  }

  String _keyOf(RequestOptions options) =>
      CacheOptions.defaultCacheKeyBuilder(url: options.uri);
}
