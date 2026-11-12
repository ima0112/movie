/// Where a title is in its release — what D1/D2 flag when it isn't simply out:
/// not released yet, or only in cinemas for now. `null` (no status) means an
/// ordinary released title, so nothing is flagged.
enum ReleaseStage { upcoming, inTheaters }

/// A title's [stage] for the region being viewed, with the dates worth saying:
/// [date] is when it comes out ([ReleaseStage.upcoming], `null` when TMDB gives
/// none) or when it opened in cinemas ([ReleaseStage.inTheaters]);
/// [streamingDate] is when it reaches digital/physical/TV, when known.
final class ReleaseStatus {
  const ReleaseStatus(this.stage, {this.date, this.streamingDate});

  final ReleaseStage stage;
  final DateTime? date;
  final DateTime? streamingDate;

  @override
  bool operator ==(Object other) =>
      other is ReleaseStatus &&
      other.stage == stage &&
      other.date == date &&
      other.streamingDate == streamingDate;

  @override
  int get hashCode => Object.hash(stage, date, streamingDate);

  @override
  String toString() => 'ReleaseStatus($stage, $date, $streamingDate)';
}

/// One of TMDB's per-region release dates for a movie. [type] is TMDB's:
/// 1 premiere, 2 limited theatrical, 3 theatrical, 4 digital, 5 physical,
/// 6 TV.
final class ReleaseDateEntry {
  const ReleaseDateEntry({required this.type, required this.date});

  final int type;
  final DateTime date;
}

/// How long after opening in cinemas a movie still counts as "in theaters"
/// when no digital/physical date has come yet.
const Duration inTheatersWindow = Duration(days: 90);

/// TMDB's own statuses for something that isn't out yet.
const _unreleasedStatuses = {
  'Rumored',
  'Planned',
  'In Production',
  'Post Production',
};

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime? _earliest(Iterable<DateTime> dates) =>
    dates.isEmpty ? null : dates.reduce((a, b) => a.isBefore(b) ? a : b);

/// A movie's [ReleaseStatus] in one region, from that region's [entries] and
/// TMDB's [tmdbStatus]. Premieres (type 1, festivals) never count as the
/// release. `null` when it is simply out — or when TMDB's data doesn't let us
/// say anything reliable, so no wrong label is ever shown.
///
/// - **No home release has come** (digital, physical, TV) and **no cinema date
///   has come** → *upcoming* ([ReleaseStatus.date] = the earliest cinema, else
///   home, date still ahead; `null` when none is known but TMDB's status says
///   it isn't out).
/// - A cinema date has come, no home release has, and it is within
///   [inTheatersWindow] → *in theaters*.
/// - Anything else → `null`.
ReleaseStatus? releaseStatusForMovie(
  List<ReleaseDateEntry> entries, {
  required DateTime today,
  required String tmdbStatus,
}) {
  final now = _day(today);
  final cinema = [
    for (final e in entries)
      if (e.type == 2 || e.type == 3) _day(e.date),
  ];
  final home = [
    for (final e in entries)
      if (e.type >= 4 && e.type <= 6) _day(e.date),
  ];
  bool arrived(DateTime d) => !d.isAfter(now);

  if (home.any(arrived)) return null; // out on digital/physical/TV
  final cinemaOpened = cinema.where(arrived);
  if (cinemaOpened.isNotEmpty) {
    final opened = _earliest(cinemaOpened)!;
    if (now.difference(opened) > inTheatersWindow) return null;
    return ReleaseStatus(
      ReleaseStage.inTheaters,
      date: opened,
      streamingDate: _earliest(home),
    );
  }

  final ahead = [...cinema, ...home];
  if (ahead.isNotEmpty) {
    return ReleaseStatus(ReleaseStage.upcoming, date: _earliest(ahead));
  }
  // No usable dates: trust TMDB's own status, with no date to show.
  return _unreleasedStatuses.contains(tmdbStatus)
      ? const ReleaseStatus(ReleaseStage.upcoming)
      : null;
}

/// A TV show's [ReleaseStatus]: *upcoming* while its first episode is still
/// ahead (or has no date and TMDB's status says it isn't out), else `null`.
ReleaseStatus? releaseStatusForTv({
  required DateTime? firstAirDate,
  required DateTime today,
  required String tmdbStatus,
}) {
  if (firstAirDate != null) {
    return _day(firstAirDate).isAfter(_day(today))
        ? ReleaseStatus(ReleaseStage.upcoming, date: _day(firstAirDate))
        : null;
  }
  return _unreleasedStatuses.contains(tmdbStatus)
      ? const ReleaseStatus(ReleaseStage.upcoming)
      : null;
}
