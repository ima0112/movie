import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/settings/domain/library_export.dart';

void main() {
  group('libraryExportJson', () {
    test('is valid, parseable JSON', () {
      final json = libraryExportJson([
        const UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: 693134),
          title: 'Dune: Part Two',
          isFavorite: true,
        ),
      ]);

      expect(() => jsonDecode(json), returnsNormally);
    });

    test('an empty library exports an empty array, not null or an error', () {
      final json = libraryExportJson(const []);

      expect(jsonDecode(json), isEmpty);
    });

    test('carries every field the task asks for: title, type, id, '
        'favorite, watchLater, rating, watchedAt', () {
      final json = libraryExportJson([
        UserMediaEntry(
          key: const MediaKey(type: MediaType.movie, tmdbId: 693134),
          title: 'Dune: Part Two',
          isFavorite: true,
          isWatchLater: false,
          watchedAt: DateTime.utc(2024, 3, 1),
          rating: 5,
        ),
      ]);

      final decoded = jsonDecode(json) as List;
      expect(decoded, hasLength(1));
      final entry = decoded.single as Map<String, dynamic>;
      expect(entry['title'], 'Dune: Part Two');
      expect(entry['type'], 'movie');
      expect(entry['id'], 693134);
      expect(entry['favorite'], isTrue);
      expect(entry['watchLater'], isFalse);
      expect(entry['rating'], 5);
      expect(entry['watchedAt'], '2024-03-01T00:00:00.000Z');
    });

    test('a TV show entry exports its type as tvShow', () {
      final json = libraryExportJson([
        const UserMediaEntry(
          key: MediaKey(type: MediaType.tvShow, tmdbId: 94997),
          title: 'Signal Lost',
          isWatchLater: true,
        ),
      ]);

      final entry = (jsonDecode(json) as List).single as Map<String, dynamic>;
      expect(entry['type'], 'tvShow');
    });

    test('an unwatched, unrated entry exports rating and watchedAt as null, '
        'not omitted or a fabricated value', () {
      final json = libraryExportJson([
        const UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: 1),
          title: 'Something',
        ),
      ]);

      final entry = (jsonDecode(json) as List).single as Map<String, dynamic>;
      expect(entry.containsKey('rating'), isTrue);
      expect(entry['rating'], isNull);
      expect(entry.containsKey('watchedAt'), isTrue);
      expect(entry['watchedAt'], isNull);
    });

    test('exports every entry in the library, in the same order', () {
      final entries = List.generate(
        5,
        (i) => UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: i),
          title: 'Movie $i',
        ),
      );

      final decoded = jsonDecode(libraryExportJson(entries)) as List;

      expect(decoded, hasLength(5));
      expect(decoded.map((e) => (e as Map<String, dynamic>)['title']), [
        'Movie 0',
        'Movie 1',
        'Movie 2',
        'Movie 3',
        'Movie 4',
      ]);
    });

    test('indented for human readability, not a single packed line', () {
      final json = libraryExportJson([
        const UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: 1),
          title: 'Something',
        ),
      ]);

      expect(json, contains('\n'));
    });
  });
}
