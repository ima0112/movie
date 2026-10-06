/// D3's header: "age calculated from birthday, or years lived if there's
/// a deathday" — `null` when [birthday] itself isn't known (nothing to
/// compute).
///
/// [reference] defaults to [DateTime.now] and exists only so tests don't
/// depend on the real clock; a caller never passes it for a living
/// person — [deathday], when present, always wins as the reference
/// point instead (a dead person's age stops advancing).
int? personAge(DateTime? birthday, DateTime? deathday, {DateTime? reference}) {
  if (birthday == null) return null;
  final until = deathday ?? reference ?? DateTime.now();
  return _yearsBetween(birthday, until);
}

int _yearsBetween(DateTime from, DateTime to) {
  var years = to.year - from.year;
  final hasNotHadBirthdayYetThisYear =
      to.month < from.month || (to.month == from.month && to.day < from.day);
  if (hasNotHadBirthdayYetThisYear) years--;
  return years;
}
