/// How much a read may lean on what the app already has saved.
///
/// Passed down from a screen's intent to the data layer, where the response cache
/// (`core/network/cache/`) acts on it; the domain only says what it wants.
enum FetchMode {
  /// The default: a saved answer that is still current is used; otherwise the
  /// network is asked and the answer saved.
  cached,

  /// The user asked for fresh data (pull-to-refresh): always ask the network and
  /// save what comes back.
  refresh,

  /// Never use or save anything: Surprise me's `discover` calls ask for random
  /// pages that are almost never asked for twice.
  live,
}
