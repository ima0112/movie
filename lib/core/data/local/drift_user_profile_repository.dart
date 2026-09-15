import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent implementation of [UserProfileRepository] — SQLite (drift)
/// via [AppDatabase]. Always reads/writes row `id = 0`
/// ([UserProfileTable]'s single-row convention).
///
/// `@LazySingleton`, not per-screen — see CLAUDE.md rule 10: B5's header,
/// H10's edit sheet, and anywhere a room shows "You'll join as Daniel"
/// all share this same connection.
@LazySingleton(as: UserProfileRepository)
class DriftUserProfileRepository implements UserProfileRepository {
  DriftUserProfileRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<UserProfile?> watch() {
    final query = _db.select(_db.userProfileTable)
      ..where((row) => row.id.equals(0));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toProfile(row),
    );
  }

  @override
  Future<Result<void>> save(UserProfile profile) async {
    try {
      await _db
          .into(_db.userProfileTable)
          .insertOnConflictUpdate(
            UserProfileTableCompanion.insert(
              // `id`'s `withDefault(Constant(0))` alone isn't enough to
              // keep this a single row: `id` is the table's sole
              // `INTEGER PRIMARY KEY`, which SQLite treats as an alias
              // for `rowid` and auto-assigns (1, 2, 3…) whenever no
              // explicit value is given, ignoring the column's own
              // `DEFAULT` clause. Passing it here is what actually pins
              // every row to `0`.
              id: const Value(0),
              displayName: profile.displayName,
              initialColor: profile.initialColor,
              updatedAt: DateTime.now(),
            ),
          );
      return const Success(null);
    } catch (e) {
      return Failure('Could not save $profile: $e');
    }
  }

  static UserProfile _toProfile(UserProfileRow row) {
    return UserProfile(
      displayName: row.displayName,
      initialColor: row.initialColor,
    );
  }
}
