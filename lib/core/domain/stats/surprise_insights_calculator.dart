import '../entities/genre.dart';
import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/surprise_history_entry.dart';
import '../entities/surprise_session.dart';
import '../entities/user_media_entry.dart';
import 'stats_period.dart';
import 'surprise_insights.dart';

/// The Surprise-me statistics for [period] — pure, no Flutter, no network.
///
/// [history] is what the sessions showed and what came of each card,
/// [sessions] what they asked for, [library] My List (to see what became of
/// the chosen ones). A session belongs to the period of its start; a card, of
/// the moment it was shown. What a chosen card became is read from [library]
/// as it is **now**, whatever the period. [now] anchors "this month" and the
/// trailing windows.
SurpriseInsights calculateSurpriseInsights({
  required List<SurpriseHistoryEntry> history,
  required List<SurpriseSession> sessions,
  required List<UserMediaEntry> library,
  required StatsPeriod period,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final periodSessions = [
    for (final s in sessions)
      if (period.contains(s.startedAt, today)) s,
  ];
  final sessionIds = {for (final s in periodSessions) s.sessionId};
  // A card with no recorded session (the history is older than the sessions'
  // record) still counts by its own date.
  final periodHistory = [
    for (final e in history)
      if (sessionIds.contains(e.sessionId) ||
          (!_hasSession(sessions, e.sessionId) &&
              period.contains(e.shownAt, today)))
        e,
  ];
  final bySession = <String, List<SurpriseHistoryEntry>>{};
  for (final e in periodHistory) {
    (bySession[e.sessionId] ??= []).add(e);
  }
  final chosenSessionIds = {
    for (final entry in bySession.entries)
      if (entry.value.any((e) => e.outcome == SurpriseOutcome.chosen))
        entry.key,
  };
  final chosen = [
    for (final e in periodHistory)
      if (e.outcome == SurpriseOutcome.chosen) e,
  ];
  final libraryByKey = {for (final e in library) e.key: e};

  return SurpriseInsights(
    hitRate: periodSessions.isEmpty
        ? null
        : _hitRate(periodSessions, bySession, chosenSessionIds),
    afterChoosing: chosen.isEmpty ? null : _afterChoosing(chosen, libraryByKey),
    discoveries: _discoveries(chosen, library, libraryByKey),
    genres: _genres(periodHistory),
    typeSplit: SurpriseTypeSplit(
      movies: chosen.where((e) => e.key.type == MediaType.movie).length,
      shows: chosen.where((e) => e.key.type == MediaType.tvShow).length,
    ),
    asked: periodSessions.isEmpty
        ? null
        : _asked(periodSessions, chosenSessionIds),
    habit: _habit(sessions, today),
  );
}

bool _hasSession(List<SurpriseSession> sessions, String id) =>
    sessions.any((s) => s.sessionId == id);

SurpriseHitRate _hitRate(
  List<SurpriseSession> sessions,
  Map<String, List<SurpriseHistoryEntry>> bySession,
  Set<String> chosenSessionIds,
) {
  var savedOnly = 0;
  var chosenCount = 0;
  var firstBatch = 0;
  var batchSum = 0;
  final buckets = {
    for (var b = 1; b <= SurpriseHitRate.maxBatchBucket; b++) b: 0,
  };
  for (final s in sessions) {
    final entries = bySession[s.sessionId] ?? const [];
    if (chosenSessionIds.contains(s.sessionId)) {
      final batch = entries
          .where((e) => e.outcome == SurpriseOutcome.chosen)
          .map((e) => e.batch)
          .reduce((a, b) => a < b ? a : b);
      chosenCount++;
      batchSum += batch;
      if (batch == 1) firstBatch++;
      final bucket = batch > SurpriseHitRate.maxBatchBucket
          ? SurpriseHitRate.maxBatchBucket
          : batch;
      buckets[bucket] = buckets[bucket]! + 1;
    } else if (entries.any((e) => e.outcome == SurpriseOutcome.saved)) {
      savedOnly++;
    }
  }
  return SurpriseHitRate(
    sessions: sessions.length,
    chosenSessions: chosenCount,
    savedOnlySessions: savedOnly,
    chosenInFirstBatch: firstBatch,
    averageBatchesToChoose: chosenCount == 0 ? null : batchSum / chosenCount,
    batchesToChoose: buckets,
  );
}

SurpriseAfterChoosing _afterChoosing(
  List<SurpriseHistoryEntry> chosen,
  Map<MediaKey, UserMediaEntry> library,
) {
  // One title chosen in two sessions counts once.
  final keys = {for (final e in chosen) e.key};
  var watched = 0;
  var waiting = 0;
  final ratings = <SurpriseChosenTitle>[];
  for (final key in keys) {
    final entry = library[key];
    if (entry == null) continue;
    if (entry.isWatched) {
      watched++;
      if (entry.rating != null) {
        ratings.add(
          SurpriseChosenTitle(
            key: key,
            title: entry.title,
            rating: entry.rating!,
          ),
        );
      }
    } else if (entry.isWatchLater) {
      waiting++;
    }
  }
  ratings.sort((a, b) {
    final byRating = b.rating.compareTo(a.rating);
    return byRating != 0 ? byRating : a.title.compareTo(b.title);
  });
  return SurpriseAfterChoosing(
    chosen: keys.length,
    watched: watched,
    stillInWatchLater: waiting,
    rated: ratings.length,
    averageRating: ratings.isEmpty
        ? null
        : ratings.fold<int>(0, (sum, r) => sum + r.rating) / ratings.length,
    best: ratings.take(SurpriseAfterChoosing.maxBest).toList(),
  );
}

List<SurpriseDiscovery> _discoveries(
  List<SurpriseHistoryEntry> chosen,
  List<UserMediaEntry> library,
  Map<MediaKey, UserMediaEntry> libraryByKey,
) {
  final chosenKeys = {for (final e in chosen) e.key};
  // What the user already liked on their own: watched or favorited titles that
  // Surprise me did not hand them.
  final usual = <Genre>{
    for (final e in library)
      if ((e.isWatched || e.isFavorite) && !chosenKeys.contains(e.key))
        ...e.genres,
  };
  if (usual.isEmpty) return const [];
  final seen = <MediaKey>{};
  final found = <SurpriseDiscovery>[];
  for (final e in chosen) {
    if (!seen.add(e.key)) continue;
    final fresh = [
      for (final g in e.genres)
        if (!usual.contains(g)) g,
    ];
    if (fresh.isEmpty) continue;
    final entry = libraryByKey[e.key];
    found.add(
      SurpriseDiscovery(
        key: e.key,
        title: entry?.title ?? '',
        newGenres: fresh,
        rating: entry?.isWatched == true ? entry?.rating : null,
      ),
    );
  }
  // Rated ones first, best first; then the rest, by how many new genres.
  found.sort((a, b) {
    final byRating = (b.rating ?? 0).compareTo(a.rating ?? 0);
    if (byRating != 0) return byRating;
    final byNew = b.newGenres.length.compareTo(a.newGenres.length);
    return byNew != 0 ? byNew : a.key.tmdbId.compareTo(b.key.tmdbId);
  });
  return [
    for (final d in found)
      if (d.title.isNotEmpty) d,
  ].take(SurpriseInsights.maxDiscoveries).toList();
}

List<SurpriseGenreStat> _genres(List<SurpriseHistoryEntry> history) {
  final shown = <Genre, int>{};
  final chosen = <Genre, int>{};
  for (final e in history) {
    for (final g in e.genres) {
      shown[g] = (shown[g] ?? 0) + 1;
      if (e.outcome == SurpriseOutcome.chosen) chosen[g] = (chosen[g] ?? 0) + 1;
    }
  }
  final stats = [
    for (final g in shown.keys)
      SurpriseGenreStat(genre: g, shown: shown[g]!, chosen: chosen[g] ?? 0),
  ];
  stats.sort((a, b) {
    final byChosen = b.chosen.compareTo(a.chosen);
    if (byChosen != 0) return byChosen;
    final byShown = b.shown.compareTo(a.shown);
    return byShown != 0 ? byShown : a.genre.id.compareTo(b.genre.id);
  });
  return stats;
}

SurpriseAsked _asked(
  List<SurpriseSession> sessions,
  Set<String> chosenSessionIds,
) {
  List<SurpriseAskStat> tally(Set<String> Function(SurpriseSession) of) {
    final asked = <String, int>{};
    final won = <String, int>{};
    for (final s in sessions) {
      for (final id in of(s)) {
        asked[id] = (asked[id] ?? 0) + 1;
        if (chosenSessionIds.contains(s.sessionId)) {
          won[id] = (won[id] ?? 0) + 1;
        }
      }
    }
    final stats = [
      for (final id in asked.keys)
        SurpriseAskStat(
          id: id,
          sessions: asked[id]!,
          chosenSessions: won[id] ?? 0,
        ),
    ];
    stats.sort((a, b) {
      final byAsked = b.sessions.compareTo(a.sessions);
      return byAsked != 0 ? byAsked : a.id.compareTo(b.id);
    });
    return stats;
  }

  bool quiz(SurpriseSession s) => s.source == SurpriseSessionSource.quiz;
  final relaxed = <String, int>{};
  for (final s in sessions) {
    for (final r in s.relaxations) {
      relaxed[r] = (relaxed[r] ?? 0) + 1;
    }
  }
  final steps = relaxed.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) {
      final byCount = b.$2.compareTo(a.$2);
      return byCount != 0 ? byCount : a.$1.compareTo(b.$1);
    });
  return SurpriseAsked(
    collections: tally((s) => s.collectionIds),
    vibes: tally((s) => s.vibeIds),
    viaQuiz: sessions.where(quiz).length,
    viaTastes: sessions.where((s) => !quiz(s)).length,
    chosenViaQuiz: sessions
        .where((s) => quiz(s) && chosenSessionIds.contains(s.sessionId))
        .length,
    chosenViaTastes: sessions
        .where((s) => !quiz(s) && chosenSessionIds.contains(s.sessionId))
        .length,
    relaxedSessions: sessions.where((s) => s.relaxations.isNotEmpty).length,
    relaxations: steps,
  );
}

