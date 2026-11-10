import '../../../core/domain/entities/search_result.dart';

/// B2's ordering rule (`docs/SCREENS.md` B2): titles keep TMDB's ranked order
/// and **people sort last, unless there's an exact name match** — a person
/// whose name is exactly [query] (case-insensitive, ignoring surrounding
/// space) goes to the very top, so searching "Zendaya" finds Zendaya first,
/// while "dune" shows the film before any person called Dune.
///
/// Stable within each group. Pure domain code: no Flutter, no network.
List<SearchResult> orderSearchResults(
  String query,
  List<SearchResult> results,
) {
  final needle = query.trim().toLowerCase();
  final exact = <SearchResult>[];
  final titles = <SearchResult>[];
  final people = <SearchResult>[];
  for (final result in results) {
    switch (result) {
      case MediaResult():
        titles.add(result);
      case PersonResult(:final person):
        (person.name.trim().toLowerCase() == needle ? exact : people).add(
          result,
        );
    }
  }
  return [...exact, ...titles, ...people];
}
