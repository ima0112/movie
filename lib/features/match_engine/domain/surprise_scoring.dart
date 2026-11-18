import 'dart:math';

import '../../../core/domain/entities/genre.dart';
import 'surprise_candidates.dart';
import 'surprise_request.dart';

/// A candidate with its score.
class ScoredCandidate {
  const ScoredCandidate(this.candidate, this.score);

  final SurpriseCandidate candidate;
  final double score;
}

/// Local scoring and selection of the Surprise-me candidates
/// (`docs/DECISIONS.md` §5): vibes, taste and a Bayesian rating add up, a
/// little seeded noise breaks ties, and the five are drawn — not simply the
/// top five — from the best twenty with diversity rules. Pure functions of
/// their input and [Random].
abstract final class SurpriseScoring {
  static const double vibeWeight = 1.0;
  static const double tasteWeight = 0.25;
  static const double qualityWeight = 1.0;
  static const double noiseWeight = 0.15;

  /// Taken off a title with no poster: a card without one is a poor
  /// surprise, so it sinks below every title that has one — but is still
  /// there when there are fewer than five with a poster.
  static const double noPosterPenalty = 2.0;

  /// The prior of the Bayesian rating `(v·R + m·C) / (v + m)`: the votes a
  /// title needs before its own average counts for more than the pool's.
  static const int priorVotes = 150;

  /// The pool the five are drawn from.
  static const int poolSize = 20;

  /// At most this many titles of the same main genre in a batch.
  static const int maxPerGenre = 2;

  /// Raising the score to this makes the draw favour the best ones more.
  static const double drawSharpness = 3;

  static List<ScoredCandidate> score(
    List<SurpriseCandidate> candidates,
    SurpriseRequest request, {
    required int chosenVibes,
    required Random rng,
  }) {
    if (candidates.isEmpty) return const [];

    final rated = candidates.where((c) => (c.item.voteCount ?? 0) > 0);
    final meanRating = rated.isEmpty
        ? 6.5
        : rated.map((c) => c.item.voteAverage).reduce((a, b) => a + b) /
              rated.length;

    double taste(SurpriseCandidate c) => c.item.genres.fold<double>(
      0,
      (sum, g) => sum + (request.genreAffinity[g] ?? 0),
    );
    final maxTaste = candidates.map((c) => taste(c).abs()).fold<double>(0, max);

    return [
      for (final c in candidates)
        ScoredCandidate(
          c,
          vibeWeight * (chosenVibes == 0 ? 0 : c.vibeIds.length / chosenVibes) +
              tasteWeight * (maxTaste == 0 ? 0 : taste(c) / maxTaste) +
              qualityWeight * _quality(c, meanRating) +
              noiseWeight * rng.nextDouble() -
              (hasPoster(c) ? 0 : noPosterPenalty),
        ),
    ];
  }

  static bool hasPoster(SurpriseCandidate c) =>
      (c.item.posterUrl ?? '').isNotEmpty;

  /// The Bayesian rating mapped onto 0–1 (5.0 → 0, 9.0 → 1).
  static double _quality(SurpriseCandidate c, double meanRating) {
    final v = (c.item.voteCount ?? 0).toDouble();
    final bayes =
        (v * c.item.voteAverage + priorVotes * meanRating) / (v + priorVotes);
    return ((bayes - 5) / 4).clamp(0.0, 1.0);
  }

  /// Up to [count] of [scored], best first: at least one per chosen vibe when
  /// there is one, one **wildcard** outside the user's liked genres (only
  /// when they have any), at most [maxPerGenre] of the same main genre, the
  /// rest drawn by score from the top [poolSize].
  static List<ScoredCandidate> select(
    List<ScoredCandidate> scored, {
    required int count,
    required List<String> vibeIds,
    required Set<Genre> likedGenres,
    required Random rng,
  }) {
    final ranked = [...scored]..sort((a, b) => b.score.compareTo(a.score));
    final picks = <ScoredCandidate>[];
    final perGenre = <String, int>{};

    String mainGenre(ScoredCandidate c) =>
        c.candidate.item.genres.firstOrNull?.id ?? '_none';
    bool underCap(ScoredCandidate c) =>
        (perGenre[mainGenre(c)] ?? 0) < maxPerGenre;
    void add(ScoredCandidate c) {
      picks.add(c);
      perGenre[mainGenre(c)] = (perGenre[mainGenre(c)] ?? 0) + 1;
    }

    // 1. At least one per chosen vibe.
    for (final vibeId in vibeIds) {
      if (picks.length >= count) break;
      if (picks.any((p) => p.candidate.vibeIds.contains(vibeId))) continue;
      final best = ranked
          .where(
            (c) =>
                !picks.contains(c) &&
                c.candidate.vibeIds.contains(vibeId) &&
                underCap(c),
          )
          .firstOrNull;
      if (best != null) add(best);
    }

    // 2. One wildcard, outside what they say they like.
    if (likedGenres.isNotEmpty && picks.length < count) {
      final liked = likedGenres.map((g) => g.id).toSet();
      final wildcard = ranked
          .where(
            (c) =>
                !picks.contains(c) &&
                underCap(c) &&
                c.candidate.item.genres.isNotEmpty &&
                c.candidate.item.genres.every((g) => !liked.contains(g.id)),
          )
          .firstOrNull;
      if (wildcard != null) add(wildcard);
    }

    // 3. Draw the rest from the pool by score, then widen it, then drop the
    // genre cap rather than return fewer than there are.
    final pool = ranked.take(poolSize).toList();
    _drawInto(picks, pool, count, rng, underCap, add);
    if (picks.length < count) {
      _drawInto(picks, ranked, count, rng, underCap, add);
    }
    if (picks.length < count) {
      _drawInto(picks, ranked, count, rng, (_) => true, add);
    }

    return picks..sort((a, b) => b.score.compareTo(a.score));
  }

  static void _drawInto(
    List<ScoredCandidate> picks,
    List<ScoredCandidate> from,
    int count,
    Random rng,
    bool Function(ScoredCandidate) allowed,
    void Function(ScoredCandidate) add,
  ) {
    while (picks.length < count) {
      final open = [
        for (final c in from)
          if (!picks.contains(c) && allowed(c)) c,
      ];
      if (open.isEmpty) return;
      final weights = [
        for (final c in open) pow(max(c.score, 0.05), drawSharpness).toDouble(),
      ];
      var roll = rng.nextDouble() * weights.reduce((a, b) => a + b);
      var chosen = open.last;
      for (var i = 0; i < open.length; i++) {
        roll -= weights[i];
        if (roll <= 0) {
          chosen = open[i];
          break;
        }
      }
      add(chosen);
    }
  }

  /// [score] as the "% for you": 60–98 over the range of [all] the scores.
  static int percent(
    double score,
    List<ScoredCandidate> all,
    int lowest,
    int highest,
  ) {
    // The no-poster penalty must not stretch the range everyone else is
    // scaled over.
    final withPoster = all.where((c) => hasPoster(c.candidate));
    final scores = (withPoster.isEmpty ? all : withPoster).map((c) => c.score);
    final lo = scores.reduce(min);
    final hi = scores.reduce(max);
    if (hi - lo < 1e-9) return ((lowest + highest) / 2).round();
    return (lowest + (highest - lowest) * (score - lo) / (hi - lo))
        .round()
        .clamp(lowest, highest);
  }
}
