import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';

void main() {
  // Loaded once for the whole file — `TestWidgetsFlutterBinding` (not
  // `testWidgets` itself, which none of these tests otherwise need) is
  // what makes `rootBundle` resolve real assets under `flutter test`.
  // Repeatedly calling `VibeCatalog.loadFromAssets()` from separate
  // `testWidgets` blocks in this same file — one real asset read per
  // test — reliably hung in this sandbox even though each of those
  // tests passed correctly in isolation; a single shared load avoids
  // that entirely and is simply less redundant I/O regardless.
  late VibeCatalog catalog;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    catalog = await VibeCatalog.loadFromAssets();
  });

  group('VibeCatalog.loadFromAssets', () {
    test('loads assets/vibes.json without error and has exactly 16 vibes', () {
      expect(catalog.all(), hasLength(16));
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

    test('availableFor(movie) and availableFor(tv) both include every vibe '
        "today — none has empty genres/keywords *and* no filter (Classic's "
        'own filter is what keeps it in, despite empty genre lists)', () {
      expect(catalog.availableFor(MediaType.movie), hasLength(16));
      expect(catalog.availableFor(MediaType.tvShow), hasLength(16));
    });

    test("every keywordIds list is empty — TMDB isn't connected yet, per "
        "vibe.dart's own doc comment", () {
      for (final vibe in catalog.all()) {
        expect(vibe.movie.keywordIds, isEmpty);
        expect(vibe.tv.keywordIds, isEmpty);
      }
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
  });
}
