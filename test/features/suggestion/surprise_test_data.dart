// ignore_for_file: prefer_initializing_formals
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'dart:async';

import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';
import 'package:movies/features/match_engine/domain/surprise_engine.dart';
import 'package:movies/features/match_engine/domain/surprise_request.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';

Movie testMovie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: 8,
);

/// A suggestion of [item] (a bare movie detail around it).
SurpriseSuggestion suggestionOf(MediaItem item, {int percent = 80}) =>
    SurpriseSuggestion(
      detail: MovieDetail(
        item: item,
        overview: '',
        cast: const [],
        crew: const [],
        videos: const [],
        similar: const [],
        imdbId: null,
        tagline: null,
        status: 'Released',
        watchProviders: WatchProviders.empty,
        runtimeMinutes: 100,
        releaseDate: null,
        certification: null,
      ),
      affinityPercent: percent,
    );

/// A batch of [size] suggestions, ids `[first, first + size)`.
SurpriseBatch batchOf(
  int size, {
  int first = 0,
  List<SurpriseRelaxation> relaxations = const [],
  String sessionId = 's',
}) => SurpriseBatch(
  sessionId: sessionId,
  suggestions: [
    for (var i = first; i < first + size; i++) suggestionOf(testMovie(i)),
  ],
  relaxations: relaxations,
);

/// Like [batchOf], every title with the genre [genreId].
SurpriseBatch batchOfGenre(int size, String genreId, {int first = 0}) =>
    SurpriseBatch(
      sessionId: 's',
      suggestions: [
        for (var i = first; i < first + size; i++)
          suggestionOf(
            Movie(
              id: i,
              title: 'Movie $i',
              posterUrl: null,
              genres: [Genre(id: genreId)],
              releaseDate: null,
              voteAverage: 8,
            ),
          ),
      ],
    );

/// A [SurpriseEngine] whose `resolve` takes exactly [delay] (or never
/// completes) and answers with the next of [results], repeating the last —
/// lets tests control the engine's side of the race against the cubit's
/// minimum/maximum durations, and see every request it received.
class FakeSurpriseEngine implements SurpriseEngine {
  FakeSurpriseEngine({
    this.delay = Duration.zero,
    List<Result<SurpriseBatch>> results = const [],
    this.neverCompletes = false,
  }) : _results = results;

  FakeSurpriseEngine.returning(
    SurpriseBatch batch, {
    Duration delay = Duration.zero,
  }) : this(delay: delay, results: [Success(batch)]);

  final Duration delay;
  final bool neverCompletes;
  final List<Result<SurpriseBatch>> _results;
  final requests = <SurpriseRequest>[];

  int get callCount => requests.length;

  @override
  Future<Result<SurpriseBatch>> resolve(
    SurpriseRequest request, {
    required VibeCatalog vibeCatalog,
    CollectionCatalog collectionCatalog = const CollectionCatalog([]),
  }) async {
    requests.add(request);
    if (neverCompletes) return Completer<Result<SurpriseBatch>>().future;
    await Future<void>.delayed(delay);
    if (_results.isEmpty) return Failure(FailureReason.unknown);
    return _results[(requests.length - 1).clamp(0, _results.length - 1)];
  }
}
