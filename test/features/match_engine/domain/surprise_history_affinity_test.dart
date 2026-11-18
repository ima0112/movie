import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/features/match_engine/domain/surprise_history_affinity.dart';

final _now = DateTime(2026, 11, 16, 12);

const _drama = Genre(id: 'drama');
const _crime = Genre(id: 'crime');
const _horror = Genre(id: 'horror');

SurpriseHistoryEntry _entry(
  int id,
  SurpriseOutcome outcome,
  List<Genre> genres, {
  Duration ago = Duration.zero,
}) => SurpriseHistoryEntry(
  key: MediaKey(type: MediaType.movie, tmdbId: id),
  sessionId: 's',
  shownAt: _now.subtract(ago),
  genres: genres,
  outcome: outcome,
);

Map<Genre, int> _affinity(List<SurpriseHistoryEntry> entries) =>
    SurpriseHistoryAffinity.from(entries, now: _now);

void main() {
  test('nothing in the history: no affinity', () {
    expect(_affinity(const []), isEmpty);
  });

  test('chosen weighs most, then saved, then revisited — on each genre of '
      'the card', () {
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.chosen, [_drama, _crime]),
      ]),
      {_drama: 6, _crime: 6},
    );
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.saved, [_drama]),
      ]),
      {_drama: 4},
    );
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.revisited, [_drama]),
      ]),
      {_drama: 2},
    );
  });

  test('viewed and rerolled weigh nothing: a rejected batch is a fact, not a '
      'verdict', () {
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.viewed, [_horror]),
        _entry(2, SurpriseOutcome.rerolled, [_horror]),
        _entry(3, SurpriseOutcome.rerolled, [_horror]),
      ]),
      isEmpty,
    );
  });

  test('picks add up per genre', () {
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.saved, [_drama]),
        _entry(2, SurpriseOutcome.revisited, [_drama]),
      ]),
      {_drama: 6},
    );
  });

  test(
    'older picks count less — half after 45 days — and nothing past 180',
    () {
      expect(
        _affinity([
          _entry(1, SurpriseOutcome.chosen, [
            _drama,
          ], ago: const Duration(days: 45)),
        ]),
        {_drama: 3},
      );
      expect(
        _affinity([
          _entry(1, SurpriseOutcome.chosen, [
            _drama,
          ], ago: const Duration(days: 181)),
        ]),
        isEmpty,
      );
    },
  );

  test('a weak, old signal that rounds to nothing leaves no entry', () {
    expect(
      _affinity([
        _entry(1, SurpriseOutcome.revisited, [
          _drama,
        ], ago: const Duration(days: 170)),
      ]),
      isEmpty,
    );
  });

  test('a run of picks in one genre is capped, so it cannot take over', () {
    final run = [
      for (var i = 0; i < 20; i++) _entry(i, SurpriseOutcome.chosen, [_drama]),
    ];

    expect(_affinity(run)[_drama], SurpriseHistoryAffinity.maxPerGenre);
  });

  test(
    'it never goes negative: nothing in the history counts against a genre',
    () {
      final all = _affinity([
        for (final o in SurpriseOutcome.values) _entry(o.index, o, [_horror]),
      ]);

      expect(all.values.every((v) => v > 0), isTrue);
    },
  );
}
