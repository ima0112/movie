import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/surprise_history_entry.dart';
import '../../domain/repositories/surprise_history_repository.dart';

/// In-memory stand-in for [SurpriseHistoryRepository] — a fast test double
/// (unannotated: only the drift one is registered). Same rules as the real
/// one: one row per title per session (the first wins), newest first.
class InMemorySurpriseHistoryRepository implements SurpriseHistoryRepository {
  final List<SurpriseHistoryEntry> _entries = [];

  @override
  Future<Result<void>> recordShown(List<SurpriseHistoryEntry> entries) async {
    for (final entry in entries) {
      final exists = _entries.any(
        (e) => e.key == entry.key && e.sessionId == entry.sessionId,
      );
      if (!exists) _entries.add(entry);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> setOutcome({
    required String sessionId,
    required MediaKey key,
    required SurpriseOutcome outcome,
  }) async {
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e.key == key &&
          e.sessionId == sessionId &&
          outcome.canReplace(e.outcome)) {
        _entries[i] = e.withOutcome(outcome);
      }
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markBatchRerolled({
    required String sessionId,
    required int batch,
  }) async {
    final inBatch = _entries.where(
      (e) => e.sessionId == sessionId && e.batch == batch,
    );
    if (inBatch.any((e) => e.outcome.isPick)) return const Success(null);
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e.sessionId == sessionId &&
          e.batch == batch &&
          e.outcome == SurpriseOutcome.viewed) {
        _entries[i] = e.withOutcome(SurpriseOutcome.rerolled);
      }
    }
    return const Success(null);
  }

  @override
  Future<Result<Set<MediaKey>>> shownKeys(
    MediaType type, {
    String? sessionId,
    DateTime? since,
  }) async => Success({
    for (final e in _entries)
      if (e.key.type == type &&
          (sessionId == null || e.sessionId == sessionId) &&
          (since == null || !e.shownAt.isBefore(since)))
        e.key,
  });

  @override
  Future<Result<List<SurpriseHistoryEntry>>> all() async => Success(
    _entries.toList()..sort((a, b) => b.shownAt.compareTo(a.shownAt)),
  );

  @override
  Future<Result<void>> clear() async {
    _entries.clear();
    return const Success(null);
  }
}
