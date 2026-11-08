import '../../../core/domain/entities/media_type.dart';

/// One vibe's genre/keyword targeting for a single media type.
///
/// `docs/DECISIONS.md` section 5 ("Vibe catalog"): "Each vibe has two
/// mapping columns (movie and TV) to genres and TMDB keyword IDs."
class VibeRule {
  const VibeRule({required this.genreIds, required this.keywordIds});

  /// Normalized `Genre.id` values (`core/domain/entities/genre.dart`),
  /// not raw TMDB genre ids.
  final List<String> genreIds;

  /// TMDB keyword ids for this vibe/type (e.g. Superhero's
  /// `superhero`/`based-on-comic`). **Always empty today** —
  /// `assets/vibes.json` ships with every `keywordIds` array empty;
  /// resolving them needs a real TMDB keyword search, which only
  /// happens once the network layer is wired up (`MediaRepository`,
  /// not yet implemented for real — see `docs/STRUCTURE.md`). Nothing
  /// downstream should treat an empty list here as an error.
  final List<String> keywordIds;

  factory VibeRule.fromJson(Map<String, dynamic> json) {
    return VibeRule(
      genreIds: List<String>.from(json['genreIds'] as List),
      keywordIds: List<String>.from(json['keywordIds'] as List),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VibeRule &&
      _listEquals(other.genreIds, genreIds) &&
      _listEquals(other.keywordIds, keywordIds);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(genreIds), Object.hashAll(keywordIds));
}

/// One of the 16 "vibes" from `docs/DECISIONS.md` section 5 ("Vibe
/// catalog") — the Matcher/quiz's "Vibes I DO want (3)" question and
/// C5's "Vibes you like" 4-column grid both work off this catalog (see
/// `vibe_catalog.dart`).
///
/// Two genres/keyword identity, equal by [id] alone — same convention
/// as `Genre` (`core/domain/entities/genre.dart`): a fixed, enumerable
/// catalog where identity is what matters, not a snapshot comparison.
class Vibe {
  const Vibe({
    required this.id,
    required this.name,
    required this.icon,
    required this.movie,
    required this.tv,
    this.maxReleaseYear,
    this.minVoteAverage,
  });

  final String id;
  final String name;

  /// The `AppIcons` constant name this vibe renders with (e.g.
  /// `"vibeFeelGood"` → `AppIcons.vibeFeelGood`) — a plain `String`, not
  /// `IconData`: this file is pure domain (no Flutter), per
  /// `docs/DECISIONS.md` section 5 ("Pure domain service: no Flutter,
  /// no Firebase..."). Resolving the string back to a real icon is a
  /// presentation-layer lookup.
  final String icon;

  final VibeRule movie;
  final VibeRule tv;

  /// Classic's own filter — "release_date.lte=1999" in
  /// `docs/DECISIONS.md`'s own example. `null` for every other vibe.
  final int? maxReleaseYear;

  /// Classic's own filter — "vote_average.gte=7.5" in the same example.
  /// `null` for every other vibe.
  final double? minVoteAverage;

  VibeRule ruleFor(MediaType type) => switch (type) {
    MediaType.movie => movie,
    MediaType.tvShow => tv,
  };

  /// Whether this vibe actually targets anything for [type] yet —
  /// genres, keywords, or a standalone filter like Classic's. Used by
  /// `VibeCatalog.availableFor` rather than assuming every vibe applies
  /// to both types forever: once real TMDB keywords are resolved, a
  /// vibe that turns out to have nothing meaningful for one type
  /// (empty genres *and* keywords, no filter) simply stops showing up
  /// there, with no list to maintain by hand.
  bool isMeaningfulFor(MediaType type) {
    final rule = ruleFor(type);
    return rule.genreIds.isNotEmpty ||
        rule.keywordIds.isNotEmpty ||
        maxReleaseYear != null ||
        minVoteAverage != null;
  }

  factory Vibe.fromJson(Map<String, dynamic> json) {
    return Vibe(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      movie: VibeRule.fromJson(json['movie'] as Map<String, dynamic>),
      tv: VibeRule.fromJson(json['tv'] as Map<String, dynamic>),
      maxReleaseYear: json['maxReleaseYear'] as int?,
      minVoteAverage: (json['minVoteAverage'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) => other is Vibe && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Vibe($id, $name)';
}

/// Order-sensitive list content equality — a local stand-in for
/// `package:collection`'s `ListEquality`, same reasoning as
/// `LibraryStats`' and `UserMediaEntry`'s own copies of this helper: no
/// new dependency for just this, and this file must stay Flutter-free.
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
