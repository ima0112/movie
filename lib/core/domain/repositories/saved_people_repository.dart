import '../entities/person.dart';
import '../entities/result.dart';

/// The people the user saved from a person's detail (D3) — My List's People
/// tab. A device-local list, no account, kept as a small snapshot of each
/// [Person] (id, name, photo, department) so the tab draws without a network
/// call.
///
/// Like `UserLibraryRepository`, it exposes `Stream`s and nobody caches the
/// whole list: the heart on D3 subscribes to "is this one person saved?", the
/// tab to the whole list (CLAUDE.md rule 10).
///
/// Lives in `core/domain` because two features need it: D3 writes it and My
/// List reads it.
abstract interface class SavedPeopleRepository {
  /// Every saved person, by name A–Z (case-insensitive); emits again after
  /// every [save] and [remove].
  Stream<List<Person>> watchAll();

  /// Whether [personId] is saved; emits again when that changes.
  Stream<bool> watchIsSaved(int personId);

  /// Saves [person] (saving an already-saved person refreshes its snapshot,
  /// never duplicates it).
  Future<Result<void>> save(Person person);

  /// Forgets the person; a no-op when they weren't saved.
  Future<Result<void>> remove(int personId);
}
