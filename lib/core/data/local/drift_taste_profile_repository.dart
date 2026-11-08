import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/taste_profile.dart';
import '../../domain/repositories/taste_profile_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent implementation of [TasteProfileRepository] — SQLite
/// (drift) via [AppDatabase]. Always reads/writes row `id = 0`
/// ([TasteProfileTable]'s single-row convention).
///
/// `@LazySingleton`, not per-screen — see CLAUDE.md rule 10: C5, B5's
/// summary card, and the match engine all share this same connection.
@LazySingleton(as: TasteProfileRepository)
class DriftTasteProfileRepository implements TasteProfileRepository {
  DriftTasteProfileRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<TasteProfile?> watch() {
    final query = _db.select(_db.tasteProfileTable)
      ..where((row) => row.id.equals(0));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toProfile(row),
    );
  }

  @override
  Future<Result<void>> save(TasteProfile profile) async {
    try {
      await _db
          .into(_db.tasteProfileTable)
          .insertOnConflictUpdate(
            TasteProfileTableCompanion.insert(
              // See `DriftUserProfileRepository.save`'s comment on the
              // same pattern — `id`'s `DEFAULT 0` is ignored by SQLite's
              // own rowid autogeneration for a sole `INTEGER PRIMARY
              // KEY` column unless the value is passed explicitly.
              id: const Value(0),
              likedGenres: _serializeGenres(profile.likedGenres),
              vetoedGenres: _serializeGenres(profile.vetoedGenres),
              likedVibes: profile.likedVibes.join(','),
              yearFrom: profile.yearFrom,
              updatedAt: DateTime.now(),
            ),
          );
      return const Success(null);
    } catch (e) {
      return Failure('Could not save $profile: $e');
    }
  }

  static TasteProfile _toProfile(TasteProfileRow row) {
    return TasteProfile(
      likedGenres: _deserializeGenres(row.likedGenres),
      vetoedGenres: _deserializeGenres(row.vetoedGenres),
      likedVibes: row.likedVibes.isEmpty
          ? const {}
          : row.likedVibes.split(',').toSet(),
      yearFrom: row.yearFrom,
      updatedAt: row.updatedAt,
    );
  }

  /// `id:name` pairs, comma-joined — see [TasteProfileTable.likedGenres]'
  /// doc comment for why both fields are stored.
  static String _serializeGenres(Set<Genre> genres) =>
      genres.map((g) => '${g.id}:${g.name}').join(',');

  static Set<Genre> _deserializeGenres(String serialized) {
    if (serialized.isEmpty) return const {};
    return serialized.split(',').map((pair) {
      final separator = pair.indexOf(':');
      return Genre(
        id: pair.substring(0, separator),
        name: pair.substring(separator + 1),
      );
    }).toSet();
  }
}
