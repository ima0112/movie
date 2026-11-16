import '../../../core/domain/entities/media_detail.dart';
import '../../../core/domain/entities/media_item.dart';

/// One step of the Surprise-me relaxation ladder, applied (in this order)
/// only while a search finds fewer than `SurpriseEngineImpl.minCandidates`.
/// Vetoes, platforms, runtime and the latest year are **never** relaxed —
/// not even silently.
enum SurpriseRelaxation {
  /// `vote_count.gte` from 150 down to 50.
  lowerVoteCount,

  /// Search without the chosen vibes (the general query alone).
  dropVibes,

  /// The earliest year moved 10 years back.
  widenYears,
}

/// One suggestion of a batch: the title with its details (runtime or
/// seasons, tagline, where to watch), which of the chosen vibes it matched,
/// and its "% for you".
class SurpriseSuggestion {
  const SurpriseSuggestion({
    required this.detail,
    this.matchedVibeIds = const {},
    required this.affinityPercent,
  });

  /// The "% for you" shown on the card: the title's score scaled to a modest
  /// range (never below [minPercent] nor above [maxPercent]) — a relative
  /// affinity among the candidates, not a probability, and never presented
  /// as more precise than that.
  static const int minPercent = 60;
  static const int maxPercent = 98;

  final MediaDetail detail;
  final Set<String> matchedVibeIds;
  final int affinityPercent;

  MediaItem get item => detail.item;
}

/// What the engine returns: up to [SurpriseRequest.count] suggestions, ranked
/// as they should be shown, plus what was relaxed to get them.
///
/// [suggestions] can hold fewer than asked when TMDB simply has no more that
/// satisfy the hard filters — and be empty ([isEmpty]) when even the
/// hard-filter-only search finds nothing: the "few options with your
/// platforms" case, never solved by silently loosening vetoes or platforms.
class SurpriseBatch {
  const SurpriseBatch({
    required this.sessionId,
    required this.suggestions,
    this.relaxations = const [],
    this.candidateCount = 0,
  });

  final String sessionId;
  final List<SurpriseSuggestion> suggestions;

  /// The ladder steps that were needed, in order, so the screen can say what
  /// was widened.
  final List<SurpriseRelaxation> relaxations;

  /// How many distinct candidates the search gathered before choosing.
  final int candidateCount;

  bool get isEmpty => suggestions.isEmpty;
}
