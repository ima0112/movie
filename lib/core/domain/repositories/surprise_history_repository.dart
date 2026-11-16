import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/result.dart';
import '../entities/surprise_history_entry.dart';

/// Local memory of what Surprise me has shown (`docs/DECISIONS.md` §5,
/// "Surprise me engine"): lets "other 5" and a redone questionnaire skip
/// what the user already saw, and gives the engine a taste signal. Drift in
/// the app, in memory in tests; nothing leaves the device.
abstract interface class SurpriseHistoryRepository {
  /// Records [entries] as shown (outcome `shown`). A title shown again in
  /// the same session keeps its first row.
  Future<Result<void>> recordShown(List<SurpriseHistoryEntry> entries);

  /// What came of [key] in [sessionId]. A no-op if it was never shown there.
  Future<Result<void>> setOutcome({
    required String sessionId,
    required MediaKey key,
    required SurpriseOutcome outcome,
  });

  /// The titles of [type] already shown: in [sessionId] alone when given
  /// (what "other 5" must skip), and/or since [since] (what a redone
  /// questionnaire skips: the last 30 days). With neither, every one.
  Future<Result<Set<MediaKey>>> shownKeys(
    MediaType type, {
    String? sessionId,
    DateTime? since,
  });

  /// Every row, newest first — the engine's taste signal.
  Future<Result<List<SurpriseHistoryEntry>>> all();

  /// Forgets everything (Settings' "clear my data").
  Future<Result<void>> clear();
}
