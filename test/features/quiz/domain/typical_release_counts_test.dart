import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/quiz/domain/typical_release_counts.dart';
import 'package:movies/shared/year_buckets.dart';

void main() {
  test('one bucket per two years, the same length yearBuckets gives', () {
    final counts = typicalReleaseCounts(minYear: 1950, maxYear: 2026);

    expect(
      counts,
      hasLength(yearBuckets(const [], minYear: 1950, maxYear: 2026).length),
    );
  });

  test('never empty, and the crest is in the 2010s — a few bars higher than '
      'the start', () {
    final counts = typicalReleaseCounts(minYear: 1950, maxYear: 2026);

    expect(counts.every((c) => c > 0), isTrue);
    final top = counts.indexOf(counts.reduce((a, b) => a > b ? a : b));
    final crestYear = 1950 + top * 2;
    expect(crestYear, inInclusiveRange(2010, 2018));
    expect(counts.last, lessThan(counts[top])); // a dip after it
    expect(counts.first, lessThan(counts[top] ~/ 3));
  });

  test('deterministic', () {
    expect(
      typicalReleaseCounts(minYear: 1950, maxYear: 2026),
      typicalReleaseCounts(minYear: 1950, maxYear: 2026),
    );
  });
}
