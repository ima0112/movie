import 'collection_query.dart';
import 'media_type.dart';

/// Where a collection sits in the list the user sees.
enum CollectionGroup {
  /// A place's cinema or series: Turkish series, Bollywood…
  world,

  /// A kind of programme: soaps, anime, reality shows.
  format,

  /// Who it is for: kids.
  occasion,
}

/// What a collection asks TMDB for on one kind of title: **the union** of its
/// [queries]'s results (Soaps are the "telenovela" keyword **or** the Soap
/// genre — one `/discover` request cannot say that, so each is its own query).
class CollectionRule {
  const CollectionRule(this.queries);

  final List<CollectionQuery> queries;

  /// The lowest vote floor among the queries — what a search that must reach
  /// every one of them (Surprise me) can ask at most.
  int get minVoteCount =>
      queries.map((q) => q.minVoteCount).reduce((a, b) => a < b ? a : b);

  factory CollectionRule.fromJson(Map<String, dynamic> json) => CollectionRule([
    for (final q in json['queries'] as List)
      CollectionQuery.fromJson(q as Map<String, dynamic>),
  ]);

  @override
  bool operator ==(Object other) =>
      other is CollectionRule &&
      other.queries.length == queries.length &&
      [
        for (var i = 0; i < queries.length; i++) queries[i] == other.queries[i],
      ].every((same) => same);

  @override
  int get hashCode => Object.hashAll(queries);
}

/// A curated slice of TMDB the genres and vibes cannot express — by origin,
/// language or format — such as Turkish series, Anime or Reality shows.
///
/// Equal by [id], like [Genre] and [Vibe]. A collection exists for the kinds
/// of title that have a rule: K-dramas are TV only, Bollywood movies only,
/// Anime both.
class Collection {
  const Collection({
    required this.id,
    required this.group,
    this.movie,
    this.tv,
    this.inTastes = true,
    this.hidesVibes = const {},
  });

  /// Stable identifier (`turkish_series`) — never a display name; the UI
  /// reads its label from `AppLocalizations`.
  final String id;
  final CollectionGroup group;

  /// The rule per kind of title; `null` where the collection doesn't exist.
  final CollectionRule? movie;
  final CollectionRule? tv;

  /// Whether the user can keep it in My Tastes. Kids is a suggestion
  /// collection only: it neither feeds the history nor is learned from.
  final bool inTastes;

  /// `Vibe.id`s that make no sense with this collection (For kids: Gangster,
  /// Revenge…): the quiz doesn't offer them. They only ever leave a list —
  /// nothing sends them to TMDB.
  final Set<String> hidesVibes;

  CollectionRule? ruleFor(MediaType type) => switch (type) {
    MediaType.movie => movie,
    MediaType.tvShow => tv,
  };

  bool isAvailableFor(MediaType type) => ruleFor(type) != null;

  factory Collection.fromJson(Map<String, dynamic> json) {
    CollectionRule? rule(String key) => json[key] == null
        ? null
        : CollectionRule.fromJson(json[key] as Map<String, dynamic>);
    return Collection(
      id: json['id'] as String,
      group: CollectionGroup.values.byName(json['group'] as String),
      movie: rule('movie'),
      tv: rule('tv'),
      inTastes: json['inTastes'] as bool? ?? true,
      hidesVibes: {
        for (final v in (json['hidesVibes'] as List?) ?? const []) v as String,
      },
    );
  }

  @override
  bool operator ==(Object other) => other is Collection && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Collection($id)';
}
