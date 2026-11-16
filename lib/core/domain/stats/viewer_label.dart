import '../entities/genre.dart';
import '../entities/media_type.dart';
import '../entities/user_media_entry.dart';

/// The kind of viewer the user's watch history says they are — the label
/// under their name on You (`docs/SCREENS.md` B5): "Fan of Science Fiction",
/// "Series binger"… Deterministic rules over what they have watched, no AI.
enum ViewerKind {
  /// Fewer than [ViewerLabel.minWatched] titles watched: too early to tell.
  newcomer,

  /// Most of what they watch is TV shows.
  seriesBinger,

  /// Rates low — an average of 2.5 stars or less.
  exigentCritic,

  /// Rates high — an average of 4.5 stars or more.
  enthusiast,

  /// One genre makes up a big share of what they watch (see [ViewerLabel.genre]).
  genreFan,

  /// Most of what they watch is movies.
  cinephile,

  /// Nothing stands out: a bit of everything.
  explorer,
}

/// A [ViewerKind], plus the [genre] for [ViewerKind.genreFan].
class ViewerLabel {
  const ViewerLabel(this.kind, [this.genre]);

  final ViewerKind kind;
  final Genre? genre;

  /// Below this many watched titles it is [ViewerKind.newcomer].
  static const int minWatched = 5;

  /// How many ratings it takes for the critic / enthusiast rules to apply.
  static const int minRated = 5;

  /// Shares (0–1) from which a type or a genre defines the viewer.
  static const double typeShare = 0.6;
  static const double genreShare = 0.3;

  @override
  bool operator ==(Object other) =>
      other is ViewerLabel && other.kind == kind && other.genre == genre;

  @override
  int get hashCode => Object.hash(kind, genre);

  @override
  String toString() => 'ViewerLabel($kind, $genre)';
}

/// The label for [watched] (only watched entries), or `null` when there are
/// none. [topGenre] and [genreShare] come from the genre tally ([genreShare]
/// is the top genre's part of every genre counted, 0–1). The first rule that
/// fits wins, in the order of [ViewerKind].
ViewerLabel? viewerLabelFor(
  List<UserMediaEntry> watched, {
  required Genre? topGenre,
  required double genreShare,
}) {
  if (watched.isEmpty) return null;
  if (watched.length < ViewerLabel.minWatched) {
    return const ViewerLabel(ViewerKind.newcomer);
  }
  final shows = watched.where((e) => e.key.type == MediaType.tvShow).length;
  final tvShare = shows / watched.length;
  final ratings = watched.map((e) => e.rating).whereType<int>().toList();
  final average = ratings.length < ViewerLabel.minRated
      ? null
      : ratings.reduce((a, b) => a + b) / ratings.length;

  if (tvShare >= ViewerLabel.typeShare && shows >= 3) {
    return const ViewerLabel(ViewerKind.seriesBinger);
  }
  if (average != null && average <= 2.5) {
    return const ViewerLabel(ViewerKind.exigentCritic);
  }
  if (average != null && average >= 4.5) {
    return const ViewerLabel(ViewerKind.enthusiast);
  }
  if (topGenre != null && genreShare >= ViewerLabel.genreShare) {
    return ViewerLabel(ViewerKind.genreFan, topGenre);
  }
  if (1 - tvShare >= ViewerLabel.typeShare) {
    return const ViewerLabel(ViewerKind.cinephile);
  }
  return const ViewerLabel(ViewerKind.explorer);
}
