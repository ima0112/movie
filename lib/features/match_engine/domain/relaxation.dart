/// The Matcher's fixed, deterministic relaxation ladder —
/// `docs/DECISIONS.md` section 5 ("Relaxation ladder (fixed,
/// deterministic order)"). Applied one step at a time, in this exact
/// order, only when a `MatchQuery` returns too few candidates — "There
/// is always a result; the screen states what was relaxed."
///
/// Order is the enum's own declaration order ([Relaxation.values]) —
/// nothing here re-sorts it, so whichever future step actually applies
/// these can just iterate `Relaxation.values` in order. Applying a step
/// is out of this file's scope (a `match_engine.dart` job, per
/// `docs/STRUCTURE.md`'s own file tree) — this only names the ladder.
enum Relaxation {
  /// "Drop the least-supported vibe" — the `Vibe.id` with the lowest
  /// weight in `MatchQuery.vibeWeights` stops constraining the score.
  dropLeastSupportedVibe,

  /// "Widen the year range 10 years back" — `MatchQuery.yearFrom - 10`.
  widenYearRange,

  /// "Raise runtime / season limit" — movies: `maxRuntimeMinutes`; TV:
  /// `maxSeasons`. Whichever one `MatchQuery.mediaType` makes relevant.
  raiseRuntimeOrSeasonLimit,

  /// "Lower `vote_count.gte` to 50" — `MatchQuery.voteCountGte`.
  lowerVoteCountThreshold,
}
