import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/result.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent implementation of [OnboardingRepository] — SQLite (drift)
/// via [AppDatabase]. Always reads/writes row `id = 0`
/// ([OnboardingTable]'s single-row convention, same as
/// [UserProfileTable]).
///
/// `@LazySingleton`, no environment split — `app/router.dart`'s own
/// top-level `redirect` reads [isCompleted] through `getIt` on every
/// navigation. [isCompleted] starts `false` (the safe "hasn't finished
/// onboarding" default) until [load] resolves — see this class' own
/// interface doc comment for why it's synchronous at all.
@LazySingleton(as: OnboardingRepository)
class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository(this._db);

  final AppDatabase _db;

  bool _isCompleted = false;

  @override
  bool get isCompleted => _isCompleted;

  @override
  Future<void> load() async {
    final query = _db.select(_db.onboardingTable)
      ..where((row) => row.id.equals(0));
    final row = await query.getSingleOrNull();
    _isCompleted = row?.completed ?? false;
  }

  @override
  Future<Result<void>> markCompleted() async {
    try {
      await _db
          .into(_db.onboardingTable)
          .insertOnConflictUpdate(
            // Same `id: const Value(0)` pinning as
            // DriftUserProfileRepository.save — see that method's own
            // doc comment for why this is needed, not just the
            // column's `withDefault`.
            OnboardingTableCompanion.insert(
              id: const Value(0),
              completed: const Value(true),
            ),
          );
      _isCompleted = true;
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }
}
