import 'dart:async';

/// How much a read may lean on what the app already has saved.
///
/// A screen states its intent by wrapping the call in [run]; the data layer's
/// response cache (`core/network/cache/`) reads it through [current]. It rides
/// on a [Zone] value so the repository interfaces (and every fake of them) stay
/// as they are: the domain only says what it wants.
///
/// ```dart
/// final result = await FetchMode.refresh.run(() => repository.getHeroItems());
/// ```
enum FetchMode {
  /// The default: a saved answer that is still current is used; otherwise the
  /// network is asked and the answer saved.
  cached,

  /// The user asked for fresh data (pull-to-refresh): always ask the network and
  /// save what comes back.
  refresh,

  /// Never use or save anything: Surprise me's `discover` calls ask for random
  /// pages that are almost never asked for twice.
  live;

  static const Object _zoneKey = #pickmeFetchMode;

  /// The mode of the code currently running ([cached] outside any [run]).
  static FetchMode get current =>
      Zone.current[_zoneKey] as FetchMode? ?? cached;

  /// Runs [body] with this mode for every read it starts.
  Future<T> run<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_zoneKey: this});
}
