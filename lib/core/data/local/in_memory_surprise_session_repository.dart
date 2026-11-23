import 'dart:async';

import '../../domain/entities/result.dart';
import '../../domain/entities/surprise_session.dart';
import '../../domain/repositories/surprise_session_repository.dart';

/// In-memory stand-in for [SurpriseSessionRepository] — a fast test double
/// (unannotated: only the drift one is registered).
class InMemorySurpriseSessionRepository implements SurpriseSessionRepository {
  final Map<String, SurpriseSession> _sessions = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<SurpriseSession> _sorted() =>
      _sessions.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Future<Result<void>> recordBatch(SurpriseSession session) async {
    final existing = _sessions[session.sessionId];
    _sessions[session.sessionId] = existing == null
        ? session
        : existing.withRelaxations(session.relaxations);
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<List<SurpriseSession>>> all() async => Success(_sorted());

  @override
  Stream<List<SurpriseSession>> watchAll() {
    // Not `async*`: cancelling a generator parked on a broadcast stream never
    // completes.
    late final StreamController<List<SurpriseSession>> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<List<SurpriseSession>>(
      onListen: () {
        controller.add(_sorted());
        changes = _changes.stream.listen((_) => controller.add(_sorted()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Result<void>> clear() async {
    _sessions.clear();
    _changes.add(null);
    return const Success(null);
  }
}
