import '../entities/genre.dart';
import '../entities/media_key.dart';

/// Everything the Surprise-me statistics show for one period
/// (`calculateSurpriseInsights`) — plain values, no Flutter. Each block is
/// `null`/empty when it has nothing to say, so the screen draws only what is
/// true (the same rule as C4's other blocks).
class SurpriseInsights {
  const SurpriseInsights({
    required this.hitRate,
    required this.afterChoosing,
    required this.discoveries,
    required this.genres,
    required this.typeSplit,
    required this.asked,
    required this.habit,
  });

  /// "Does it work for me?" — `null` with no session in the period.
  final SurpriseHitRate? hitRate;

  /// "What happened to what I chose?" — `null` when nothing was chosen.
  final SurpriseAfterChoosing? afterChoosing;

  /// Choices that were new to the user, best first (at most
  /// [maxDiscoveries]).
  final List<SurpriseDiscovery> discoveries;

  /// Genres by how often they were picked, then shown.
  final List<SurpriseGenreStat> genres;

  /// What was chosen, movies against shows.
  final SurpriseTypeSplit typeSplit;

  /// "What do I ask for?" — the collections, vibes and ways in, and how often
  /// the engine had to relax. `null` with no session.
  final SurpriseAsked? asked;

  final SurpriseHabit habit;

  /// Nothing at all happened in the period.
  bool get isEmpty => hitRate == null;

  static const int maxDiscoveries = 3;
}

/// Sessions and how many ended in a pick.
class SurpriseHitRate {
  const SurpriseHitRate({
    required this.sessions,
    required this.chosenSessions,
    required this.savedOnlySessions,
    required this.chosenInFirstBatch,
    required this.averageBatchesToChoose,
    required this.batchesToChoose,
  });

  final int sessions;

  /// Sessions in which a card was chosen.
  final int chosenSessions;

  /// Sessions with a card saved to Watch later but none chosen.
  final int savedOnlySessions;

  /// Chosen sessions decided on the first five cards.
  final int chosenInFirstBatch;

  /// Mean batch number of the chosen card, over the chosen sessions; `null`
  /// when none.
  final double? averageBatchesToChoose;

  /// How many chosen sessions were decided in batch 1, 2, 3 or later (the
  /// last key, [maxBatchBucket], means that many or more).
  final Map<int, int> batchesToChoose;

  /// Chosen sessions over all sessions, 0–1.
  double get rate => sessions == 0 ? 0 : chosenSessions / sessions;

  static const int maxBatchBucket = 3;
}

/// What became of the cards chosen in the period, from My List.
class SurpriseAfterChoosing {
  const SurpriseAfterChoosing({
    required this.chosen,
    required this.watched,
    required this.stillInWatchLater,
    required this.rated,
    required this.averageRating,
    required this.best,
  });

  final int chosen;

  /// Chosen cards the user went on to watch.
  final int watched;

  /// Chosen cards still waiting in Watch later (not watched).
  final int stillInWatchLater;

  /// Watched ones with a rating, and their mean (1–5); `null` when none.
  final int rated;
  final double? averageRating;

  /// The best-rated watched ones, best first (at most [maxBest]).
  final List<SurpriseChosenTitle> best;

  /// Watched over chosen, 0–1.
  double get watchedRate => chosen == 0 ? 0 : watched / chosen;

  static const int maxBest = 3;
}

class SurpriseChosenTitle {
  const SurpriseChosenTitle({
    required this.key,
    required this.title,
    required this.rating,
  });

  final MediaKey key;
  final String title;
  final int rating;
}

/// A choice with a genre the user had not watched or favorited before.
class SurpriseDiscovery {
  const SurpriseDiscovery({
    required this.key,
    required this.title,
    required this.newGenres,
    this.rating,
  });

  final MediaKey key;
  final String title;

  /// The genres of it that were new to the user.
  final List<Genre> newGenres;

  /// The user's rating once watched; `null` before.
  final int? rating;
}

class SurpriseGenreStat {
  const SurpriseGenreStat({
    required this.genre,
    required this.shown,
    required this.chosen,
  });

  final Genre genre;

  /// Cards with the genre that were shown / that were chosen.
  final int shown;
  final int chosen;
}

class SurpriseTypeSplit {
  const SurpriseTypeSplit({required this.movies, required this.shows});

  final int movies;
  final int shows;

  int get total => movies + shows;
}

/// How often something was asked for and how often it ended in a choice.
class SurpriseAskStat {
  const SurpriseAskStat({
    required this.id,
    required this.sessions,
    required this.chosenSessions,
  });

  /// A `Collection.id` or `Vibe.id`.
  final String id;
  final int sessions;
  final int chosenSessions;

  double get rate => sessions == 0 ? 0 : chosenSessions / sessions;
}

class SurpriseAsked {
  const SurpriseAsked({
    required this.collections,
    required this.vibes,
    required this.viaQuiz,
    required this.viaTastes,
    required this.chosenViaQuiz,
    required this.chosenViaTastes,
    required this.relaxedSessions,
    required this.relaxations,
  });

  /// Most asked first; ties by id.
  final List<SurpriseAskStat> collections;
  final List<SurpriseAskStat> vibes;

  /// Sessions by how they began (the quiz; "use my tastes" — the profile or
  /// the list inferred from My List) and how many of each ended in a choice.
  final int viaQuiz;
  final int viaTastes;
  final int chosenViaQuiz;
  final int chosenViaTastes;

  /// Sessions in which the engine had to relax the answers, and how many times
  /// each step (`SurpriseRelaxation.name`) was needed, most first.
  final int relaxedSessions;
  final List<(String, int)> relaxations;

  static const int maxRows = 5;
}

class SurpriseHabit {
  const SurpriseHabit({
    required this.byMonth,
    required this.byWeekday,
    required this.weeklyStreak,
    required this.bestWeeklyStreak,
  });

  /// Sessions per month for the last 12 months, oldest first, as `(first day
  /// of the month, count)`.
  final List<(DateTime, int)> byMonth;

  /// Sessions per weekday, Monday first (7 values).
  final List<int> byWeekday;

  /// Consecutive Monday-to-Sunday weeks with a session, ending at this week —
  /// or the week before when this one has none yet — and the best ever. Of
  /// the whole history, whatever the period.
  final int weeklyStreak;
  final int bestWeeklyStreak;
}
