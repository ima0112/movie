// ignore_for_file: avoid_print
//
// Resolves candidate TMDB keyword ids for the vibes whose
// `VibeRule.keywordIds` is still empty in `assets/vibes.json`
// (`docs/DECISIONS.md` §5's "Vibe catalog" — the keyword mapping
// column that was never actually populated). Pure Dart, no Flutter,
// no new dependencies: `dart:io`'s own `HttpClient` for the TMDB
// calls, reusing this package's existing genre-mapping code for the
// AND-with-genres cross query.
//
// Run with: dart run tool/resolve_vibe_keywords.dart [vibeId]
// See tool/README.md for the full explanation.
//
// This script NEVER writes to assets/vibes.json — it only produces
// tool/out/vibe_keywords_report.md (gitignored, a scratch report) for
// a human to read and decide which keyword ids are actually worth
// adding, by hand, to the real catalog.
import 'dart:convert';
import 'dart:io';

import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';

/// `tool/vibe_search_terms.json`'s own path — the set of vibes this
/// script covers is exactly that file's keys, so adding a vibe there
/// (or more candidate terms to an existing one) never needs a change
/// here.
const _searchTermsPath = 'tool/vibe_search_terms.json';
const _vibesJsonPath = 'assets/vibes.json';
const _envPath = 'env/dev.json';
const _reportPath = 'tool/out/vibe_keywords_report.md';

/// Top N `/search/keyword` hits kept per candidate term — TMDB already
/// returns these ranked by relevance, and without a cap a broad term
/// like "music" could pull in dozens of barely-related keywords, each
/// costing 4 more `/discover` calls. Raise this if a vibe's own terms
/// genuinely need it.
const _maxKeywordHitsPerTerm = 5;

/// Fixed pause between every TMDB call — this script does on the
/// order of a few hundred calls per full run; TMDB's own rate limit is
/// generous but not infinite, and there's no need to race it.
const _requestPause = Duration(milliseconds: 300);

/// Same fixed filters `discoverQueryParams` always sends
/// (`tmdb_discover_params.dart`) — without these, a count would be the
/// raw, unfiltered TMDB total, not what the app's own `/discover` call
/// would actually return.
const _discoverFixedParams = {
  'include_adult': 'false',
  'vote_count.gte': '100',
};

/// A crossed (keyword + genre) total below this is flagged as not
/// very useful on its own — too few titles for this vibe/type to
/// actually surface candidates from in `MatchEngine._fetchAndScore`.
const _lowVolumeThreshold = 50;

/// A *solo* keyword total at or above this, paired with a crossed
/// total below [_lowVolumeThreshold], is flagged separately: the
/// keyword is broad on its own but doesn't actually say much once
/// narrowed to this vibe's own genres.
const _wideSoloThreshold = 500;

