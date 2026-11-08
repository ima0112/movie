import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';

const _key = MediaKey(type: MediaType.movie, tmdbId: 1);
const _action = Genre(id: 'action', name: 'Action');
const _drama = Genre(id: 'drama', name: 'Drama');

void main() {
  group('UserMediaEntry', () {
    test('isFavorite and isWatchLater are independent', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        isFavorite: true,
        isWatchLater: true,
      );

      expect(entry.isFavorite, isTrue);
      expect(entry.isWatchLater, isTrue);
      expect(entry.isWatched, isFalse);
    });

    test('markWatched clears isWatchLater — docs/DECISIONS.md section 4: '
        '"Marking as watched automatically removes it from Watch later"', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        isWatchLater: true,
      );

      final watched = entry.markWatched(
        watchedAt: DateTime(2024, 1, 1),
        rating: 4,
      );

      expect(watched.isWatchLater, isFalse);
      expect(watched.isWatched, isTrue);
      expect(watched.watchedAt, DateTime(2024, 1, 1));
      expect(watched.rating, 4);
      // Favorite is untouched by marking as watched.
      expect(watched.isFavorite, entry.isFavorite);
    });

    test('markWatched defaults watchedAt to now', () {
      const entry = UserMediaEntry(title: 'Test Title', key: _key);
      final before = DateTime.now();

      final watched = entry.markWatched();

      expect(
        watched.watchedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('unmarkWatched clears watchedAt and rating', () {
      final entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        watchedAt: DateTime(2024, 1, 1),
        rating: 5,
      );

      final unmarked = entry.unmarkWatched();

      expect(unmarked.isWatched, isFalse);
      expect(unmarked.watchedAt, isNull);
      expect(unmarked.rating, isNull);
    });

    test('rating must be between 1 and 5', () {
      expect(
        () => UserMediaEntry(title: 'Test Title', key: _key, rating: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => UserMediaEntry(title: 'Test Title', key: _key, rating: 6),
        throwsA(isA<AssertionError>()),
      );
    });

    test('two entries with the same fields are equal', () {
      final a = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        isFavorite: true,
        watchedAt: DateTime(2024, 1, 1),
      );
      final b = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        isFavorite: true,
        watchedAt: DateTime(2024, 1, 1),
      );

      expect(a, equals(b));
    });

    test('genres defaults to empty', () {
      const entry = UserMediaEntry(title: 'Test Title', key: _key);

      expect(entry.genres, isEmpty);
    });

    test('markWatched preserves genres when none are passed, unlike rating '
        'and the duration fields (which hard-reset)', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        genres: [_action, _drama],
      );

      final watched = entry.markWatched();

      expect(watched.genres, [_action, _drama]);
    });

    test('markWatched replaces genres when a fresh list is passed', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        genres: [_action],
      );

      final watched = entry.markWatched(genres: const [_drama]);

      expect(watched.genres, [_drama]);
    });

    test('unmarkWatched preserves genres — it describes the title, not '
        'the watch event', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        watchedAt: null,
        genres: [_action],
      );
      final watched = entry.markWatched();

      final unmarked = watched.unmarkWatched();

      expect(unmarked.genres, [_action]);
    });

    test('copyWith preserves genres by default and replaces them when '
        'passed', () {
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        genres: [_action],
      );

      expect(entry.copyWith(isFavorite: true).genres, [_action]);
      expect(entry.copyWith(genres: const [_drama]).genres, [_drama]);
    });

    test('two entries with genres in a different order are not equal — '
        "it's a list, not a set", () {
      const a = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        genres: [_action, _drama],
      );
      const b = UserMediaEntry(
        title: 'Test Title',
        key: _key,
        genres: [_drama, _action],
      );

      expect(a, isNot(equals(b)));
    });
  });
}
