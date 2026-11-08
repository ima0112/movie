import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/person.dart';

/// D3's filmography segmented control — `docs/SCREENS.md` D3: "filter
/// chips All · Movies · TV Shows". [asDirector] is the one option this
/// task's own task description adds beyond that: offered only when
/// [PersonFilmography.hasBothCastAndCrew] says so, and narrows to
/// directing credits specifically (not every crew department) once
/// picked — see that getter's own doc comment for why.
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
  /// The segmented control's own "and only then" rule
  /// (`docs/SCREENS.md` D3, this task's own addition): an "As director"
  /// option appears only when this person has *both* a cast credit
  /// (acted in something) and a crew credit (worked on something) among
  /// **all** their credits — independent of whatever segment is
  /// currently selected, so switching segments never makes the tab
  /// itself appear or disappear.
  bool get hasBothCastAndCrew =>
      any((c) => c.character != null) && any((c) => c.job != null);

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
