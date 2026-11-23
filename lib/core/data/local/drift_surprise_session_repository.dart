import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/genre_catalog.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/surprise_session.dart';
import '../../domain/repositories/surprise_session_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent [SurpriseSessionRepository]: SQLite (drift) through the app's one
/// [AppDatabase]. Lists are stored comma-joined (ids only, never a display
/// name).
@LazySingleton(as: SurpriseSessionRepository)
class DriftSurpriseSessionRepository implements SurpriseSessionRepository {
  DriftSurpriseSessionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> recordBatch(SurpriseSession session) async {
    try {
      final existing = await (_db.select(
        _db.surpriseSessionTable,
      )..where((r) => r.sessionId.equals(session.sessionId))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.surpriseSessionTable)
            .insert(
              SurpriseSessionTableCompanion.insert(
                sessionId: session.sessionId,
                startedAt: session.startedAt,
                mediaType: session.mediaType,
                source: session.source,
                yearFrom: session.yearFrom,
                yearTo: Value(session.yearTo),
                collectionIds: Value(session.collectionIds.join(',')),
                vibeIds: Value(session.vibeIds.join(',')),
                excludedGenres: Value(
                  session.excludedGenres.map((g) => g.id).join(','),
                ),
                platformIds: Value(session.platformIds.join(',')),
                relaxations: Value(session.relaxations.join(',')),
              ),
            );
      } else {
        final merged = {
          ..._split(existing.relaxations),
          ...session.relaxations,
        };
        await (_db.update(
          _db.surpriseSessionTable,
        )..where((r) => r.sessionId.equals(session.sessionId))).write(
          SurpriseSessionTableCompanion(relaxations: Value(merged.join(','))),
        );
      }
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<List<SurpriseSession>>> all() async {
    try {
      final rows = await (_db.select(
        _db.surpriseSessionTable,
      )..orderBy([(r) => OrderingTerm.desc(r.startedAt)])).get();
      return Success([for (final r in rows) _toSession(r)]);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Stream<List<SurpriseSession>> watchAll() =>
      (_db.select(_db.surpriseSessionTable)
            ..orderBy([(r) => OrderingTerm.desc(r.startedAt)]))
          .watch()
          .map((rows) => [for (final r in rows) _toSession(r)]);

  @override
  Future<Result<void>> clear() async {
    try {
      await _db.delete(_db.surpriseSessionTable).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  static Set<String> _split(String joined) =>
      joined.isEmpty ? const {} : joined.split(',').toSet();

  static SurpriseSession _toSession(SurpriseSessionRow r) => SurpriseSession(
    sessionId: r.sessionId,
    startedAt: r.startedAt,
    mediaType: r.mediaType,
    source: r.source,
    yearFrom: r.yearFrom,
    yearTo: r.yearTo,
    collectionIds: _split(r.collectionIds),
    vibeIds: _split(r.vibeIds),
    excludedGenres: {
      for (final id in _split(r.excludedGenres)) ?GenreCatalog.byId(id),
    },
    platformIds: {for (final id in _split(r.platformIds)) int.parse(id)},
    relaxations: _split(r.relaxations),
  );
}
