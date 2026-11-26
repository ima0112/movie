/// What the response cache did, counted — for tests and for anyone checking in
/// the debug console that opening the same screen twice asked TMDB once.
class ApiCacheStats {
  /// A saved answer that was still current was used (no request).
  int hits = 0;

  /// A cacheable route with nothing current saved: the network was asked.
  int misses = 0;

  /// The user asked for fresh data (`FetchMode.refresh`).
  int refreshes = 0;

  /// Not cached at all: a route outside the list, or `FetchMode.live`.
  int bypasses = 0;

  /// An old-but-usable answer was handed back at once and refreshed behind it
  /// (stale-while-revalidate).
  int revalidations = 0;

  void reset() => hits = misses = refreshes = bypasses = revalidations = 0;

  @override
  String toString() =>
      'ApiCacheStats(hits: $hits, misses: $misses, refreshes: $refreshes, '
      'bypasses: $bypasses, revalidations: $revalidations)';
}
