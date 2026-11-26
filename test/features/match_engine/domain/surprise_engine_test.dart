import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/fetch_mode.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';
import 'package:movies/features/match_engine/domain/surprise_candidates.dart';
import 'package:movies/features/match_engine/domain/surprise_engine_impl.dart';
import 'package:movies/features/match_engine/domain/surprise_request.dart';
import 'package:movies/features/match_engine/domain/surprise_scoring.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';

const _genreCycle = ['action', 'comedy', 'drama', 'horror', 'family', 'crime'];

/// A synthetic catalog: [n] titles with 1–2 genres from the cycle, years
/// 1985–2024, votes 60–5000, popularity falling with the id.
List<MediaItem> _catalog(
  int n, {
  MediaType type = MediaType.movie,
  int firstYear = 1985,
  int minVotes = 200,
  List<String> genres = _genreCycle,
}) => [
  for (var i = 1; i <= n; i++)
    _item(
      i,
      type,
      [
        Genre(id: genres[i % genres.length]),
        if (i % 3 == 0) Genre(id: genres[(i + 2) % genres.length]),
      ],
      year: firstYear + (i * 7) % 40,
      votes: minVotes + (i * 37) % 4800,
      rating: 6.1 + (i % 25) / 10,
    ),
];

MediaItem _item(
  int id,
  MediaType type,
  List<Genre> genres, {
  required int year,
  required int votes,
  required double rating,
}) {
  final date = DateTime(year, 6);
  return type == MediaType.movie
      ? Movie(
          id: id,
          title: 'Movie $id',
          posterUrl: 'https://img/$id.jpg',
          genres: genres,
          releaseDate: date,
          voteAverage: rating,
          voteCount: votes,
          popularity: 10000.0 - id,
        )
      : TvShow(
          id: id,
          title: 'Show $id',
          posterUrl: 'https://img/$id.jpg',
          genres: genres,
          releaseDate: date,
          voteAverage: rating,
          voteCount: votes,
          popularity: 10000.0 - id,
        );
}

/// Serves the catalog through `discoverPage` honouring the filter fields the
/// engine sets, and records every call so tests can check what was asked.
class _FakeRepository implements MediaRepository {
  _FakeRepository(this.catalog);

  final List<MediaItem> catalog;
  final calls = <({DiscoverFilter filter, int page})>[];
  final discoverModes = <FetchMode>[];
  final detailModes = <FetchMode>[];
  bool failDiscover = false;
  Set<int> failDetailIds = {};
  bool failAllDetails = false;
  WatchProviders providers = WatchProviders.empty;

