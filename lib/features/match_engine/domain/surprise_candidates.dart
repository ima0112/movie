import 'dart:math';

import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/discover_page.dart';
import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/result.dart';
import '../../../core/domain/repositories/media_repository.dart';
import 'surprise_request.dart';
import 'vibe.dart';

/// What a search is currently allowed to loosen (`SurpriseRelaxation`): only
/// these three knobs ever move — every hard filter is read straight from the
/// request.
class SurpriseSearchState {
  const SurpriseSearchState({
    required this.minVoteCount,
    required this.useVibes,
    required this.yearFrom,
  });

  final int minVoteCount;
  final bool useVibes;
  final int yearFrom;

  SurpriseSearchState copyWith({
    int? minVoteCount,
    bool? useVibes,
    int? yearFrom,
  }) => SurpriseSearchState(
    minVoteCount: minVoteCount ?? this.minVoteCount,
    useVibes: useVibes ?? this.useVibes,
    yearFrom: yearFrom ?? this.yearFrom,
  );
}

/// A gathered title and which of the chosen vibes' queries found it.
class SurpriseCandidate {
  SurpriseCandidate(this.item) : vibeIds = {};

  final MediaItem item;
  final Set<String> vibeIds;

  MediaKey get key => item.key;
}

class SurpriseGather {
  const SurpriseGather(this.candidates, {this.failure});

  final List<SurpriseCandidate> candidates;

  /// Set only when **every** `/discover` call failed (offline): "nothing
  /// found" and "couldn't ask" are different answers.
  final FailureReason? failure;
}

/// Builds and runs the candidate queries of one Surprise-me search
/// (`docs/DECISIONS.md` §5): one query per chosen vibe plus a general one,
/// each with the request's hard filters; the first call of each reads
/// `total_pages`, then a few more pages are drawn at random, biased to the
/// first ones, so every batch looks at different titles.
class SurpriseCandidateSource {
  const SurpriseCandidateSource(this._repository);

  final MediaRepository _repository;

  /// The quality floor on TMDB's own average, always sent.
  static const double minVoteAverage = 6.0;

  /// `vote_average.desc` is only safe with a high vote floor (a handful of
  /// 10/10 votes would top it otherwise), and never once votes were relaxed.
  static const int ratingSortVoteFloor = 300;

  /// How many pages to draw per query after the first.
  static const int extraPages = 2;

  /// Pages beyond this are too deep to be good (TMDB stops at 500).
  static const int maxPageDepth = 25;

  Future<SurpriseGather> gather(
    SurpriseRequest request,
    List<Vibe> vibes,
    SurpriseSearchState state,
    Random rng,
  ) async {
    final queries = [
      if (state.useVibes)
        for (final vibe in vibes)
          (vibe: vibe, filter: _filter(request, state, rng, vibe)),
      (vibe: null, filter: _filter(request, state, rng, null)),
    ];

    final byKey = <MediaKey, SurpriseCandidate>{};
    var calls = 0;
    var failures = 0;
    FailureReason? firstFailure;

    void absorb(Vibe? vibe, List<MediaItem> items) {
      for (final item in items) {
        if (request.excludeKeys.contains(item.key)) continue;
        final poster = item.posterUrl;
        if (poster == null || poster.isEmpty) continue;
        final candidate = byKey.putIfAbsent(
          item.key,
          () => SurpriseCandidate(item),
        );
        if (vibe != null) candidate.vibeIds.add(vibe.id);
      }
    }

    // Phase A: the first page of every query, in parallel.
    final firstPages = await Future.wait([
      for (final q in queries) _repository.discoverPage(q.filter),
    ]);

    final pending = <Future<void>>[];
    for (var i = 0; i < queries.length; i++) {
      calls++;
      final result = firstPages[i];
      switch (result) {
        case Failure<DiscoverPage>(:final reason):
          failures++;
          firstFailure ??= reason;
        case Success<DiscoverPage>(:final value):
          absorb(queries[i].vibe, value.items);
          // Phase B: a few more random pages of the same query.
          for (final page in pickPages(value.totalPages, rng)) {
            calls++;
            pending.add(
              _repository.discoverPage(queries[i].filter, page: page).then((r) {
                switch (r) {
                  case Failure<DiscoverPage>(:final reason):
                    failures++;
                    firstFailure ??= reason;
                  case Success<DiscoverPage>(:final value):
                    absorb(queries[i].vibe, value.items);
                }
              }),
            );
          }
      }
    }
    await Future.wait(pending);

    return SurpriseGather(
      byKey.values.toList(),
      failure: calls > 0 && failures == calls ? firstFailure : null,
    );
  }

  /// [extraPages] distinct pages after the first, `1 + floor(min(total, 25) *
  /// r²)` — squared so the first pages (the better ones) come up more often.
  static List<int> pickPages(int totalPages, Random rng) {
    final depth = min(totalPages, maxPageDepth);
    if (depth <= 1) return const [];
    final pages = <int>{};
    for (var attempt = 0; attempt < extraPages * 6; attempt++) {
      if (pages.length >= extraPages || pages.length >= depth - 1) break;
      final r = rng.nextDouble();
      final page = 1 + (depth * r * r).floor();
      if (page > 1 && page <= depth) pages.add(page);
    }
    return pages.toList()..sort();
  }

  DiscoverFilter _filter(
    SurpriseRequest request,
    SurpriseSearchState state,
    Random rng,
    Vibe? vibe,
  ) {
    final a = request.answers;
    final isMovie = request.type == MediaType.movie;
    final byRating =
        state.minVoteCount >= SurpriseSearchStateDefaults.voteCount &&
        rng.nextBool();
    final vibeMaxYear = vibe?.maxReleaseYear;
    final yearTo = switch ((a.yearTo, vibeMaxYear)) {
      (final int x, final int y) => min(x, y),
      (final int x, null) => x,
      (null, final int y) => y,
      (null, null) => null,
    };
    return DiscoverFilter(
      type: request.type,
      withGenres: vibe?.genresFor(request.type) ?? const {},
      withKeywords: vibe?.keywordIdsFor(request.type) ?? const {},
      withoutGenres: a.excludedGenres,
      yearFrom: state.yearFrom,
      yearTo: yearTo,
      minVoteAverage: max(minVoteAverage, vibe?.minVoteAverage ?? 0),
      maxRuntimeMinutes: isMovie ? a.maxRuntimeMinutes : null,
      tvStatus: isMovie ? null : a.tvStatus,
      sortBy: byRating ? DiscoverSortBy.rating : DiscoverSortBy.popularity,
      minVoteCount: byRating
          ? max(state.minVoteCount, ratingSortVoteFloor)
          : state.minVoteCount,
      withWatchProviders: a.platformIds,
      monetizationTypes: a.platformIds.isEmpty
          ? const {}
          : {
              WatchMonetization.flatrate,
              if (a.includeRentBuy) ...{
                WatchMonetization.rent,
                WatchMonetization.buy,
              },
            },
    );
  }
}

/// The vote floor a search starts at, and the relaxed one.
abstract final class SurpriseSearchStateDefaults {
  static const int voteCount = 150;
  static const int relaxedVoteCount = 50;
}
