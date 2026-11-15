/// The span of C4 (Stats): what the watched titles are counted over
/// (`docs/SCREENS.md` C4). Distinct spans, so none is another's subset:
/// everything ever, this calendar year, this calendar month.
enum StatsPeriod {
  allTime,
  thisYear,
  thisMonth;

  /// Whether a title watched on [date] belongs to this period, seen from
  /// [now].
  bool contains(DateTime date, DateTime now) => switch (this) {
    StatsPeriod.allTime => true,
    StatsPeriod.thisYear => date.year == now.year,
    StatsPeriod.thisMonth => date.year == now.year && date.month == now.month,
  };
}
