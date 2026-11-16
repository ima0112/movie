import 'discover_filter.dart';
import 'media_type.dart';

/// The extra choices of H8's "Sort by" row besides the three plain orders:
/// a ready-made slice of the catalog — what is coming, what is in cinemas,
/// which shows are airing or over. Each is a combination of fields a
/// [DiscoverFilter] already has (a release window or a TV status), not a
/// field of its own, so every repository call and listing keeps working
/// unchanged; [DiscoverFilterPreset] applies and recognizes them.
enum DiscoverPreset {
  /// Movies releasing from tomorrow up to [comingSoonWindow] ahead.
  comingSoon,

  /// Movies released in the last [inTheatersWindow] (what is still in
  /// cinemas).
  inTheaters,

  /// TV shows still on the air.
  airingNow,

  /// TV shows that have ended.
  finished;

  /// The presets that make sense for [type], in the order they show:
  /// movies get Coming soon and In theaters, TV shows Finished and Airing
  /// now, and "All" none (a window or a status means something different
  /// for each kind).
  static List<DiscoverPreset> forType(MediaType? type) => switch (type) {
    MediaType.movie => const [comingSoon, inTheaters],
    MediaType.tvShow => const [finished, airingNow],
    null => const [],
  };

  static const Duration comingSoonWindow = Duration(days: 90);
  static const Duration inTheatersWindow = Duration(days: 45);
}

/// Votes needed under the "Top rated" order.
const int ratedMinVoteCount = 300;

extension DiscoverFilterPreset on DiscoverFilter {
  /// The preset this filter is exactly, as of [now] (default: today), or
  /// `null`. A release window is recognized by its dates, so one saved
  /// yesterday is no longer "Coming soon" today and simply shows no preset.
  DiscoverPreset? presetAt(DateTime now) {
    if (tvStatus != null) {
      return switch (tvStatus!) {
        DiscoverTvStatus.airing => DiscoverPreset.airingNow,
        DiscoverTvStatus.ended => DiscoverPreset.finished,
      };
    }
    final from = releasedFrom;
    final to = releasedTo;
    if (from == null || to == null) return null;
    final today = _day(now);
    if (from == today.add(const Duration(days: 1)) &&
        to == today.add(DiscoverPreset.comingSoonWindow)) {
      return DiscoverPreset.comingSoon;
    }
    if (from == today.subtract(DiscoverPreset.inTheatersWindow) &&
        to == today) {
      return DiscoverPreset.inTheaters;
    }
    return null;
  }

  /// [presetAt] for today.
  DiscoverPreset? get preset => presetAt(DateTime.now());

  /// The votes a title needs to be listed under [sort] — a "top rated" order
  /// is meaningless on a handful of votes (a 9.9 from 143 people), so it asks
  /// for 300 (as B2's Top rated does); otherwise the default. A preset keeps
  /// its own floor (unreleased titles have no votes at all).
  DiscoverFilter withSort(DiscoverSortBy sort, {DateTime? now}) {
    final floor = switch (presetAt(now ?? DateTime.now())) {
      DiscoverPreset.comingSoon => 0,
      DiscoverPreset.inTheaters => 10,
      _ =>
        sort == DiscoverSortBy.rating
            ? ratedMinVoteCount
            : const DiscoverFilter().minVoteCount,
    };
    return copyWith(sortBy: sort, minVoteCount: floor);
  }

  /// This filter with [preset] applied (or, with `null`, with any preset
  /// removed), replacing whichever one was there. Unreleased titles have no
  /// votes yet, so Coming soon drops the vote floor, and In theaters lowers it.
  DiscoverFilter withPreset(DiscoverPreset? preset, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final cleared = copyWith(
      releasedFrom: () => null,
      releasedTo: () => null,
      tvStatus: () => null,
      minVoteCount: const DiscoverFilter().minVoteCount,
    );
    return switch (preset) {
      null => cleared,
      DiscoverPreset.comingSoon => cleared.copyWith(
        releasedFrom: () => today.add(const Duration(days: 1)),
        releasedTo: () => today.add(DiscoverPreset.comingSoonWindow),
        minVoteCount: 0,
      ),
      DiscoverPreset.inTheaters => cleared.copyWith(
        releasedFrom: () => today.subtract(DiscoverPreset.inTheatersWindow),
        releasedTo: () => today,
        minVoteCount: 10,
      ),
      DiscoverPreset.airingNow => cleared.copyWith(
        tvStatus: () => DiscoverTvStatus.airing,
      ),
      DiscoverPreset.finished => cleared.copyWith(
        tvStatus: () => DiscoverTvStatus.ended,
      ),
    };
  }
}

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);
