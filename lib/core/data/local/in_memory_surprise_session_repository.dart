import '../../domain/entities/result.dart';
import '../../domain/entities/surprise_session.dart';
import '../../domain/repositories/surprise_session_repository.dart';

/// In-memory stand-in for [SurpriseSessionRepository] — a fast test double
/// (unannotated: only the drift one is registered).
class InMemorySurpriseSessionRepository implements SurpriseSessionRepository {
  final Map<String, SurpriseSession> _sessions = {};

  @override
  Future<Result<void>> recordBatch(SurpriseSession session) async {
    final existing = _sessions[session.sessionId];
    _sessions[session.sessionId] = existing == null
        ? session
        : existing.withRelaxations(session.relaxations);
    return const Success(null);
  }

  @override
  Future<Result<List<SurpriseSession>>> all() async => Success(
    _sessions.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
  );

  @override
  Future<Result<void>> clear() async {
    _sessions.clear();
    return const Success(null);
  }
}
