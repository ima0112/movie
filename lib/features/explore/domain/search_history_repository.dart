import '../../../core/domain/entities/result.dart';

/// B2's "Recent" search chips — "last 10... tap to run, long-press to
/// remove; 'Clear all'" (`docs/SCREENS.md` B2).
///
/// Private to the Explore feature (`docs/STRUCTURE.md`:
/// "features/explore/domain/ — SearchHistoryRepository", per CLAUDE.md
/// rule 1's `features/<x>/domain/` — "entities and contracts private to
/// that feature"): nothing outside Explore (B2) has any reason to know
/// what someone searched for, unlike `UserLibraryRepository`/
/// `TasteProfileRepository`, which live in `core/domain` precisely
/// because more than one feature needs them.
abstract interface class SearchHistoryRepository {
  /// Most-recent-first, capped at 10 — reactive so B2's chips update
  /// live after [record]/[remove]/[clear], no manual refresh.
  Stream<List<String>> watch();

  /// Records a search. An already-present query moves to the front
  /// instead of duplicating; the list is capped at 10 (oldest dropped).
  /// A blank/whitespace-only query is a no-op — B2 never runs an empty
  /// search worth remembering.
  Future<Result<void>> record(String query);

  /// B2's long-press-to-remove for a single chip.
  Future<Result<void>> remove(String query);

  /// B2's "Clear all".
  Future<Result<void>> clear();
}
