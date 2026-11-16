import 'dart:math';

/// A fixed, typical shape of how many titles were released each year — the
/// histogram behind E2's year range, so the control has relief for someone
/// whose own list is still empty. It is a picture of "more recent years have
/// more films", not data: nothing real is counted.
///
/// One bucket per [width] years from [minYear] to [maxYear], like
/// `yearBuckets` (so it plugs into `ReleaseRangePicker` as is): a low, slowly
/// rising tail up to the 1990s, a steeper climb to a crest around the 2010s
/// and a slight dip after it. Never zero, so no bar is just a stub.
List<int> typicalReleaseCounts({
  required int minYear,
  required int maxYear,
  int width = 2,
}) {
  final buckets = ((maxYear - minYear) ~/ width) + 1;
  return [
    for (var i = 0; i < buckets; i++) _count(minYear + i * width, minYear),
  ];
}

/// The crest of the shape.
const int _peakYear = 2015;

int _count(int year, int minYear) {
  // A broad bell around the peak year on top of a gentle rise.
  final rise = 8 + 14 * ((year - minYear) / 60);
  final crest = 78 * exp(-pow((year - _peakYear) / 14, 2));
  return (rise + crest).round();
}