Future<void> main(List<String> args) async {
  final token = _readTmdbToken();
  final searchTerms = _readSearchTerms();
  final vibeGenres = _readVibeGenres();

  final onlyVibeId = args.isNotEmpty ? args.first : null;
  final vibeIds = onlyVibeId != null ? [onlyVibeId] : searchTerms.keys.toList();

  final client = HttpClient();
  final resultsByVibe = <String, List<_KeywordCandidate>>{};

  try {
    for (final vibeId in vibeIds) {
      final terms = searchTerms[vibeId];
      final genres = vibeGenres[vibeId];
      if (terms == null) {
        stderr.writeln('Skipping "$vibeId" — not in $_searchTermsPath.');
        continue;
      }
      if (genres == null) {
        stderr.writeln('Skipping "$vibeId" — not found in $_vibesJsonPath.');
        continue;
      }

      print('== $vibeId ==');
      final candidates = await _resolveVibe(
        client,
        token,
        vibeId,
        terms,
        genres,
      );
      candidates.sort(
        (a, b) =>
            (b.crossMovie + b.crossTv).compareTo(a.crossMovie + a.crossTv),
      );
      resultsByVibe[vibeId] = candidates;
    }
  } finally {
    client.close(force: true);
  }

  final report = _buildReport(resultsByVibe, vibeGenres);
  final file = File(_reportPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(report);
  print('\nReport written to $_reportPath');
}

Future<List<_KeywordCandidate>> _resolveVibe(
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
        // Same keyword surfaced by more than one term for this vibe
        // (e.g. "true story" and "biography" both finding "based on
        // true story") — record the extra term, don't requery TMDB.
        existing.sourceTerms.add(term);
        continue;
      }

      final soloMovie = await _discoverTotal(
        client,
        token,
        MediaType.movie,
        hit.id,
      );
      final soloTv = await _discoverTotal(
        client,
        token,
        MediaType.tvShow,
        hit.id,
      );
      final crossMovie = await _discoverTotal(
        client,
        token,
        MediaType.movie,
        hit.id,
        genreIds: genres.movieTmdbIds,
      );
      final crossTv = await _discoverTotal(
        client,
        token,
        MediaType.tvShow,
        hit.id,
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

Future<int> _discoverTotal(
  HttpClient client,
  String token,
  MediaType type,
  int keywordId, {
  List<int> genreIds = const [],
}) async {
  final path = type == MediaType.movie ? '/discover/movie' : '/discover/tv';
  final query = {
    ..._discoverFixedParams,
    'with_keywords': '$keywordId',
    if (genreIds.isNotEmpty) 'with_genres': genreIds.join('|'),
  };
  final json = await _getJson(client, token, path, query);
  return (json['total_results'] as int?) ?? 0;
}

/// GETs [path] from TMDB with [query], retrying with backoff on a 429
/// and pausing [_requestPause] after every successful call — see this
/// file's own top-of-file doc comment for why.
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

Map<String, List<String>> _readSearchTerms() {
  final json =
      jsonDecode(File(_searchTermsPath).readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      entry.key: List<String>.from(entry.value as List),
  };
}

/// One vibe's current genre rule, both as the normalized ids
/// `assets/vibes.json` itself stores (for the report) and as TMDB's
/// own numeric ids per type (for the cross `/discover` query) —
/// resolved via [TmdbGenreMapper], the same mapping
/// `MatchEngine._filterForVibe` already uses, so this script can never
/// drift from what the app itself would actually send.
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

Map<String, _VibeGenres> _readVibeGenres() {
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

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

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
  final int soloMovie;
  final int soloTv;
  final int crossMovie;
  final int crossTv;

  bool get isLowVolume =>
      crossMovie < _lowVolumeThreshold && crossTv < _lowVolumeThreshold;

  bool get isWideSoloNarrowCross =>
      (soloMovie >= _wideSoloThreshold && crossMovie < _lowVolumeThreshold) ||
      (soloTv >= _wideSoloThreshold && crossTv < _lowVolumeThreshold);
}

String _buildReport(
  Map<String, List<_KeywordCandidate>> resultsByVibe,
  Map<String, _VibeGenres> vibeGenres,
) {
  final buffer = StringBuffer()
    ..writeln('# Vibe keyword candidates report')
    ..writeln()
    ..writeln(
      'Generated ${DateTime.now().toIso8601String()} by '
      '`tool/resolve_vibe_keywords.dart` — never written back to '
      '`assets/vibes.json` automatically. Review, then edit that '
      'file by hand.',
    )
    ..writeln()
    ..writeln('Legend:')
    ..writeln(
      '- 🔸 low volume — both cross totals are below $_lowVolumeThreshold, '
      'too few titles to be a useful keyword for this vibe.',
    )
    ..writeln(
      '- ⚠️ wide solo / narrow cross — the keyword alone has '
      '$_wideSoloThreshold+ results, but ANDed with this vibe\'s own '
      'genres it drops below $_lowVolumeThreshold — a weak genre proxy.',
    )
    ..writeln(
      '- No flag — crosses $_lowVolumeThreshold+ for at least one type; a '
      'real candidate.',
    )
    ..writeln();

  for (final entry in resultsByVibe.entries) {
    final vibeId = entry.key;
    final candidates = entry.value;
    final genres = vibeGenres[vibeId];

    buffer
      ..writeln('## $vibeId')
      ..writeln()
      ..writeln(
        'Current genres — movie: ${genres?.movieGenreIds.join(', ') ?? '—'}; '
        'tv: ${genres?.tvGenreIds.join(', ') ?? '—'}',
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

  return buffer.toString();
}
