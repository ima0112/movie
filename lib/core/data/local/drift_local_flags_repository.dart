import 'package:injectable/injectable.dart';

import '../../domain/entities/result.dart';
import '../../domain/repositories/local_flags_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent [LocalFlagsRepository]: SQLite (drift) through the app's one
/// [AppDatabase].
@LazySingleton(as: LocalFlagsRepository)
class DriftLocalFlagsRepository implements LocalFlagsRepository {
  DriftLocalFlagsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<bool> isSet(LocalFlag flag) async {
    try {
      final row = await (_db.select(
        _db.localFlagsTable,
      )..where((r) => r.flag.equals(flag.name))).getSingleOrNull();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Result<void>> set(LocalFlag flag) async {
    try {
      await _db
          .into(_db.localFlagsTable)
          .insertOnConflictUpdate(
            LocalFlagsTableCompanion.insert(flag: flag.name),
          );
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }
}
