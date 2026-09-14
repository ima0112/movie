import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';

const _key = MediaKey(type: MediaType.movie, tmdbId: 1);

void main() {
  group('UserMediaEntry', () {
    test('isFavorite and isWatchLater are independent', () {
      const entry = UserMediaEntry(
        key: _key,
        isFavorite: true,
        isWatchLater: true,
      );

      expect(entry.isFavorite, isTrue);
      expect(entry.isWatchLater, isTrue);
      expect(entry.isWatched, isFalse);
    });

    test(
      'markWatched clears isWatchLater — docs/DECISIONS.md section 4: '
      '"Marking as watched automatically removes it from Watch later"',
      () {
        const entry = UserMediaEntry(key: _key, isWatchLater: true);

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
      },
    );

    test('markWatched defaults watchedAt to now', () {
      const entry = UserMediaEntry(key: _key);
      final before = DateTime.now();

      final watched = entry.markWatched();

      expect(
        watched.watchedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('unmarkWatched clears watchedAt and rating', () {
      final entry = UserMediaEntry(
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
        () => UserMediaEntry(key: _key, rating: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => UserMediaEntry(key: _key, rating: 6),
        throwsA(isA<AssertionError>()),
      );
    });

    test('two entries with the same fields are equal', () {
      final a = UserMediaEntry(
        key: _key,
        isFavorite: true,
        watchedAt: DateTime(2024, 1, 1),
      );
      final b = UserMediaEntry(
        key: _key,
        isFavorite: true,
        watchedAt: DateTime(2024, 1, 1),
      );

      expect(a, equals(b));
    });
  });
}
