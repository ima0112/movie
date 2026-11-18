import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/surprise_batch.dart';

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
  const ChooseSource(
    this.mediaType,
    this.source, {
    this.tasteGenres = const {},
  });

  final MediaType mediaType;
  final SuggestionSource source;

  /// The profile's liked genres, to name them in H11 (empty for an inferred
  /// list or a profile with only vibes).
  final Set<Genre> tasteGenres;
}

/// A short message the deck wants shown once (a snackbar, a discreet line) and
/// then forgotten — `SurpriseCubit.noticeShown` clears it. No text here:
/// the screen supplies the copy (CLAUDE.md rule 15).
enum SurpriseNotice {
  none,

  /// The first batch needed a relaxation: the search was widened a little.
  widenedSearch,

  /// "Other 5" found nothing new for these answers; the deck stays as it was.
  noMoreSurprises,

  /// "Other 5" couldn't reach TMDB; the deck stays as it was.
  offline,
}

/// The deck in play (the PDF's `playing`): the batch the engine returned (up to
/// five, ranked, each with its details and "% for you") as a **circular** deck
/// — passing the last card brings the first — with the card on top, which ones
/// are in Watch later, and a pending [notice].
///
/// Fewer than five cards is fine (the deck is just shorter; with one there is
/// nowhere to pass to).
final class SurpriseResult extends SurpriseState {
  const SurpriseResult({
    required this.suggestions,
    required this.index,
    required this.relaxations,
    required this.source,
    this.savedKeys = const {},
    this.notice = SurpriseNotice.none,
  });

  final List<SurpriseSuggestion> suggestions;

  /// The card on top.
  final int index;

  /// What the engine had to loosen to find these (`SurpriseRelaxation`).
  final List<SurpriseRelaxation> relaxations;
  final SuggestionSource source;

  /// The cards of this batch that are in Watch later — already there when the
  /// deck opened, or saved from it.
  final Set<MediaKey> savedKeys;

  final SurpriseNotice notice;

  List<MediaItem> get candidates => [for (final s in suggestions) s.item];
  SurpriseSuggestion get currentSuggestion => suggestions[index];
  MediaItem get current => currentSuggestion.item;
  bool isSaved(int i) => savedKeys.contains(suggestions[i].item.key);

  SurpriseResult copyWith({
    int? index,
    Set<MediaKey>? savedKeys,
    SurpriseNotice? notice,
  }) => SurpriseResult(
    suggestions: suggestions,
    index: index ?? this.index,
    relaxations: relaxations,
    source: source,
    savedKeys: savedKeys ?? this.savedKeys,
    notice: notice ?? this.notice,
  );
}

/// The user picked a card (the PDF's `chosen`): it is already in Watch later
/// and the closing screen shows it alone. The batch stays so the thumbnails can
/// show it, inactive.
final class SurpriseChosen extends SurpriseState {
  const SurpriseChosen({
    required this.suggestions,
    required this.index,
    required this.savedKeys,
    required this.source,
  });

  final List<SurpriseSuggestion> suggestions;

  /// The chosen card.
  final int index;
  final Set<MediaKey> savedKeys;
  final SuggestionSource source;

  SurpriseSuggestion get chosen => suggestions[index];
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
