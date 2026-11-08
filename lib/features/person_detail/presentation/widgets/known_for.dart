import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/person.dart';

/// D3's "Known for": "carousel of their 6 most popular titles"
/// (`docs/SCREENS.md` D3). [MediaItem] has no dedicated popularity
/// field (same gap `FakeMediaRepository.discover`'s own `sortBy:
/// popularity` comment already notes) — `voteAverage` descending is the
/// closest available proxy. A person can carry more than one credit for
/// the same title (e.g. acted in and also wrote it); this dedupes by
/// the title's own identity first, so "Known for" never repeats one.
extension PersonKnownFor on List<MediaCredit> {
  List<MediaItem> knownForItems({int limit = 6}) {
    final seen = <MediaItem>{};
    final items = <MediaItem>[];
    for (final credit in this) {
      if (seen.add(credit.item)) items.add(credit.item);
    }
    items.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return items.take(limit).toList();
  }
}
