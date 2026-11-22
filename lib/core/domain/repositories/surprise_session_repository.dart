import '../entities/result.dart';
import '../entities/surprise_session.dart';

/// Local record of what each Surprise-me session asked for — the other half of
/// `SurpriseHistoryRepository` (what it showed). Drift in the app, in memory in
/// tests; nothing leaves the device. Cleared with the Surprise-me history.
abstract interface class SurpriseSessionRepository {
  /// Records [session]. A session already recorded (a later batch of it) keeps
  /// its first answers and gains the relaxation steps of [session].
  Future<Result<void>> recordBatch(SurpriseSession session);

  /// Every session, newest first.
  Future<Result<List<SurpriseSession>>> all();

  /// Forgets everything.
  Future<Result<void>> clear();
}
