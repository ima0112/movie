import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/relaxation.dart';

/// Where a Surprise-me result's answers came from — `docs/SCREENS.md`
/// E3's own per-source subtitle, and whether its "Answer the quiz
/// instead" link should even appear (`profile`/`inferredList` only —
/// having just answered the quiz, there's nothing left to offer).
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

/// Usable tastes exist (DECISIONS.md §5's case 1 or 2 — an explicit,
/// usable [TasteProfile], or one inferred from My List) — E1's own
/// signal to open H11 instead of launching the search right away, so
/// the user can pick between using that signal or answering the quiz
/// anyway. [source] is always [SuggestionSource.profile] or
/// [SuggestionSource.inferredList], never `.quiz` — this state only
/// ever precedes [SurpriseCubit.useMyTastes]/
/// [SurpriseCubit.answerQuizInstead], both of which read it off
/// [SurpriseState], not something the quiz path ever produces.
final class ChooseSource extends SurpriseState {
  const ChooseSource(this.mediaType, this.source);

  final MediaType mediaType;
  final SuggestionSource source;
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
/// recovery for both, so neither needs its own state. No message of
/// its own (CLAUDE.md rule 15: domain/data — and this Cubit, which
/// never imports Flutter — never carry user-facing text); the one
/// screen that renders this state supplies the copy itself, via
/// `context.l10n.surpriseErrorMessage`.
final class SurpriseError extends SurpriseState {
  const SurpriseError();
}
