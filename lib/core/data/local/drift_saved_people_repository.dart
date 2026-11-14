import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/person.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/saved_people_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent [SavedPeopleRepository]: SQLite (drift) through the app's one
/// [AppDatabase].
///
/// `@LazySingleton`: D3 writes it and My List reads it, so they share one
/// instance (and the one connection).
@LazySingleton(as: SavedPeopleRepository)
class DriftSavedPeopleRepository implements SavedPeopleRepository {
  DriftSavedPeopleRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Person>> watchAll() {
    return _db
        .select(_db.savedPeopleTable)
        .watch()
        .map(
          (rows) => rows.map(_toPerson).toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            ),
        );
  }

  @override
  Stream<bool> watchIsSaved(int personId) {
    final query = _db.select(_db.savedPeopleTable)
      ..where((row) => row.tmdbId.equals(personId));
    return query.watch().map((rows) => rows.isNotEmpty).distinct();
  }

  @override
  Future<Result<void>> save(Person person) async {
    try {
      await _db
          .into(_db.savedPeopleTable)
          .insertOnConflictUpdate(
            SavedPeopleTableCompanion.insert(
              tmdbId: Value(person.id),
              name: person.name,
              profilePath: Value(person.profilePath),
              knownForDepartment: Value(person.knownForDepartment),
            ),
          );
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> remove(int personId) async {
    try {
      await (_db.delete(
        _db.savedPeopleTable,
      )..where((row) => row.tmdbId.equals(personId))).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  Person _toPerson(SavedPersonRow row) => Person(
    id: row.tmdbId,
    name: row.name,
    profilePath: row.profilePath,
    knownForDepartment: row.knownForDepartment,
  );
}