  @override
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  }) async {
    calls.add((filter: filter, page: page));
    discoverModes.add(FetchMode.current);
    if (failDiscover) return Failure(FailureReason.network);
    var items = catalog.where((m) {
      if (filter.type != null && m.type != filter.type) return false;
      final ids = m.genres.map((g) => g.id).toSet();
      if (filter.withGenres.isNotEmpty &&
          !filter.withGenres.any((g) => ids.contains(g.id))) {
        return false;
      }
      if (filter.withoutGenres.any((g) => ids.contains(g.id))) return false;
      final year = m.releaseDate!.year;
      if (filter.yearFrom != null && year < filter.yearFrom!) return false;
      if (filter.yearTo != null && year > filter.yearTo!) return false;
      if ((m.voteCount ?? 0) < filter.minVoteCount) return false;
      if (filter.minVoteAverage != null &&
          m.voteAverage < filter.minVoteAverage!) {
        return false;
      }
      return true;
    }).toList();
    items.sort(
      (a, b) => filter.sortBy == DiscoverSortBy.rating
          ? b.voteAverage.compareTo(a.voteAverage)
          : (b.popularity ?? 0).compareTo(a.popularity ?? 0),
    );
    final totalPages = (items.length / 20).ceil();
    final start = (page - 1) * 20;
    final slice = start >= items.length
        ? <MediaItem>[]
        : items.sublist(start, min(start + 20, items.length));
    return Success(
      DiscoverPage(
        items: slice,
        page: page,
        totalPages: totalPages,
        totalResults: items.length,
      ),
    );
  }

  @override
  Future<Result<MediaDetail>> detail(MediaKey key, {String? regionCode}) async {
    detailModes.add(FetchMode.current);
    if (failAllDetails || failDetailIds.contains(key.tmdbId)) {
      return Failure(FailureReason.network);
    }
    final item = catalog.firstWhere((m) => m.key == key);
    return Success(
      item is Movie
          ? MovieDetail(
              item: item,
              overview: '',
              cast: const [],
              crew: const [],
              videos: const [],
              similar: const [],
              imdbId: null,
              tagline: 'tagline ${item.id}',
              status: 'Released',
              watchProviders: providers,
              runtimeMinutes: 110,
              releaseDate: item.releaseDate,
              certification: null,
            )
          : TvShowDetail(
              item: item,
              overview: '',
              cast: const [],
              crew: const [],
              videos: const [],
              similar: const [],
              imdbId: null,
              tagline: 'tagline ${item.id}',
              status: 'Ended',
              watchProviders: providers,
              creators: const [],
              seasons: const [],
              numberOfEpisodes: 10,
              episodeRuntimeMinutes: 45,
              firstAirDate: item.releaseDate,
              lastAirDate: item.releaseDate,
              inProduction: false,
              certification: null,
            ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Vibe _vibe(String id, List<String> genres) => Vibe(
  id: id,
  icon: 'x',
  movie: VibeRule(genreIds: genres, keywordIds: const []),
  tv: VibeRule(genreIds: genres, keywordIds: const []),
);

final _vibes = VibeCatalog([
  _vibe('monster', ['horror']),
  _vibe('feel_good', ['comedy', 'family']),
]);

SurpriseRequest _request({
  MediaType type = MediaType.movie,
  ParticipantAnswers? answers,
  int seed = 1,
  Set<MediaKey> exclude = const {},
  Map<Genre, int> affinity = const {},
}) => SurpriseRequest(
  type: type,
  answers:
      answers ?? const ParticipantAnswers(participantId: 'me', yearFrom: 1980),
  sessionId: 's1',
  region: 'ES',
  seed: seed,
  excludeKeys: exclude,
  genreAffinity: affinity,
);

Future<SurpriseBatch> _resolve(
  _FakeRepository repo,
  SurpriseRequest request,
) async {
  final result = await SurpriseEngineImpl(
    repo,
  ).resolve(request, vibeCatalog: _vibes);
  return (result as Success<SurpriseBatch>).value;
}

Set<MediaKey> _keys(SurpriseBatch b) => {
  for (final s in b.suggestions) s.item.key,
};

String _mainGenre(SurpriseSuggestion s) =>
    s.item.genres.firstOrNull?.id ?? '_none';

void main() {
  test(
    'discover pages are asked live (never cached); details are not',
    () async {
      final repo = _FakeRepository(_catalog(200));

      await _resolve(repo, _request());

      expect(repo.discoverModes, isNotEmpty);
      expect(repo.discoverModes.toSet(), {FetchMode.live});
      expect(repo.detailModes, isNotEmpty);
      expect(repo.detailModes.toSet(), {FetchMode.cached});
    },
  );

  group('a batch', () {
    test(
      'has five suggestions with details and a "% for you" of 60–98',
      () async {
        final repo = _FakeRepository(_catalog(200));

        final batch = await _resolve(repo, _request());

        expect(batch.suggestions, hasLength(5));
        expect(batch.relaxations, isEmpty);
        for (final s in batch.suggestions) {
          expect(s.detail, isA<MovieDetail>());
          expect(s.affinityPercent, inInclusiveRange(60, 98));
        }
        final percents = batch.suggestions
            .map((s) => s.affinityPercent)
            .toList();
        expect(percents, [...percents]..sort((a, b) => b.compareTo(a)));
      },
    );

    test('is deterministic for a seed, and varies with it', () async {
      final repo = _FakeRepository(_catalog(300));

      final a = _keys(await _resolve(repo, _request(seed: 7)));
      final b = _keys(await _resolve(repo, _request(seed: 7)));
      final others = <Set<MediaKey>>[
        for (var seed = 8; seed < 14; seed++)
          _keys(await _resolve(repo, _request(seed: seed))),
      ];

      expect(a, b);
      expect(
        others.any((o) => !(o.length == a.length && o.containsAll(a))),
        isTrue,
      );
    });
  });

  group('"other 5" in the same session', () {
    test('two consecutive batches share no title', () async {
      final repo = _FakeRepository(_catalog(300));
      final first = await _resolve(repo, _request(seed: 1));

      final second = await _resolve(
        repo,
        _request(seed: 2, exclude: _keys(first)),
      );

      expect(first.suggestions, hasLength(5));
      expect(second.suggestions, hasLength(5));
      expect(_keys(first).intersection(_keys(second)), isEmpty);
    });

    test('five batches in a row never repeat a title', () async {
      final repo = _FakeRepository(_catalog(300));
      final seen = <MediaKey>{};

      for (var i = 0; i < 5; i++) {
        final batch = await _resolve(
          repo,
          _request(seed: i, exclude: {...seen}),
        );
        expect(batch.suggestions, hasLength(5));
        expect(seen.intersection(_keys(batch)), isEmpty, reason: 'batch $i');
        seen.addAll(_keys(batch));
      }
    });

    test(
      'titles without a poster sink below every title that has one',
      () async {
        final repo = _FakeRepository([
          ..._catalog(60),
          for (var i = 1000; i < 1030; i++)
            Movie(
              id: i,
              title: 'No poster $i',
              posterUrl: null,
              genres: const [Genre(id: 'action')],
              releaseDate: DateTime(2020),
              voteAverage: 9,
              voteCount: 9000,
              popularity: 99999,
            ),
        ]);

        final batch = await _resolve(repo, _request());

        expect(batch.suggestions.every((s) => s.item.id < 1000), isTrue);
      },
    );
  });

  group('typical questionnaires', () {
    test(
      'five typical combinations each gather 15 or more candidates',
      () async {
        final combos = <ParticipantAnswers>[
          const ParticipantAnswers(participantId: 'me', yearFrom: 1980),
          ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1990,
            excludedGenres: {const Genre(id: 'horror')},
            vibeIds: const {'feel_good'},
          ),
          const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1985,
            yearTo: 2020,
            vibeIds: {'monster', 'feel_good'},
            maxRuntimeMinutes: 150,
          ),
          ParticipantAnswers(
            participantId: 'me',
            yearFrom: 2000,
            excludedGenres: {
              const Genre(id: 'drama'),
              const Genre(id: 'crime'),
            },
            platformIds: const {8},
            includeRentBuy: true,
          ),
          const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            vibeIds: {'feel_good'},
            platformIds: {8, 337},
          ),
        ];

        for (final answers in combos) {
          final batch = await _resolve(
            _FakeRepository(_catalog(600)),
            _request(answers: answers),
          );
          expect(
            batch.candidateCount,
            greaterThanOrEqualTo(15),
            reason: '$answers',
          );
          expect(batch.suggestions, hasLength(5), reason: '$answers');
        }
      },
    );
  });

  group('collections', () {
    final collections = CollectionCatalog.fromJsonString(
      File('assets/collections.json').readAsStringSync(),
    );
    Future<SurpriseBatch> resolveWith(
      _FakeRepository repo,
      Set<String> ids, {
      MediaType type = MediaType.tvShow,
      Set<String> vibeIds = const {},
    }) async {
      final result = await SurpriseEngineImpl(repo).resolve(
        _request(
          type: type,
          answers: ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            collectionIds: ids,
            vibeIds: vibeIds,
          ),
        ),
        vibeCatalog: _vibes,
        collectionCatalog: collections,
      );
      return (result as Success<SurpriseBatch>).value;
    }

    test('every query carries the collection, with its own lower vote floor '
        'and no rating sort', () async {
      final repo = _FakeRepository(_catalog(300));
      await resolveWith(repo, {'turkish_series'});

      expect(repo.calls, isNotEmpty);
      for (final c in repo.calls) {
        expect(c.filter.collection, collections.byId('turkish_series'));
        expect(c.filter.minVoteCount, lessThanOrEqualTo(30));
        expect(c.filter.sortBy, DiscoverSortBy.popularity);
      }
    });

    test('two collections make two sets of queries; one that does not exist '
        'for the kind of title is ignored; more than two are cut', () async {
      final repo = _FakeRepository(_catalog(300));
      await resolveWith(repo, {'turkish_series', 'anime'});
      expect(
        {for (final c in repo.calls) c.filter.collection?.id},
        {'turkish_series', 'anime'},
      );

      final other = _FakeRepository(_catalog(300));
      await resolveWith(other, {'bollywood'}); // movies only; this is TV
      expect({for (final c in other.calls) c.filter.collection}, {null});

      final many = _FakeRepository(_catalog(300));
      await resolveWith(many, {'turkish_series', 'anime', 'soaps'});
      expect(
        {for (final c in many.calls) c.filter.collection?.id}.length,
        ParticipantAnswers.maxCollections,
      );
    });

    test('relaxing never drops the collection', () async {
      final repo = _FakeRepository(const []);
      await resolveWith(repo, {'turkish_series'}, vibeIds: {'feel_good'});

      expect(repo.calls.length, greaterThan(3)); // it did relax
      expect(
        repo.calls.every((c) => c.filter.collection?.id == 'turkish_series'),
        isTrue,
      );
    });
  });

  group('hard filters', () {
    final answers = ParticipantAnswers(
      participantId: 'me',
      yearFrom: 1990,
      yearTo: 2015,
      excludedGenres: {Genre(id: 'horror')},
      vibeIds: {'feel_good'},
      maxRuntimeMinutes: 120,
      platformIds: {8, 337},
    );

    test('every call carries vetoes, platforms, streaming, runtime and the '
        'latest year', () async {
      final repo = _FakeRepository(_catalog(300));

      await _resolve(repo, _request(answers: answers));

      expect(repo.calls, isNotEmpty);
      for (final c in repo.calls) {
        expect(c.filter.withoutGenres, {const Genre(id: 'horror')});
        expect(c.filter.withWatchProviders, {8, 337});
        expect(c.filter.monetizationTypes, {WatchMonetization.flatrate});
        expect(c.filter.maxRuntimeMinutes, 120);
        expect(c.filter.yearTo, lessThanOrEqualTo(2015));
        expect(c.filter.minVoteAverage, greaterThanOrEqualTo(6.0));
      }
    });

    test('"include rent and buy" adds them — with platforms, and with '
        '"All platforms" (no list: any service of the region)', () async {
      final repo = _FakeRepository(_catalog(300));
      await _resolve(
        repo,
        _request(
          answers: const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            platformIds: {8},
            includeRentBuy: true,
          ),
        ),
      );
      for (final c in repo.calls) {
        expect(c.filter.withWatchProviders, {8});
        expect(c.filter.monetizationTypes, {
          WatchMonetization.flatrate,
          WatchMonetization.rent,
          WatchMonetization.buy,
        });
      }

      final all = _FakeRepository(_catalog(300));
      await _resolve(
        all,
        _request(
          answers: const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            includeRentBuy: true,
          ),
        ),
      );
      for (final c in all.calls) {
        expect(c.filter.withWatchProviders, isEmpty);
        expect(c.filter.monetizationTypes, {
          WatchMonetization.flatrate,
          WatchMonetization.rent,
          WatchMonetization.buy,
        });
      }
    });

    test('"All platforms" is still a hard filter: any service of the region '
        'by subscription — never a title available nowhere', () async {
      final repo = _FakeRepository(_catalog(300));

      await _resolve(repo, _request());

      expect(repo.calls, isNotEmpty);
      for (final c in repo.calls) {
        expect(c.filter.withWatchProviders, isEmpty);
        expect(c.filter.monetizationTypes, {WatchMonetization.flatrate});
      }
    });

    test('a vetoed genre never appears in a suggestion', () async {
      final repo = _FakeRepository(_catalog(300));

      final batch = await _resolve(repo, _request(answers: answers));

      for (final s in batch.suggestions) {
        expect(s.item.genres.map((g) => g.id), isNot(contains('horror')));
      }
    });

    test('TV: status applies, runtime does not', () async {
      final repo = _FakeRepository(_catalog(300, type: MediaType.tvShow));

      await _resolve(
        repo,
        _request(
          type: MediaType.tvShow,
          answers: const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            maxRuntimeMinutes: 90,
            tvStatus: DiscoverTvStatus.ended,
          ),
        ),
      );

      for (final c in repo.calls) {
        expect(c.filter.type, MediaType.tvShow);
        expect(c.filter.tvStatus, DiscoverTvStatus.ended);
        expect(c.filter.maxRuntimeMinutes, isNull);
      }
    });
  });

  group('relaxation ladder', () {
    final withVibe = ParticipantAnswers(
      participantId: 'me',
      yearFrom: 1990,
      excludedGenres: {Genre(id: 'horror')},
      vibeIds: {'feel_good'},
      platformIds: {8},
      maxRuntimeMinutes: 100,
    );

    test('enough candidates: nothing is relaxed', () async {
      final batch = await _resolve(
        _FakeRepository(_catalog(300)),
        _request(answers: withVibe),
      );

      expect(batch.relaxations, isEmpty);
    });

    test('few votes: lowering the floor is the first and only step', () async {
      final repo = _FakeRepository(
        _catalog(90, minVotes: 60).map((m) {
          return _item(
            m.id,
            m.type,
            m.genres,
            year: m.releaseDate!.year,
            votes: 60 + m.id % 80, // 60–139: under 150, over 50
            rating: m.voteAverage,
          );
        }).toList(),
      );

      final batch = await _resolve(repo, _request(answers: withVibe));

      expect(batch.relaxations, [SurpriseRelaxation.lowerVoteCount]);
      expect(batch.suggestions, hasLength(5));
    });

    test('old titles only: votes, then vibes, then years — in that order, and '
        'the earliest year moves only 10 back', () async {
      final repo = _FakeRepository(
        List.generate(
          30,
          (i) => _item(
            i + 1,
            MediaType.movie,
            [Genre(id: _genreCycle[(i + 1) % _genreCycle.length])],
            year: 1985, // before 1990, after 1980
            votes: 2000,
            rating: 7.5,
          ),
        ),
      );

      final batch = await _resolve(repo, _request(answers: withVibe));

      expect(batch.relaxations, [
        SurpriseRelaxation.lowerVoteCount,
        SurpriseRelaxation.dropVibes,
        SurpriseRelaxation.widenYears,
      ]);
      expect(batch.suggestions, isNotEmpty);
      expect(repo.calls.map((c) => c.filter.yearFrom).toSet(), {1990, 1980});
    });

    test('nothing even then: an empty batch — and vetoes, platforms and '
        'runtime were never loosened to get there', () async {
      final repo = _FakeRepository(const []);

      final batch = await _resolve(repo, _request(answers: withVibe));

      expect(batch.isEmpty, isTrue);
      expect(batch.relaxations, hasLength(3));
      for (final c in repo.calls) {
        expect(c.filter.withoutGenres, {const Genre(id: 'horror')});
        expect(c.filter.withWatchProviders, {8});
        expect(c.filter.monetizationTypes, {WatchMonetization.flatrate});
        expect(c.filter.maxRuntimeMinutes, 100);
      }
    });
  });

  group('selection', () {
    test('at most two of the same main genre', () async {
      final repo = _FakeRepository(_catalog(300));

      for (var seed = 0; seed < 8; seed++) {
        final batch = await _resolve(repo, _request(seed: seed));
        final counts = <String, int>{};
        for (final s in batch.suggestions) {
          counts[_mainGenre(s)] = (counts[_mainGenre(s)] ?? 0) + 1;
        }
        expect(
          counts.values.every((c) => c <= 2),
          isTrue,
          reason: 'seed $seed',
        );
      }
    });

    test('every chosen vibe is represented', () async {
      final repo = _FakeRepository(_catalog(300));
      const answers = ParticipantAnswers(
        participantId: 'me',
        yearFrom: 1980,
        vibeIds: {'monster', 'feel_good'},
      );

      for (var seed = 0; seed < 6; seed++) {
        final batch = await _resolve(
          repo,
          _request(answers: answers, seed: seed),
        );
        final matched = {
          for (final s in batch.suggestions) ...s.matchedVibeIds,
        };
        expect(
          matched,
          containsAll({'monster', 'feel_good'}),
          reason: 'seed $seed',
        );
      }
    });

    test('one wildcard outside the liked genres', () async {
      final repo = _FakeRepository(_catalog(300));

      for (var seed = 0; seed < 6; seed++) {
        final batch = await _resolve(
          repo,
          _request(
            seed: seed,
            affinity: {const Genre(id: 'drama'): 4},
          ),
        );
        expect(
          batch.suggestions.any(
            (s) => s.item.genres.every((g) => g.id != 'drama'),
          ),
          isTrue,
          reason: 'seed $seed',
        );
      }
    });

    test('taste orders without excluding: liked genres lead, others still '
        'appear', () async {
      final repo = _FakeRepository(_catalog(300));
      var liked = 0;
      var total = 0;

      for (var seed = 0; seed < 10; seed++) {
        final batch = await _resolve(
          repo,
          _request(
            seed: seed,
            affinity: {const Genre(id: 'crime'): 5},
          ),
        );
        for (final s in batch.suggestions) {
          total++;
          if (s.item.genres.any((g) => g.id == 'crime')) liked++;
        }
      }

      // crime is about a fifth of the catalog; the taste lifts it well above
      // that…
      expect(liked / total, greaterThan(0.35));
      // …without turning the batch into only crime.
      expect(liked / total, lessThan(0.75));
    });
  });

  group('pages', () {
    test(
      'after the first page, more are drawn at random, never past 25',
      () async {
        final repo = _FakeRepository(_catalog(1200));

        await _resolve(repo, _request());

        final pages = repo.calls.map((c) => c.page).toList();
        expect(pages.where((p) => p == 1), isNotEmpty);
        expect(pages.any((p) => p > 1), isTrue);
        expect(
          pages.every((p) => p <= SurpriseCandidateSource.maxPageDepth),
          isTrue,
        );
      },
    );

    test(
      'pickPages: distinct, sorted, within the depth, none for one page',
      () {
        for (var seed = 0; seed < 50; seed++) {
          final pages = SurpriseCandidateSource.pickPages(400, Random(seed));
          expect(pages.toSet(), hasLength(pages.length));
          expect(pages, [...pages]..sort());
          expect(pages.every((p) => p > 1 && p <= 25), isTrue);
        }
        expect(SurpriseCandidateSource.pickPages(1, Random(1)), isEmpty);
        expect(SurpriseCandidateSource.pickPages(0, Random(1)), isEmpty);
        expect(
          SurpriseCandidateSource.pickPages(2, Random(1)),
          everyElement(2),
        );
      },
    );

    test('the draw favours the first pages', () {
      final rng = Random(3);
      var early = 0;
      var late = 0;
      for (var i = 0; i < 500; i++) {
        for (final p in SurpriseCandidateSource.pickPages(500, rng)) {
          if (p <= 6) early++;
          if (p > 19) late++;
        }
      }
      expect(early, greaterThan(late));
    });
  });

  group('where to watch', () {
    test('each suggestion carries the services it is on that the answers '
        'accept — only the picked ones when there are any', () async {
      final repo = _FakeRepository(_catalog(120));
      repo.providers = const WatchProviders(
        flatrate: ['Netflix', 'Max'],
        rent: ['Apple TV'],
        buy: [],
        link: null,
        ids: {'Netflix': 8, 'Max': 1899, 'Apple TV': 2},
      );

      final all = await _resolve(repo, _request());
      expect(all.suggestions.first.platforms.map((p) => p.name), [
        'Netflix',
        'Max',
      ]);

      final picked = await _resolve(
        repo,
        _request(
          answers: const ParticipantAnswers(
            participantId: 'me',
            yearFrom: 1980,
            platformIds: {8},
          ),
        ),
      );
      expect(picked.suggestions.first.platforms.map((p) => p.name), [
        'Netflix',
      ]);
    });
  });

  group('details and failures', () {
    test('a suggestion whose detail fails is replaced, still five', () async {
      final repo = _FakeRepository(_catalog(300));
      final first = await _resolve(repo, _request(seed: 4));

      repo.failDetailIds = {first.suggestions.first.item.id};
      final again = await _resolve(repo, _request(seed: 4));

      expect(again.suggestions, hasLength(5));
      expect(
        again.suggestions.map((s) => s.item.id),
        isNot(contains(first.suggestions.first.item.id)),
      );
    });

    test('offline: a Failure, not an empty batch', () async {
      final repo = _FakeRepository(_catalog(300))..failDiscover = true;

      final result = await SurpriseEngineImpl(
        repo,
      ).resolve(_request(), vibeCatalog: _vibes);

      expect(result, isA<Failure<SurpriseBatch>>());
    });

    test('no detail at all: a Failure', () async {
      final repo = _FakeRepository(_catalog(300))..failAllDetails = true;

      final result = await SurpriseEngineImpl(
        repo,
      ).resolve(_request(), vibeCatalog: _vibes);

      expect(result, isA<Failure<SurpriseBatch>>());
    });
  });

  group('scoring', () {
    test('a Bayesian rating: a 9.0 on 5000 votes beats a 9.0 on 5', () {
      SurpriseCandidate c(int id, int votes) => SurpriseCandidate(
        _item(
          id,
          MediaType.movie,
          const [Genre(id: 'drama')],
          year: 2000,
          votes: votes,
          rating: 9,
        ),
      );
      final few = c(1, 5);
      final many = c(2, 5000);
      final filler = SurpriseCandidate(
        _item(
          3,
          MediaType.movie,
          const [Genre(id: 'drama')],
          year: 2000,
          votes: 800,
          rating: 6.5,
        ),
      );

      final scored = SurpriseScoring.score(
        [few, many, filler],
        _request(),
        chosenVibes: 0,
        rng: Random(1),
      );

      final byId = {for (final s in scored) s.candidate.item.id: s.score};
      expect(byId[2]!, greaterThan(byId[1]!));
    });

    test('percent maps the lowest score to 60 and the highest to 98', () {
      SurpriseCandidate c(int id) => SurpriseCandidate(
        _item(id, MediaType.movie, const [], year: 2000, votes: 100, rating: 7),
      );
      final all = [
        ScoredCandidate(c(1), 0.2),
        ScoredCandidate(c(2), 0.7),
        ScoredCandidate(c(3), 1.2),
      ];

      expect(SurpriseScoring.percent(0.2, all, 60, 98), 60);
      expect(SurpriseScoring.percent(1.2, all, 60, 98), 98);
      expect(SurpriseScoring.percent(0.7, all, 60, 98), 79);
    });
  });
}
