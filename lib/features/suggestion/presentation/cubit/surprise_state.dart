import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/relaxation.dart';

/// Where a Surprise-me result's answers came from — `docs/SCREENS.md`
/// E3's own subtitles ("Based on your tastes" / "Based on your list")
/// and whether its "Save these answers as my tastes?" link should even
/// appear ("If it came from the quiz and there's no profile").
enum SuggestionSource { profile, inferredList, quiz }

/// Surprise me (N=1)'s states — `docs/SCREENS.md` E1/E3.
sealed class SurpriseState {
  const SurpriseState();
}

/// E1 — nothing chosen yet.
final class ChoosingType extends SurpriseState {
  const ChoosingType();
}

/// E3's "loading (card skeleton with 'Searching…' text)".
final class Searching extends SurpriseState {
  const Searching(this.mediaType);

  final MediaType mediaType;
}

/// DECISIONS.md section 5's case 3 ("Nothing → guided quiz") — the
/// caller's (a future `SurpriseScreen`'s) signal to push E2, not
/// something this Cubit renders itself.
final class NeedsQuiz extends SurpriseState {
  const NeedsQuiz(this.mediaType);

  final MediaType mediaType;
}

/// E3's own result. [candidates] is the *whole* pool
/// `MatchOptions.randomizeTop` produced (`MatchResult.winner` followed
/// by `MatchResult.alternatives`, in that order) — [index] is which one
/// is currently shown. `SurpriseCubit.another()` only ever advances
/// [index]; it never re-queries `MatchEngine` (see that method's own
/// doc comment for why the whole pool has to live here).
final class SurpriseResult extends SurpriseState {
  const SurpriseResult({
    required this.candidates,
    required this.index,
    required this.relaxationsApplied,
    required this.source,
  });

  final List<MediaItem> candidates;
  final int index;

  /// E3's own "if filters were relaxed: discreet note 'We widened the
  /// search to 1990'".
  final List<Relaxation> relaxationsApplied;
  final SuggestionSource source;

  MediaItem get current => candidates[index];
}

/// Every candidate in the pool has already been shown —
/// `SurpriseCubit.another`'s own "after the 5th, Exhausted".
final class Exhausted extends SurpriseState {
  const Exhausted();
}

/// `MatchEngine.resolve` either took longer than `SurpriseCubit`'s own
/// maximum wait, or genuinely returned `null` (every relaxation step
/// exhausted, still no candidate) — `SurpriseCubit.retry()` is the
/// recovery for both, so neither needs its own state.
final class SurpriseError extends SurpriseState {
  const SurpriseError(this.message);

  final String message;
}
