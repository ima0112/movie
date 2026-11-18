import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';
import 'package:movies/features/match_engine/domain/surprise_request.dart';

void main() {
  const key = MediaKey(type: MediaType.movie, tmdbId: 1);

  group('ParticipantAnswers — the Surprise-me fields', () {
    test('default to "no platform filter, open year end, no rent/buy"', () {
      const answers = ParticipantAnswers(participantId: 'me', yearFrom: 1990);

      expect(answers.platformIds, isEmpty);
      expect(answers.yearTo, isNull);
      expect(answers.includeRentBuy, isFalse);
    });

    test('count in equality and hashing', () {
      const base = ParticipantAnswers(participantId: 'me', yearFrom: 1990);
      const withPlatform = ParticipantAnswers(
        participantId: 'me',
        yearFrom: 1990,
        platformIds: {8},
      );
      const same = ParticipantAnswers(
        participantId: 'me',
        yearFrom: 1990,
        platformIds: {8},
      );

      expect(withPlatform, same);
      expect(withPlatform.hashCode, same.hashCode);
      expect(withPlatform, isNot(base));
      expect(
        const ParticipantAnswers(
          participantId: 'me',
          yearFrom: 1990,
          yearTo: 2015,
        ),
        isNot(base),
      );
      expect(
        const ParticipantAnswers(
          participantId: 'me',
          yearFrom: 1990,
          includeRentBuy: true,
        ),
        isNot(base),
      );
    });
  });

  group('SurpriseRequest', () {
    const answers = ParticipantAnswers(participantId: 'me', yearFrom: 1990);

    test('asks for five by default', () {
      const request = SurpriseRequest(
        type: MediaType.movie,
        answers: answers,
        sessionId: 's1',
        region: 'ES',
        seed: 1,
      );

      expect(request.count, 5);
      expect(request.excludeKeys, isEmpty);
    });

    test('copyWith changes only the seed and what to exclude', () {
      const request = SurpriseRequest(
        type: MediaType.tvShow,
        answers: answers,
        sessionId: 's1',
        region: 'ES',
        seed: 1,
      );

      final next = request.copyWith(seed: 2, excludeKeys: {key});

      expect(next.seed, 2);
      expect(next.excludeKeys, {key});
      expect(next.sessionId, 's1');
      expect(next.type, MediaType.tvShow);
      expect(next.region, 'ES');
      expect(next.answers, answers);
    });
  });

  group('SurpriseHistoryEntry', () {
    final shownAt = DateTime(2026, 11, 16, 9);

    test('starts as viewed and withOutcome changes only the outcome', () {
      final entry = SurpriseHistoryEntry(
        key: key,
        sessionId: 's1',
        shownAt: shownAt,
      );
      final chosen = entry.withOutcome(SurpriseOutcome.chosen);

      expect(entry.outcome, SurpriseOutcome.viewed);
      expect(chosen.outcome, SurpriseOutcome.chosen);
      expect(chosen.key, key);
      expect(chosen.sessionId, 's1');
      expect(chosen.shownAt, shownAt);
      expect(chosen, isNot(entry));
      expect(chosen.withOutcome(SurpriseOutcome.viewed), entry);
    });
  });

  group('SurpriseOutcome', () {
    test('goes from neutral to strong: viewed, rerolled, revisited, saved, '
        'chosen', () {
      expect(SurpriseOutcome.values, [
        SurpriseOutcome.viewed,
        SurpriseOutcome.rerolled,
        SurpriseOutcome.revisited,
        SurpriseOutcome.saved,
        SurpriseOutcome.chosen,
      ]);
    });

    test('a stronger outcome replaces a weaker one, never the reverse', () {
      expect(SurpriseOutcome.saved.canReplace(SurpriseOutcome.viewed), isTrue);
      expect(SurpriseOutcome.chosen.canReplace(SurpriseOutcome.saved), isTrue);
      expect(SurpriseOutcome.viewed.canReplace(SurpriseOutcome.saved), isFalse);
      expect(
        SurpriseOutcome.revisited.canReplace(SurpriseOutcome.saved),
        isFalse,
      );
      expect(SurpriseOutcome.saved.canReplace(SurpriseOutcome.saved), isFalse);
    });

    test('only saved and chosen are picks', () {
      expect(
        [
          for (final o in SurpriseOutcome.values)
            if (o.isPick) o,
        ],
        [SurpriseOutcome.saved, SurpriseOutcome.chosen],
      );
    });

    test('an entry carries its batch and genres', () {
      final entry = SurpriseHistoryEntry(
        key: key,
        sessionId: 's1',
        shownAt: DateTime(2026, 11, 16),
        batch: 2,
        genres: const [
          Genre(id: 'drama'),
          Genre(id: 'crime'),
        ],
      );

      expect(entry.batch, 2);
      expect(entry.withOutcome(SurpriseOutcome.saved).genres, entry.genres);
      expect(entry.withOutcome(SurpriseOutcome.saved).batch, 2);
      expect(
        entry,
        isNot(
          SurpriseHistoryEntry(
            key: key,
            sessionId: 's1',
            shownAt: DateTime(2026, 11, 16),
            batch: 1,
            genres: const [
              Genre(id: 'drama'),
              Genre(id: 'crime'),
            ],
          ),
        ),
      );
    });
  });

  group('SurpriseBatch', () {
    test('is empty with no suggestions, and the percent range is 60-98', () {
      const batch = SurpriseBatch(sessionId: 's1', suggestions: []);

      expect(batch.isEmpty, isTrue);
      expect(batch.relaxations, isEmpty);
      expect(SurpriseSuggestion.minPercent, 60);
      expect(SurpriseSuggestion.maxPercent, 98);
    });
  });
}
