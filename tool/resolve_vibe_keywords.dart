// ignore_for_file: avoid_print
//
// Resolves candidate TMDB keyword ids for vibes whose own keyword
// mapping is still empty (`VibeRule.keywordIds`, `assets/vibes.json`
// — `docs/DECISIONS.md` §5's "Vibe catalog"), and reports raw
// `/discover` pool sizes for vibes that work by genre alone. Pure
// Dart, no Flutter, no new dependencies: `dart:io`'s own `HttpClient`
// for the TMDB calls, reusing this package's existing genre-mapping
// code so a vibe's genre side can never drift from what the real app
// would send.
//
// Run with: dart run tool/resolve_vibe_keywords.dart [vibeId ...]
// (no args = every vibe in tool/vibe_search_terms.json). "classic" is
// always computed too — it isn't in that file at all (no genres/
// keywords, just a year+rating cutoff). See tool/README.md.
//
// This script NEVER writes to assets/vibes.json — it only produces a
// report (gitignored, a scratch artifact) for a human to read and
// decide what's actually worth adding, by hand, to the real catalog.
import 'dart:convert';
import 'dart:io';

import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';

const _searchTermsPath = 'tool/vibe_search_terms.json';
const _vibesJsonPath = 'assets/vibes.json';
const _envPath = 'env/dev.json';
const _reportPath = 'tool/out/vibe_keywords_report_round2.md';

/// Top N `/search/keyword` hits kept per candidate term — TMDB already
/// returns these ranked by relevance, and without a cap a broad term
/// like "dream" could pull in dozens of barely-related keywords, each
/// costing more `/discover` calls. Raise this if a vibe's own terms
/// genuinely need it.
const _maxKeywordHitsPerTerm = 5;

/// Fixed pause between every TMDB call.
const _requestPause = Duration(milliseconds: 300);

/// `MatchQuery`'s own default field (`match_query.dart`:
/// `this.voteCountGte = 200`) — `docs/DECISIONS.md` §5's "Fetching
/// candidates": "vote_count.gte=200" on the *first* attempt, before
/// any relaxation (`MatchEngineImpl._relaxedVoteCountGte` only lowers
/// it to 50 on step 4, when nothing matched at all).
///
/// **This is the designed value, not today's actual one.** A
/// pre-existing, already-documented gap (`MatchEngineImpl`'s own doc
/// comment, `DiscoverFilter`'s own doc comment) means `DiscoverFilter`
/// has no `vote_count.gte` field at all — `discoverQueryParams`
/// hardcodes `100` unconditionally, regardless of `MatchQuery
/// .voteCountGte` or which relaxation step fired. Every number this
/// script reports under "≥200" is measuring MatchEngine's *intended*
/// first-attempt threshold, not the `100` the app actually sends
/// today.
const _matchEngineFirstAttemptVoteCountGte = 200;

/// A crossed (keyword + genre) total below this, at the ≥200
/// threshold, is flagged as not very useful on its own.
const _lowVolumeThreshold = 50;

/// A *solo* keyword total at or above this (≥200 threshold), paired
/// with a crossed total below [_lowVolumeThreshold], is flagged
/// separately: broad alone, narrow once ANDed with the vibe's genres.
const _wideSoloThreshold = 500;