SurpriseHabit _habit(List<SurpriseSession> sessions, DateTime now) {
  // Months: the last 12, this one included.
  final months = [
    for (var i = 11; i >= 0; i--) DateTime(now.year, now.month - i),
  ];
  final byMonth = [
    for (final m in months)
      (
        m,
        sessions
            .where(
              (s) => s.startedAt.year == m.year && s.startedAt.month == m.month,
            )
            .length,
      ),
  ];
  final byWeekday = List.filled(7, 0);
  for (final s in sessions) {
    byWeekday[s.startedAt.weekday - DateTime.monday]++;
  }
  DateTime weekOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
  final weeks = {for (final s in sessions) weekOf(s.startedAt)};
  var current = weekOf(now);
  if (!weeks.contains(current)) {
    current = DateTime(current.year, current.month, current.day - 7);
  }
  var streak = 0;
  var cursor = current;
  while (weeks.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
  }
  final sorted = weeks.toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final w in sorted) {
    run =
        previous != null &&
            w == DateTime(previous.year, previous.month, previous.day + 7)
        ? run + 1
        : 1;
    if (run > best) best = run;
    previous = w;
  }
  return SurpriseHabit(
    byMonth: byMonth,
    byWeekday: byWeekday,
    weeklyStreak: streak,
    bestWeeklyStreak: best,
  );
}
