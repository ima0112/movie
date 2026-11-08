import '../entities/person.dart';
import '../entities/result.dart';

/// Read access to D3 (Person detail).
///
/// Source of truth: `docs/STRUCTURE.md` and `docs/SCREENS.md` D3. Kept
/// separate from [MediaRepository] (not a method on it) — a person
/// isn't a `MediaItem`/`MediaKey` (movie/TV show), so it doesn't fit
/// that repository's own vocabulary; `docs/DECISIONS.md` §2 already
/// called this out as infra ("DTO + mapper + datasource call") built
/// ahead of a consumer, not an interface method.
///
/// `domain` contract only, per CLAUDE.md rule 2 — the only place that
/// actually talks to TMDB is `data/repositories/tmdb_person_repository
/// .dart`.
abstract interface class PersonRepository {
  /// D3's full detail for one person.
  Future<Result<PersonDetail>> detail(int personId);
}
