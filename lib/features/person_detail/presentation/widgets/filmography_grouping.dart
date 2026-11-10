import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/person.dart';

/// D3's filmography segmented control — `docs/SCREENS.md` D3: "filter
/// chips All · Movies · TV Shows". [asDirector] is the one option this
/// task's own task description adds beyond that: offered only when
/// [PersonFilmography.availableSegments] says it has directing credits, and
/// narrows to directing credits specifically (not every crew department).
enum FilmographySegment { all, movies, tvShows, asDirector }

/// One year's worth of filmography rows, already in the order D3 shows
/// them: [PersonFilmography.groupedByYear]'s own result, newest year
/// first, with undated credits always first of all.
class FilmographyYearGroup {
  const FilmographyYearGroup({required this.year, required this.credits});

  /// `null` for undated credits — CLAUDE.md rule 15: this is domain
  /// code, so it carries the raw year, never a display string.
  /// Presentation renders `null` as "Coming soon"
  /// (`personFilmographyComingSoon`).
  final int? year;
  final List<MediaCredit> credits;
}

/// [credits] filtering/grouping for D3's filmography section — pulled
/// out of any widget so `person_detail_cubit_test.dart`'s sibling, this
/// task's own "test de la agrupación por año", can exercise it with no
/// Flutter import at all.
extension PersonFilmography on List<MediaCredit> {
  /// The tabs worth showing for these credits: "All", plus each other
  /// segment only when it has credits **and** isn't the same list as "All"
  /// (a person with only movies gets no "Movies" tab, one who never directed
  /// gets no "As director" tab). A single tab ("All" alone) means no tabs at
  /// all — the caller hides the control then.
  List<FilmographySegment> get availableSegments => [
    FilmographySegment.all,
    for (final segment in [
      FilmographySegment.movies,
      FilmographySegment.tvShows,
      FilmographySegment.asDirector,
    ])
      if (_isProperSubset(filteredBy(segment))) segment,
  ];

  bool _isProperSubset(List<MediaCredit> subset) =>
      subset.isNotEmpty && subset.length < length;

  /// Newest first: undated ("Coming soon") credits ahead of every dated one,
  /// then by release year descending (stable within a year).
  List<MediaCredit> get newestFirst => [
    for (final group in groupedByYear) ...group.credits,
  ];

  /// [segment]'s own subset. [FilmographySegment.asDirector] narrows to
  /// `job == 'Director'` specifically — the segment is called "As
  /// director", not "As crew", because a person notable enough to need
  /// this tab at all is notable for directing specifically, not for
  /// every department (editor, producer...) TMDB's `crew` list happens
  /// to carry.
  List<MediaCredit> filteredBy(FilmographySegment segment) => switch (segment) {
    FilmographySegment.all => this,
    FilmographySegment.movies => where((c) => c.item is Movie).toList(),
    FilmographySegment.tvShows => where((c) => c.item is TvShow).toList(),
    FilmographySegment.asDirector => where((c) => c.job == 'Director').toList(),
  };

  /// Groups by `item.releaseDate`'s own year, descending — undated
  /// credits ("Coming soon") always come first, ahead of every real
  /// year, since they're upcoming work rather than something already
  /// placeable in the past.
  List<FilmographyYearGroup> get groupedByYear {
    final undated = <MediaCredit>[];
    final byYear = <int, List<MediaCredit>>{};
    for (final credit in this) {
      final year = credit.item.releaseDate?.year;
      if (year == null) {
        undated.add(credit);
      } else {
        (byYear[year] ??= []).add(credit);
      }
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      if (undated.isNotEmpty)
        FilmographyYearGroup(year: null, credits: undated),
      for (final year in years)
        FilmographyYearGroup(year: year, credits: byYear[year]!),
    ];
  }
}