Future<void> main(List<String> args) async {
  final token = _readTmdbToken();
  final searchTerms = _readSearchTerms();
  final vibeJsonGenres = _readVibesJsonGenres();

  final requestedIds = args.isNotEmpty ? args : searchTerms.keys.toList();

  final client = HttpClient();
  final keywordResults = <String, List<_KeywordCandidate>>{};
  final genrePoolResults = <_GenrePoolResult>[];

  try {
    for (final vibeId in requestedIds) {
      final entry = searchTerms[vibeId];
      if (entry == null) {
        stderr.writeln('Skipping "$vibeId" — not in $_searchTermsPath.');
        continue;
      }

      final genres = _resolveVibeGenres(vibeId, vibeJsonGenres, entry);
      if (genres == null) {
        stderr.writeln(
          'Skipping "$vibeId" — not in $_vibesJsonPath and no "genres" '
          'override in $_searchTermsPath.',
        );
        continue;
      }

      if (entry.terms.isEmpty) {
        print('== $vibeId (genre pool only, no keyword search) ==');
        final pool = await _resolveGenreOnlyVibe(client, token, vibeId, genres);
        genrePoolResults.add(pool);
      } else {
        print('== $vibeId ==');
        final candidates = await _resolveKeywordVibe(
          client,
          token,
          vibeId,
          entry.terms,
          genres,
        );
        candidates.sort(
          (a, b) => (b.crossMovie.withMinVotes + b.crossTv.withMinVotes)
              .compareTo(a.crossMovie.withMinVotes + a.crossTv.withMinVotes),
        );
        keywordResults[vibeId] = candidates;
        // Every keyword vibe also gets its own genre-pool baseline (no
        // keyword at all) for the summary table — "how big is the
        // pool before any keyword narrows it".
        genrePoolResults.add(
          await _resolveGenreOnlyVibe(client, token, vibeId, genres),
        );
      }
    }

    print('== classic ==');
    final classic = await _resolveClassic(client, token);
    genrePoolResults.add(classic);

    final report = _buildReport(keywordResults, genrePoolResults);
    final file = File(_reportPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(report);
    print('\nReport written to $_reportPath');
  } finally {
    client.close(force: true);
  }
}

Future<List<_KeywordCandidate>> _resolveKeywordVibe(
  HttpClient client,
  String token,
  String vibeId,
  List<String> terms,
  _VibeGenres genres,
) async {
  final candidates = <_KeywordCandidate>[];
  final seenKeywordIds = <int, _KeywordCandidate>{};

  for (final term in terms) {
    final hits = await _searchKeyword(client, token, term);
    for (final hit in hits.take(_maxKeywordHitsPerTerm)) {
      final existing = seenKeywordIds[hit.id];
      if (existing != null) {
        existing.sourceTerms.add(term);
        continue;
      }

      final soloMovie = await _discoverTotal(
        client,
        token,
        MediaType.movie,
        keywordId: hit.id,
      );
      final soloTv = await _discoverTotal(
        client,
        token,
        MediaType.tvShow,
        keywordId: hit.id,
      );
      final crossMovie = await _discoverTotal(
        client,
        token,
        MediaType.movie,
        keywordId: hit.id,
        genreIds: genres.movieTmdbIds,
      );
      final crossTv = await _discoverTotal(
        client,
        token,
        MediaType.tvShow,
        keywordId: hit.id,
        genreIds: genres.tvTmdbIds,
      );

      final candidate = _KeywordCandidate(
        id: hit.id,
        name: hit.name,
        sourceTerms: {term},
        soloMovie: soloMovie,
        soloTv: soloTv,
        crossMovie: crossMovie,
        crossTv: crossTv,
      );
      seenKeywordIds[hit.id] = candidate;
      candidates.add(candidate);
      print(
        '  "$term" -> ${hit.name} (#${hit.id}): '
        'solo movie=$soloMovie tv=$soloTv, '
        'cross movie=$crossMovie tv=$crossTv',
      );
    }
  }

  return candidates;
}

/// No keyword search at all — just how big the pool is for [vibeId]'s
/// own genres (OR'd together, same as a real vibe rule's `with_genres`
/// — `discoverQueryParams`'s own pipe-separated OR form).
Future<_GenrePoolResult> _resolveGenreOnlyVibe(
  HttpClient client,
  String token,
  String vibeId,
  _VibeGenres genres,
) async {
  final movieTotal = await _discoverTotal(
    client,
    token,
    MediaType.movie,
    genreIds: genres.movieTmdbIds,
  );
  final tvTotal = await _discoverTotal(
    client,
    token,
    MediaType.tvShow,
    genreIds: genres.tvTmdbIds,
  );
  print(
    '  movie genreIds=${genres.movieTmdbIds} (${genres.movieGenreIds}) -> '
    '$movieTotal',
  );
  print('  tv genreIds=${genres.tvTmdbIds} (${genres.tvGenreIds}) -> $tvTotal');

  return _GenrePoolResult(
    vibeId: vibeId,
    movieGenreIds: genres.movieTmdbIds,
    tvGenreIds: genres.tvTmdbIds,
    movieTotal: movieTotal,
    tvTotal: tvTotal,
    note: null,
  );
}

/// Classic isn't in `tool/vibe_search_terms.json` at all — the real
/// `assets/vibes.json` "classic" vibe has no genres or keywords either
/// (`movie`/`tv` `genreIds: []`), just `maxReleaseYear: 1999` +
/// `minVoteAverage: 7.5`. Same filters here, by hand.
Future<_GenrePoolResult> _resolveClassic(
  HttpClient client,
  String token,
) async {
  final cutoff = DateTime(1999, 12, 31);
  final movieTotal = await _discoverTotal(
    client,
    token,
    MediaType.movie,
    releaseBefore: cutoff,
    minVoteAverage: 7.5,
  );
  final tvTotal = await _discoverTotal(
    client,
    token,
    MediaType.tvShow,
    releaseBefore: cutoff,
    minVoteAverage: 7.5,
  );
  print('  movie (<=1999, rating>=7.5) -> $movieTotal');
  print('  tv (<=1999, rating>=7.5) -> $tvTotal');

  return _GenrePoolResult(
    vibeId: 'classic',
    movieGenreIds: const [],
    tvGenreIds: const [],
    movieTotal: movieTotal,
    tvTotal: tvTotal,
    note: 'release <= 1999-12-31, vote_average >= 7.5, no genres/keywords',
  );
}

// ---------------------------------------------------------------------------
// TMDB calls
// ---------------------------------------------------------------------------

class _KeywordHit {
  _KeywordHit(this.id, this.name);

  final int id;
  final String name;
}

Future<List<_KeywordHit>> _searchKeyword(
  HttpClient client,
  String token,
  String query,
) async {
  final json = await _getJson(client, token, '/search/keyword', {
    'query': query,
  });
  final results = (json['results'] as List?) ?? const [];
  return [
    for (final r in results)
      _KeywordHit(
        (r as Map<String, dynamic>)['id'] as int,
        r['name'] as String,
      ),
  ];
}

/// Two `/discover` calls, not one: [_VoteSplitTotal.raw] has no
/// `vote_count.gte` at all, [_VoteSplitTotal.withMinVotes] adds
/// `vote_count.gte=$_matchEngineFirstAttemptVoteCountGte` — see that
/// constant's own doc comment for why 200, not the 100
/// `discoverQueryParams` actually sends today. Every total this script
/// reports goes through this one function, so the criterion is always
/// the same across every vibe/section in the report.
Future<_VoteSplitTotal> _discoverTotal(
  HttpClient client,
  String token,
  MediaType type, {
  int? keywordId,
  List<int> genreIds = const [],
  DateTime? releaseBefore,
  double? minVoteAverage,
}) async {
  final raw = await _discoverTotalOnce(
    client,
    token,
    type,
    keywordId: keywordId,
    genreIds: genreIds,
    releaseBefore: releaseBefore,
    minVoteAverage: minVoteAverage,
  );
  final withMinVotes = await _discoverTotalOnce(
    client,
    token,
    type,
    keywordId: keywordId,
    genreIds: genreIds,
    releaseBefore: releaseBefore,
    minVoteAverage: minVoteAverage,
    voteCountGte: _matchEngineFirstAttemptVoteCountGte,
  );
  return _VoteSplitTotal(raw: raw, withMinVotes: withMinVotes);
}

Future<int> _discoverTotalOnce(
  HttpClient client,
  String token,
  MediaType type, {
  int? keywordId,
  List<int> genreIds = const [],
  DateTime? releaseBefore,
  double? minVoteAverage,
  int? voteCountGte,
}) async {
  final path = type == MediaType.movie ? '/discover/movie' : '/discover/tv';
  final query = <String, String>{'include_adult': 'false'};
  if (voteCountGte != null) query['vote_count.gte'] = '$voteCountGte';
  if (keywordId != null) query['with_keywords'] = '$keywordId';
  if (genreIds.isNotEmpty) query['with_genres'] = genreIds.join('|');
  if (releaseBefore != null) {
    final dateField = type == MediaType.movie
        ? 'primary_release_date'
        : 'first_air_date';
    query['$dateField.lte'] = _isoDate(releaseBefore);
  }
  if (minVoteAverage != null) query['vote_average.gte'] = '$minVoteAverage';

  final json = await _getJson(client, token, path, query);
  return (json['total_results'] as int?) ?? 0;
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// GETs [path] from TMDB with [query], retrying with backoff on a 429
/// and pausing [_requestPause] after every successful call.
Future<Map<String, dynamic>> _getJson(
  HttpClient client,
  String token,
  String path,
  Map<String, String> query,
) async {
  final uri = Uri.parse(
    'https://api.themoviedb.org/3$path',
  ).replace(queryParameters: query);

  var attempt = 0;
  while (true) {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();

    if (response.statusCode == 429) {
      final retryAfterHeader = response.headers.value('retry-after');
      final retryAfterSeconds = int.tryParse(retryAfterHeader ?? '');
      final wait = retryAfterSeconds != null
          ? Duration(seconds: retryAfterSeconds)
          : Duration(seconds: 1 << attempt); // 1s, 2s, 4s, 8s...
      await response.drain<void>();
      attempt++;
      if (attempt > 5) {
        throw HttpException('TMDB kept returning 429 for $uri after 5 retries');
      }
      stderr.writeln('  (429 — waiting ${wait.inSeconds}s before retrying)');
      await Future<void>.delayed(wait);
      continue;
    }

    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('TMDB ${response.statusCode} for $uri: $body');
    }

    await Future<void>.delayed(_requestPause);
    return jsonDecode(body) as Map<String, dynamic>;
  }
}

// ---------------------------------------------------------------------------
// Local file reads — env token, search terms, vibes.json's own genres
// ---------------------------------------------------------------------------

String _readTmdbToken() {
  final file = File(_envPath);
  if (!file.existsSync()) {
    stderr.writeln(
      '$_envPath not found — copy env/dev.example.json to env/dev.json '
      'and add your TMDB v4 token first.',
    );
    exit(1);
  }
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final token = json['TMDB_TOKEN'] as String?;
  if (token == null || token.isEmpty) {
    stderr.writeln('$_envPath has no TMDB_TOKEN set.');
    exit(1);
  }
  return token;
}

/// `tool/vibe_search_terms.json`'s own entry for one vibe — `terms`
/// (empty means "genre pool only, no keyword search") plus an optional
/// `genres` override (`{"movie": [TMDB ids], "tv": [TMDB ids]}`),
/// **only consulted when the vibe isn't in `assets/vibes.json` at
/// all** — a vibe that's already there keeps using its own real
/// `genreIds`, resolved through [TmdbGenreMapper] like any other.
class _SearchTermsEntry {
  _SearchTermsEntry({required this.terms, this.genresOverride});

  final List<String> terms;
  final _VibeGenres? genresOverride;
}

Map<String, _SearchTermsEntry> _readSearchTerms() {
  final json =
      jsonDecode(File(_searchTermsPath).readAsStringSync())
          as Map<String, dynamic>;

  final result = <String, _SearchTermsEntry>{};
  for (final entry in json.entries) {
    final map = entry.value as Map<String, dynamic>;
    final terms = List<String>.from(map['terms'] as List? ?? const []);
    final genresJson = map['genres'] as Map<String, dynamic>?;

    _VibeGenres? override;
    if (genresJson != null) {
      override = _VibeGenres(
        movieGenreIds: const [], // numeric-only override, no normalized ids
        tvGenreIds: const [],
        movieTmdbIds: List<int>.from(genresJson['movie'] as List? ?? const []),
        tvTmdbIds: List<int>.from(genresJson['tv'] as List? ?? const []),
      );
    }

    result[entry.key] = _SearchTermsEntry(
      terms: terms,
      genresOverride: override,
    );
  }
  return result;
}

/// One vibe's genre rule, both as the normalized ids
/// `assets/vibes.json` stores (empty for a `genres`-override vibe,
/// which has no normalized `Genre` at all — e.g. "fantasy", not in
/// `GenreCatalog.all`) and as TMDB's own numeric ids per type (what
/// actually goes into `with_genres`).
class _VibeGenres {
  _VibeGenres({
    required this.movieGenreIds,
    required this.tvGenreIds,
    required this.movieTmdbIds,
    required this.tvTmdbIds,
  });

  final List<String> movieGenreIds;
  final List<String> tvGenreIds;
  final List<int> movieTmdbIds;
  final List<int> tvTmdbIds;
}

Map<String, _VibeGenres> _readVibesJsonGenres() {
  final json =
      jsonDecode(File(_vibesJsonPath).readAsStringSync())
          as Map<String, dynamic>;
  final vibes = json['vibes'] as List;

  final result = <String, _VibeGenres>{};
  for (final v in vibes) {
    final map = v as Map<String, dynamic>;
    final id = map['id'] as String;
    final movieGenreIds = List<String>.from(
      (map['movie'] as Map<String, dynamic>)['genreIds'] as List,
    );
    final tvGenreIds = List<String>.from(
      (map['tv'] as Map<String, dynamic>)['genreIds'] as List,
    );

    result[id] = _VibeGenres(
      movieGenreIds: movieGenreIds,
      tvGenreIds: tvGenreIds,
      // .whereType<int>() is what silently drops a normalized genre
      // that has no TMDB id for this *type* specifically — e.g.
      // "date"'s own tv: ["romance", "comedy"] only ever resolves to
      // comedy's id on the TV side, since TmdbGenreMapper._tvIds has
      // no "romance" entry at all (TMDB's real TV genre list doesn't
      // have one). The report shows both lists side by side so that
      // gap is visible, not hidden.
      movieTmdbIds: movieGenreIds
          .map((g) => TmdbGenreMapper.toTmdbId(Genre(id: g), MediaType.movie))
          .whereType<int>()
          .toList(),
      tvTmdbIds: tvGenreIds
          .map((g) => TmdbGenreMapper.toTmdbId(Genre(id: g), MediaType.tvShow))
          .whereType<int>()
          .toList(),
    );
  }
  return result;
}

/// `assets/vibes.json` wins when [vibeId] is actually there — a
/// `genres` override in `tool/vibe_search_terms.json` is only ever a
/// fallback for a vibe that doesn't exist yet. `null` if neither has
/// anything to offer.
_VibeGenres? _resolveVibeGenres(
  String vibeId,
  Map<String, _VibeGenres> vibesJsonGenres,
  _SearchTermsEntry entry,
) {
  return vibesJsonGenres[vibeId] ?? entry.genresOverride;
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

/// `raw` has no `vote_count.gte` at all; `withMinVotes` adds
/// `vote_count.gte=$_matchEngineFirstAttemptVoteCountGte` — every
/// number in this report is one of these, always both, always the
/// same criterion.
class _VoteSplitTotal {
  const _VoteSplitTotal({required this.raw, required this.withMinVotes});

  final int raw;
  final int withMinVotes;

  @override
  String toString() => '$raw / $withMinVotes';
}

class _KeywordCandidate {
  _KeywordCandidate({
    required this.id,
    required this.name,
    required this.sourceTerms,
    required this.soloMovie,
    required this.soloTv,
    required this.crossMovie,
    required this.crossTv,
  });

  final int id;
  final String name;
  final Set<String> sourceTerms;
  final _VoteSplitTotal soloMovie;
  final _VoteSplitTotal soloTv;
  final _VoteSplitTotal crossMovie;
  final _VoteSplitTotal crossTv;

  // Flags are computed off the ≥200 figure (MatchEngine's own
  // first-attempt threshold) — the realistic one, not the raw count.
  bool get isLowVolume =>
      crossMovie.withMinVotes < _lowVolumeThreshold &&
      crossTv.withMinVotes < _lowVolumeThreshold;

  bool get isWideSoloNarrowCross =>
      (soloMovie.withMinVotes >= _wideSoloThreshold &&
          crossMovie.withMinVotes < _lowVolumeThreshold) ||
      (soloTv.withMinVotes >= _wideSoloThreshold &&
          crossTv.withMinVotes < _lowVolumeThreshold);
}

class _GenrePoolResult {
  _GenrePoolResult({
    required this.vibeId,
    required this.movieGenreIds,
    required this.tvGenreIds,
    required this.movieTotal,
    required this.tvTotal,
    required this.note,
  });

  final String vibeId;
  final List<int> movieGenreIds;
  final List<int> tvGenreIds;
  final _VoteSplitTotal movieTotal;
  final _VoteSplitTotal tvTotal;
  final String? note;
}

String _buildReport(
  Map<String, List<_KeywordCandidate>> keywordResults,
  List<_GenrePoolResult> genrePoolResults,
) {
  final buffer = StringBuffer()
    ..writeln('# Vibe keyword candidates report — round 2')
    ..writeln()
    ..writeln(
      'Generated ${DateTime.now().toIso8601String()} by '
      '`tool/resolve_vibe_keywords.dart` — never written back to '
      '`assets/vibes.json` automatically. Review, then edit that file '
      'by hand.',
    )
    ..writeln()
    ..writeln(
      '**Vote criterion**: every total below is a pair `raw / '
      '≥$_matchEngineFirstAttemptVoteCountGte` — `raw` has no '
      '`vote_count.gte` at all; `≥$_matchEngineFirstAttemptVoteCountGte` '
      'adds `vote_count.gte=$_matchEngineFirstAttemptVoteCountGte`, '
      "MatchQuery's own default field (`match_query.dart`) and "
      "DECISIONS.md §5's documented first-attempt threshold. This is "
      'the *designed* value, not what the app sends today — '
      '`discoverQueryParams` currently hardcodes `vote_count.gte=100` '
      'unconditionally (a separate, pre-existing, already-documented '
      'gap: `DiscoverFilter` has no `vote_count.gte` field at all, so '
      "`MatchQuery.voteCountGte` — 200 first, 50 after relaxation step "
      "4 — has no effect on a real call yet). Flags below are computed "
      'off the ≥$_matchEngineFirstAttemptVoteCountGte figure.',
    )
    ..writeln()
    ..writeln(
      '**A `raw` total of exactly 20001 is TMDB\'s own result cap, not '
      'a real count** — confirmed directly: `GET /discover/movie?'
      'include_adult=false` with no other filter at all already '
      'returns `total_results: 20001` (`total_pages: 1001`). Any '
      '`raw` figure at that exact number just means "TMDB stopped '
      'counting", not that the pool is literally 20001 titles — '
      'treat it as "very large, functionally uncapped" and lean on '
      'the ≥$_matchEngineFirstAttemptVoteCountGte column instead, '
      'which is what actually distinguishes these pools.',
    )
    ..writeln()
    ..writeln('Legend:')
    ..writeln(
      '- 🔸 low volume — both cross totals (≥$_matchEngineFirstAttemptVoteCountGte) '
      'are below $_lowVolumeThreshold.',
    )
    ..writeln(
      '- ⚠️ wide solo / narrow cross — the keyword alone has '
      '$_wideSoloThreshold+ (≥$_matchEngineFirstAttemptVoteCountGte), but '
      "ANDed with the vibe's own genres it drops below "
      '$_lowVolumeThreshold.',
    )
    ..writeln('- No flag — a real candidate.')
    ..writeln();

  for (final entry in keywordResults.entries) {
    final vibeId = entry.key;
    final candidates = entry.value;
    final pool = genrePoolResults.firstWhere((p) => p.vibeId == vibeId);

    buffer
      ..writeln('## $vibeId')
      ..writeln()
      ..writeln(
        'Reference genres for the cross column (OR\'d with `|`, same as '
        "a real vibe rule's `with_genres`) — movie: ${pool.movieGenreIds}; "
        'tv: ${pool.tvGenreIds}.',
      )
      ..writeln(
        'Genre pool alone (no keyword) — movie: ${pool.movieTotal} · tv: '
        '${pool.tvTotal}.',
      )
      ..writeln();

    if (candidates.isEmpty) {
      buffer
        ..writeln('_No keyword candidates found for this vibe\'s terms._')
        ..writeln();
      continue;
    }

    buffer
      ..writeln(
        '| Keyword | id | from term(s) | solo movie | solo tv | '
        'cross movie | cross tv | flags |',
      )
      ..writeln('|---|---|---|---|---|---|---|---|');

    for (final c in candidates) {
      final flags = [
        if (c.isLowVolume) '🔸',
        if (c.isWideSoloNarrowCross) '⚠️',
      ].join(' ');
      buffer.writeln(
        '| ${c.name} | ${c.id} | ${c.sourceTerms.join(', ')} | '
        '${c.soloMovie} | ${c.soloTv} | ${c.crossMovie} | ${c.crossTv} | '
        '${flags.isEmpty ? '—' : flags} |',
      );
    }
    buffer.writeln();
  }

  buffer
    ..writeln('## Genre-only vibes (no keyword search)')
    ..writeln()
    ..writeln(
      'Just how big each pool already is with the vibe\'s own genres '
      "(OR'd) — no keyword involved. \"movie genreIds\"/\"tv genreIds\" "
      'are the *resolved* TMDB ids actually sent, confirming what '
      '`TmdbGenreMapper`/the `genres` override produced for each type.',
    )
    ..writeln()
    ..writeln(
      '| Vibe | movie genreIds | tv genreIds | movie total | tv total |',
    )
    ..writeln('|---|---|---|---|---|');

  for (final pool in genrePoolResults) {
    if (keywordResults.containsKey(pool.vibeId)) continue; // own section above
    buffer.writeln(
      '| ${pool.vibeId}${pool.note != null ? ' (${pool.note})' : ''} | '
      '${pool.movieGenreIds} | ${pool.tvGenreIds} | ${pool.movieTotal} | '
      '${pool.tvTotal} |',
    );
  }
  buffer.writeln();

  buffer
    ..writeln('## TMDB genre resolution — verification')
    ..writeln()
    ..writeln(
      'Resolved live by this run via `TmdbGenreMapper.toTmdbId` (the '
      'same code `MatchEngine._filterForVibe` uses), not hand-typed:',
    )
    ..writeln(
      '- `action` → movie: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'action'), MediaType.movie)}, '
      'tv: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'action'), MediaType.tvShow)} '
      '("Action & Adventure" on TV — merged, per that mapper\'s own doc comment).',
    )
    ..writeln(
      '- `sci-fi` → movie: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'sci-fi'), MediaType.movie)}, '
      'tv: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'sci-fi'), MediaType.tvShow)} '
      '("Sci-Fi & Fantasy" on TV — merged, same reason).',
    )
    ..writeln(
      '- `fantasy` → movie: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'fantasy'), MediaType.movie)}, '
      'tv: ${TmdbGenreMapper.toTmdbId(const Genre(id: 'fantasy'), MediaType.tvShow)} — '
      "both null: there's no normalized `Genre(id: 'fantasy')` in "
      '`GenreCatalog.all` at all, which is exactly why the "fantasy" '
      'vibe needs `tool/vibe_search_terms.json`\'s own `genres` '
      'override (movie: TMDB 14, tv: TMDB 10765) instead of the usual '
      'vibes.json → TmdbGenreMapper pipeline.',
    )
    ..writeln();

  buffer
    ..writeln('## Summary — one row per vibe')
    ..writeln()
    ..writeln(
      '| Vibe | movie genreIds | tv genreIds | movie total | tv total | notes |',
    )
    ..writeln('|---|---|---|---|---|---|');
  for (final pool in genrePoolResults) {
    buffer.writeln(
      '| ${pool.vibeId} | ${pool.movieGenreIds} | ${pool.tvGenreIds} | '
      '${pool.movieTotal} | ${pool.tvTotal} | ${pool.note ?? (keywordResults.containsKey(pool.vibeId) ? 'genre pool baseline — see its own keyword table above' : '—')} |',
    );
  }
  buffer.writeln();

  return buffer.toString();
}
