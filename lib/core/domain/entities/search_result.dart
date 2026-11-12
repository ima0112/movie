import 'media_item.dart';
import 'person.dart';

/// One row of B2's multi-search (`MediaRepository.searchMulti`): a movie or
/// TV show, or a person. TMDB's `/search/multi` mixes all three in one
/// ranked list, so the repository returns them as they come.
///
/// Sealed, so a screen has to say what it does for both kinds.
sealed class SearchResult {
  const SearchResult();
}

/// A movie or TV show.
final class MediaResult extends SearchResult {
  const MediaResult(this.item);

  final MediaItem item;
}

/// A person (actor, director, …): their id, name, photo path and known-for
/// department — enough for a result row that opens D3.
final class PersonResult extends SearchResult {
  const PersonResult(this.person);

  final Person person;
}
