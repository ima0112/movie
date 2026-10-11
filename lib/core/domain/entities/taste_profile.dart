import 'genre.dart';

/// The local user's explicit taste signal — C5 ("My Tastes") reads and
/// writes this directly; the match engine and recommendations read it as
/// one of their inputs (implicit signals from `UserMediaEntry` are a
/// separate, later concern — see `docs/STRUCTURE.md`'s
/// `taste_profile_builder.dart`).
///
/// Shape fixed by the fields C5 exposes: liked/never-want genres (C5:
/// "mutually exclusive with the above" — enforcing that exclusivity is
/// C5's job when it writes both sets, not this entity's), liked vibes
/// (C5's 4-column grid of the 16 vibes), and "how far back" as a single
/// starting year (C5's slider).
class TasteProfile {
  const TasteProfile({
    required this.likedGenres,
    required this.vetoedGenres,
    required this.likedVibes,
    required this.yearFrom,
    required this.updatedAt,
  });

  final Set<Genre> likedGenres;

  /// "Genres you never want" (C5) — e.g. excluded from Discover/Explore
  /// results and the match engine.
  final Set<Genre> vetoedGenres;

  /// Vibe ids from `assets/vibes.json` (`docs/STRUCTURE.md`'s
  /// `vibe_catalog.dart`) — kept as plain strings here rather than a
  /// `Vibe` entity, since that catalog lives in `match_engine`'s own
  /// domain and `core/domain` can't depend on a feature (rule 1). Never
  /// a display name (CLAUDE.md rule 15) — presentation translates an id
  /// via `VibeLocalization`.
  final Set<String> likedVibes;

  /// C5's "How far back" slider — titles released before this year are
  /// deprioritized/excluded, depending on where this is consumed.
  final int yearFrom;

  /// When this profile last changed — same purpose as
  /// `UserMediaEntry`/its table's `updatedAt`: a future sync step's
  /// change marker, not shown in any UI.
  final DateTime updatedAt;

  /// Whether this profile carries enough explicit signal to drive
  /// Surprise me / the Matcher directly — `TasteProfileBuilder.build`'s
  /// own "an explicit TasteProfile exists → used" case now gates on
  /// this instead of a bare non-null check.
  ///
  /// [vetoedGenres] alone doesn't count: a veto only narrows what gets
  /// excluded, it says nothing about what to actually suggest. Neither
  /// does [yearFrom] alone — every profile always has *some* value
  /// there (C5's slider has no "unset" position), so it's never a
  /// meaningful signal on its own. A profile with only one or both of
  /// those (e.g. only the year slider ever touched) is treated the
  /// same as no profile at all: it falls through to the inferred-from-
  /// My-List case, or the quiz.
  bool get isUsableForSuggestions =>
      likedGenres.isNotEmpty || likedVibes.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is TasteProfile &&
      _setEquals(other.likedGenres, likedGenres) &&
      _setEquals(other.vetoedGenres, vetoedGenres) &&
      _setEquals(other.likedVibes, likedVibes) &&
      other.yearFrom == yearFrom &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(likedGenres),
    Object.hashAllUnordered(vetoedGenres),
    Object.hashAllUnordered(likedVibes),
    yearFrom,
    updatedAt,
  );

  @override
  String toString() =>
      'TasteProfile(liked: $likedGenres, vetoed: $vetoedGenres, '
      'vibes: $likedVibes, yearFrom: $yearFrom, updatedAt: $updatedAt)';
}

/// Order-independent set content equality — a local stand-in for
/// `package:collection`'s `SetEquality` so this file doesn't need a new
/// dependency (CLAUDE.md "What NOT to do": don't add one without
/// discussing it) just for `==`.
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
