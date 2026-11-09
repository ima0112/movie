import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_discover_params.dart';
import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';

/// Every vibe whose TV rule was deliberately emptied by the
/// `vibe-keywords-curated` branch's own `--final-pools` measurement
/// (its own report: `tv ≥200` below 30) — kept as one named list so
/// each test below documents *why* these three, not just *that* they
/// don't show up on TV.
const _tvEmptiedByPoolSize = {'tearjerker', 'gangster', 'musical'};

/// `indie`/`fantasy` are deliberate, permanent TV exclusions (not
/// pool-size-driven) — Indie never had a TV-side rule to begin with,
/// and "Fantasy entra solo en película" is this branch's own curated
/// decision.
const _neverMeaningfulForTv = {'indie', 'fantasy'};

void main() {
  late VibeCatalog catalog;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    catalog = await VibeCatalog.loadFromAssets();
  });

  group('VibeCatalog.loadFromAssets', () {
    test('loads assets/vibes.json without error, has exactly 16 vibes, '
        'and cult is gone', () {
      expect(catalog.all(), hasLength(16));
      expect(catalog.byId('cult'), isNull);
    });

    test('every vibe has a non-empty id and icon', () {
      for (final vibe in catalog.all()) {
        expect(vibe.id, isNotEmpty);
        expect(vibe.icon, isNotEmpty);
      }
    });

    test('byId finds a known vibe and returns null for an unknown one', () {
      expect(catalog.byId('feel_good')?.id, 'feel_good');
      expect(catalog.byId('does-not-exist'), isNull);
    });

    test('every vibe is meaningful for at least one media type — none '
        'is a dead entry', () {
      for (final vibe in catalog.all()) {
        expect(
          vibe.isMeaningfulFor(MediaType.movie) ||
              vibe.isMeaningfulFor(MediaType.tvShow),
          isTrue,
          reason: '${vibe.id} has no rule for either type',
        );
      }
    });

    test('at least 8 vibes are meaningful per type', () {
      expect(
        catalog.availableFor(MediaType.movie).length,
        greaterThanOrEqualTo(8),
      );
      expect(
        catalog.availableFor(MediaType.tvShow).length,
        greaterThanOrEqualTo(8),
      );
    });

    test('no duplicate ids within a single rule, and every id is a '
        'positive integer', () {
      for (final vibe in catalog.all()) {
        for (final rule in [vibe.movie, vibe.tv]) {
          final ids = rule.keywordIds.map(int.parse).toList();
          expect(
            ids.toSet().length,
            ids.length,
            reason: '${vibe.id} has a duplicate keyword id: $ids',
          );
          for (final id in ids) {
            expect(
              id,
              greaterThan(0),
              reason: '${vibe.id} has a non-positive keyword id: $id',
            );
          }
        }
      }
    });

    test('indie and fantasy are not meaningful for tv', () {
      for (final id in _neverMeaningfulForTv) {
        final vibe = catalog.byId(id)!;
        expect(
          vibe.isMeaningfulFor(MediaType.tvShow),
          isFalse,
          reason: '$id should have an empty tv rule',
        );
      }
    });

    test('every vibe not deliberately excluded from tv is meaningful '
        'for tv', () {
      final excluded = {..._neverMeaningfulForTv, ..._tvEmptiedByPoolSize};
      for (final vibe in catalog.all()) {
        if (excluded.contains(vibe.id)) continue;
        expect(
          vibe.isMeaningfulFor(MediaType.tvShow),
          isTrue,
          reason: '${vibe.id} should still be meaningful for tv',
        );
      }
    });

    test('tearjerker/gangster/musical — emptied for tv by the '
        '--final-pools pool-size rule — are not meaningful for tv, but '
        'still are for movie', () {
      for (final id in _tvEmptiedByPoolSize) {
        final vibe = catalog.byId(id)!;
        expect(
          vibe.isMeaningfulFor(MediaType.tvShow),
          isFalse,
          reason: '$id should have an empty tv rule',
        );
        expect(
          vibe.isMeaningfulFor(MediaType.movie),
          isTrue,
          reason: '$id should still be meaningful for movie',
        );
      }
    });

    test('a vibe with several keyword ids produces with_keywords='
        'id1|id2 via discoverQueryParams', () {
      final monster = catalog.byId('monster')!;
      final keywordIds = monster.movie.keywordIds.map(int.parse).toSet();
      expect(keywordIds, hasLength(2));

      final filter = DiscoverFilter(withKeywords: keywordIds);
      final params = discoverQueryParams(filter, type: MediaType.movie);

      final sent = (params['with_keywords'] as String)
          .split('|')
          .map(int.parse)
          .toSet();
      expect(sent, keywordIds);
    });

    test('gritty on tv produces with_keywords but no with_genres — its '
        'tv rule is keywords-only', () {
      final gritty = catalog.byId('gritty')!;
      expect(gritty.tv.genreIds, isEmpty);
      expect(gritty.tv.keywordIds, isNotEmpty);

      final keywordIds = gritty.tv.keywordIds.map(int.parse).toSet();
      final filter = DiscoverFilter(withKeywords: keywordIds);
      final params = discoverQueryParams(filter, type: MediaType.tvShow);

      expect(params.containsKey('with_keywords'), isTrue);
      expect(params.containsKey('with_genres'), isFalse);
    });

    test('fantasy genre still resolves a real TMDB id for movie — '
        'confirms GenreCatalog/TmdbGenreMapper are wired, independent '
        'of the fantasy vibe itself', () {
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'fantasy'), MediaType.movie),
        14,
      );
    });
  });

  group('VibeCatalog.fromJsonString', () {
    // Pure parsing, no asset bundle needed at all.
    test('parses a minimal catalog with no Flutter/asset dependency', () {
      const source = '''
      {
        "vibes": [
          {
            "id": "classic",
            "name": "Classic",
            "icon": "vibeClassic",
            "movie": {"genreIds": [], "keywordIds": []},
            "tv": {"genreIds": [], "keywordIds": []},
            "maxReleaseYear": 1999,
            "minVoteAverage": 7.5
          }
        ]
      }
      ''';

      final parsed = VibeCatalog.fromJsonString(source);

      expect(parsed.all(), hasLength(1));
      final classic = parsed.byId('classic')!;
      expect(classic.maxReleaseYear, 1999);
      expect(classic.minVoteAverage, 7.5);
      // Empty genres/keywords, but the filter alone keeps it meaningful.
      expect(classic.isMeaningfulFor(MediaType.movie), isTrue);
    });

    test('tolerates an extra "keywordNotes" field without choking — '
        'assets/vibes.json carries one per keyword id for human '
        'readability; the parser never reads it', () {
      const source = '''
      {
        "vibes": [
          {
            "id": "superhero",
            "name": "Superhero",
            "icon": "vibeSuperhero",
            "movie": {
              "genreIds": [],
              "keywordIds": ["9715"],
              "keywordNotes": {"9715": "superhero"}
            },
            "tv": {"genreIds": [], "keywordIds": []}
          }
        ]
      }
      ''';

      final parsed = VibeCatalog.fromJsonString(source);

      expect(parsed.byId('superhero')!.movie.keywordIds, ['9715']);
    });
  });
}
