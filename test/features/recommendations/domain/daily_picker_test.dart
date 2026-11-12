import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/recommendations/domain/daily_picker.dart';

void main() {
  final items = [
    for (final s in ['a', 'b', 'c', 'd', 'e']) (s, 1),
  ];

  test('the same day, inputs and salt always give the same pick', () {
    final day = DateTime(2026, 5, 4);
    expect(
      DailyPicker(day).pick(items, salt: 'x'),
      DailyPicker(DateTime(2026, 5, 4, 23, 59)).pick(items, salt: 'x'),
    );
  });

  test('every option comes up in time', () {
    final seen = {
      for (var d = 1; d <= 30; d++)
        DailyPicker(DateTime(2026, 5, d)).pick(items, salt: 'x'),
    };
    expect(seen.length, items.length);
  });

  test('different slots on the same day are independent', () {
    final day = DailyPicker(DateTime(2026, 5, 4));
    final picks = {
      for (var i = 0; i < 12; i++) day.pick(items, salt: 'slot$i'),
    };
    expect(picks.length, greaterThan(1));
  });

  test('a single candidate is always picked; none gives null', () {
    final day = DailyPicker(DateTime(2026, 5, 4));
    expect(day.pick([('only', 1)], salt: 's'), 'only');
    expect(day.pick(<(String, int)>[], salt: 's'), isNull);
  });

  test('heavier candidates come up more often', () {
    final weighted = [('a', 1), ('b', 1), ('c', 4)];
    final counts = <String, int>{};
    for (var d = 0; d < 60; d++) {
      final pick = DailyPicker(
        DateTime(2026, 6, 1 + d),
      ).pick(weighted, salt: 'w')!;
      counts[pick] = (counts[pick] ?? 0) + 1;
    }
    expect(counts['c']!, greaterThan(counts['a']!));
    expect(counts['c']!, greaterThan(counts['b']!));
  });

  test('over 200 days it never repeats the day before', () {
    String? previous;
    for (var d = 0; d < 200; d++) {
      final pick = DailyPicker(
        DateTime(2026, 1, 1).add(Duration(days: d)),
      ).pick(items, salt: 'c')!;
      expect(pick, isNot(previous));
      previous = pick;
    }
  });

  test('with two candidates it alternates', () {
    final two = [('a', 1), ('b', 1)];
    String? previous;
    for (var d = 0; d < 60; d++) {
      final pick = DailyPicker(
        DateTime(2026, 1, 1).add(Duration(days: d)),
      ).pick(two, salt: 't')!;
      expect(pick, isNot(previous));
      previous = pick;
    }
  });

  test('pickMany returns distinct picks, at most the number available', () {
    final day = DailyPicker(DateTime(2026, 5, 4));
    final two = day.pickMany(items, count: 2, salt: 'm');
    expect(two.toSet().length, 2);
    expect(day.pickMany([('a', 1)], count: 3, salt: 'm'), ['a']);
  });
}
