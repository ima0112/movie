/// What may be cached, and for how long — the one place both are decided
/// (`docs/DECISIONS.md`, "Caching").
///
/// **TTL** (time to live) is how long a saved response counts as current: within
/// it the saved answer is used without a request; past it the network is asked
/// again. The values are the app's own, kept close to what TMDB itself announces
/// (`Cache-Control: max-age`: about 5 min for trending, 1.5 h for discover, 3.8 h
/// for a detail).
///
/// A **list of what is cached**, not of what isn't: a route not matched by a rule
/// here is never saved — a new endpoint stays uncached until someone decides how
/// long its answer may live. `/search/multi` is deliberately absent (it depends on
/// what the user types).
class CacheRule {
  const CacheRule(this.pattern, this.ttl);

  /// Matched against the request's path (`/movie/603`, no host, no query).
  final RegExp pattern;
  final Duration ttl;
}

abstract final class CacheTtl {
  /// Home's and Explore's fixed lists (trending, now playing, popular…).
  static const Duration homeLists = Duration(minutes: 10);

  /// `discover`, behind sections, filters and listings.
  static const Duration discover = Duration(minutes: 15);

  /// "Because you like …" seeds.
  static const Duration recommendations = Duration(hours: 1);

  /// A movie or TV show with everything bundled, its seasons, videos and where
  /// to watch it.
  static const Duration detail = Duration(hours: 6);

  /// A person, the streaming-service lists, TMDB's own configuration.
  static const Duration slowChanging = Duration(hours: 24);

  /// How long an **old** saved response may still be handed back when the network
  /// fails (and so how long it is kept at all). Well under the six months TMDB's
  /// terms allow caching its data for.
  static const Duration staleHorizon = Duration(days: 30);

  static final List<CacheRule> rules = [
    CacheRule(
      RegExp(
        r'^/(trending/(all|movie|tv)/week|movie/(now_playing|top_rated|upcoming)'
        r'|tv/(on_the_air|top_rated|popular))$',
      ),
      homeLists,
    ),
    CacheRule(RegExp(r'^/discover/(movie|tv)$'), discover),
    CacheRule(RegExp(r'^/(movie|tv)/\d+/recommendations$'), recommendations),
    CacheRule(
      RegExp(
        r'^/(movie|tv)/\d+(/videos|/watch/providers)?$|^/tv/\d+/season/\d+$',
      ),
      detail,
    ),
    CacheRule(
      RegExp(r'^/person/\d+$|^/watch/providers/(movie|tv)$|^/configuration$'),
      slowChanging,
    ),
  ];

  /// The rule for [path], or `null` when it is not cached.
  static CacheRule? ruleFor(String path) {
    for (final rule in rules) {
      if (rule.pattern.hasMatch(path)) return rule;
    }
    return null;
  }
}
