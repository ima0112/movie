import '../../../core/domain/entities/search_result.dart';
import '../../../core/domain/text/search_text.dart';

/// B2's ordering rule (`docs/SCREENS.md` B2): titles keep TMDB's ranked order
/// and **people sort last, unless there's an exact name match** — a person
/// whose name is exactly [query] (ignoring case, accents and extra space:
/// "zoe saldana" is Zoë Saldaña) goes to the very top, so searching "Zendaya" finds Zendaya first,
/// while "dune" shows the film before any person called Dune.
///
/// Stable within each group. Pure domain code: no Flutter, no network.
List<SearchResult> orderSearchResults(
  String query,
  List<SearchResult> results,
) {
  final exact = <SearchResult>[];
  final titles = <SearchResult>[];
  final people = <SearchResult>[];
  for (final result in results) {
    switch (result) {
      case MediaResult():
        titles.add(result);
      case PersonResult(:final person):
        (equalsSearch(person.name, query) ? exact : people).add(result);
    }
  }
  return [...exact, ...titles, ...people];
}
