import '../../../core/domain/entities/media_item.dart';
import 'relaxation.dart';

/// One suggestion of a batch: the title, which of the chosen vibes it
/// matched, and its "% for you".
class SurpriseSuggestion {
  const SurpriseSuggestion({
    required this.item,
    this.matchedVibeIds = const {},
    required this.affinityPercent,
  });

  /// The "% for you" shown on the card: the title's score scaled to a modest
  /// range (never below [minPercent] nor above [maxPercent]) — a relative
  /// affinity within the batch, not a probability, and never presented as
  /// more precise than that.
  static const int minPercent = 60;
  static const int maxPercent = 98;

  final MediaItem item;
  final Set<String> matchedVibeIds;
  final int affinityPercent;
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

  /// The steps of the relaxation ladder that were needed, in order
  /// (`Relaxation`), so the screen can say what was widened.
  final List<Relaxation> relaxations;

  /// How many distinct candidates the search gathered before choosing.
  final int candidateCount;

  bool get isEmpty => suggestions.isEmpty;
}
