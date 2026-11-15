/// How many of [years] fall in each [width]-year bucket from [minYear] to
/// [maxYear] (the last bucket may be shorter): the data of a release-year
/// histogram. A `null` year (an entry saved before years were kept) and a year
/// outside the span count for nothing.
List<int> yearBuckets(
  Iterable<int?> years, {
  required int minYear,
  required int maxYear,
  int width = 2,
}) {
  final counts = List<int>.filled(((maxYear - minYear) ~/ width) + 1, 0);
  for (final year in years) {
    if (year == null || year < minYear || year > maxYear) continue;
    counts[(year - minYear) ~/ width]++;
  }
  return counts;
}
