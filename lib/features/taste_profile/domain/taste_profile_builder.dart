import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/taste_profile.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import '../../match_engine/domain/participant_answers.dart';
import '../../match_engine/domain/vibe.dart';
import '../../match_engine/domain/vibe_catalog.dart';

/// Builds Surprise-me (N=1)'s `ParticipantAnswers` from whatever taste
/// signal already exists — `docs/DECISIONS.md` section 5 ("Surprise me
/// (N=1)"):
///
/// 1. An explicit [TasteProfile] exists → used, refined with
///    [libraryEntries]' signals (favorites and ≥4-star watches reinforce
///    a liked genre's priority when [vibeCatalog] needs to fill in a
///    missing vibe; ≤2-star watches deprioritize one — "refinement" only
///    ever re-ranks which of the profile's *own* liked genres get mapped
///    to a filler vibe first; it never adds to or removes from
///    [TasteProfile.likedGenres]/[TasteProfile.vetoedGenres]/
///    [TasteProfile.likedVibes] themselves, and an explicit veto always
///    wins even if a favorite/high rating contradicts it).
/// 2. No profile, but [libraryEntries] has at least [minInferredEntries]
///    rows → a provisional profile is inferred entirely from those same
///    signals (nothing else to build one from).
/// 3. Neither → `null` — the caller's signal to open the quiz (E2)
///    instead.
///
/// [mediaType] isn't part of this feature's own two-input framing
/// (`TasteProfile?`, `List<UserMediaEntry>`), but resolving
/// `Vibe.ruleFor` needs one — E1's "First tap: movie or TV show?"
/// always happens before Surprise-me ever reaches this builder, so the
/// caller already has it on hand.
///
/// [excludeWatched] is always `true` in the result: DECISIONS.md's own
/// wording ("used, refined with my_list signals, excludes watched
/// items") makes this a fixed behavior of the profile-based path, not a
/// question — unlike the quiz (E2), which has an actual toggle for it.
/// [ParticipantAnswers.maxRuntimeMinutes]/[ParticipantAnswers.tvStatus]/
/// [ParticipantAnswers.maxSeasons] stay `null` (no limit): neither
/// [TasteProfile] nor [UserMediaEntry] carries anything those three
/// could reasonably come from.
///
/// Instantiated with its own [vibeCatalog] rather than exposed as static
/// methods taking one per call — `SurpriseCubit` (the feature that
/// actually uses this) receives it alongside `MatchEngine` through its
/// own constructor, so this needs the same "one instance, injectable"
/// shape `MatchEngine` already has, not a bag of static helpers.
/// Not `@LazySingleton`-registered: [VibeCatalog] itself isn't
/// DI-registered either (`VibeCatalog.loadFromAssets()` is async and
/// nothing wires it through `get_it` yet — see `MyTastesScreen`'s own
/// `FutureBuilder` for the same reason), so whoever needs this
/// constructs both by hand, the same way `QuizScreen` already does for
/// `VibeCatalog` alone.
class TasteProfileBuilder {
  const TasteProfileBuilder(this.vibeCatalog);

  final VibeCatalog vibeCatalog;

  /// "No profile but `my_list` has ≥ 5 items" (DECISIONS.md's own
  /// wording) — the *total* entry count, not a filtered subset.
  static const int minInferredEntries = 5;

  /// E2's own "up to 3" veto cap — applied here too so a `TasteProfile`
  /// with more vetoes than the quiz would ever allow (My Tastes doesn't
  /// cap `vetoedGenres`) still produces a valid `ParticipantAnswers`.
  static const int maxExcludedGenres = 3;

  /// E2's own "exactly 3" vibe requirement.
  static const int requiredVibeCount = 3;

  /// Same default `MyTastesState`/`QuizState` already use for "how far
  /// back" — an inferred profile has no release-year signal to derive
  /// one from (`UserMediaEntry` carries no release date at all).
  static const int inferredDefaultYearFrom = 1990;

  ParticipantAnswers? build({
    required TasteProfile? profile,
    required List<UserMediaEntry> libraryEntries,
    required MediaType mediaType,
    required String participantId,
  }) {
    final Set<Genre> likedGenres;
    final Set<Genre> vetoedGenres;
    final Set<String> likedVibes;
    final int yearFrom;

    if (profile != null) {
      likedGenres = profile.likedGenres;
      vetoedGenres = profile.vetoedGenres;
      likedVibes = profile.likedVibes;
      yearFrom = profile.yearFrom;
    } else if (libraryEntries.length >= minInferredEntries) {
      final affinity = _genreAffinity(libraryEntries);
      likedGenres = {
        for (final entry in affinity.entries)
          if (entry.value > 0) entry.key,
      };
      vetoedGenres = const {};
      likedVibes = const {};
      yearFrom = inferredDefaultYearFrom;
    } else {
      return null;
    }

    final excludedGenres = _capped(vetoedGenres, maxExcludedGenres);
    final vibeIds = _completeVibes(
      existingVibes: likedVibes,
      likedGenres: likedGenres,
      vetoedGenres: vetoedGenres,
      affinity: _genreAffinity(libraryEntries),
      mediaType: mediaType,
    );
    final watchedKeys = {
      for (final entry in libraryEntries)
        if (entry.isWatched) entry.key,
    };

    return ParticipantAnswers(
      participantId: participantId,
      excludedGenres: excludedGenres,
      vibeIds: vibeIds,
      yearFrom: yearFrom,
      excludeWatched: true,
      watchedKeys: watchedKeys,
    );
  }

  /// Per-genre affinity from [entries]: +1 for each favorite or ≥4-star
  /// watch touching that genre, -1 for each ≤2-star watch. An entry with
  /// neither signal (unrated, or rated 3) contributes nothing. Purely a
  /// ranking signal for [_completeVibes] — never read for anything else.
  static Map<Genre, int> _genreAffinity(List<UserMediaEntry> entries) {
    final affinity = <Genre, int>{};
    for (final entry in entries) {
      final rating = entry.rating;
      final isBoost = entry.isFavorite || (rating != null && rating >= 4);
      final isPenalty = rating != null && rating <= 2;
      if (!isBoost && !isPenalty) continue;

      final delta = isBoost ? 1 : -1;
      for (final genre in entry.genres) {
        affinity[genre] = (affinity[genre] ?? 0) + delta;
      }
    }
    return affinity;
  }

  /// Deterministic (sorted by [Genre.id]) truncation — [TasteProfile]
  /// doesn't rank its own vetoes, so there's no "strongest 3" to prefer,
  /// only a reproducible one.
  static Set<Genre> _capped(Set<Genre> genres, int max) {
    if (genres.length <= max) return genres;
    final sorted = genres.toList()..sort((a, b) => a.id.compareTo(b.id));
    return sorted.take(max).toSet();
  }

  /// Tops [existingVibes] up to exactly [requiredVibeCount] (or trims
  /// down to it, for a profile that somehow stored more than the quiz
  /// would ever allow) by mapping [likedGenres] to vibes via
  /// [vibeCatalog], highest-[affinity] genre first (ties broken by
  /// [Genre.id] for a reproducible order). A vetoed genre is never used
  /// as a source, even one with positive affinity — the explicit veto
  /// always wins. If [likedGenres] runs out before reaching
  /// [requiredVibeCount] (no signal at all, or every mappable vibe
  /// already picked), the result is simply smaller than 3 rather than
  /// an error — a thinner answer, not an invalid one.
  Set<String> _completeVibes({
    required Set<String> existingVibes,
    required Set<Genre> likedGenres,
    required Set<Genre> vetoedGenres,
    required Map<Genre, int> affinity,
    required MediaType mediaType,
  }) {
    if (existingVibes.length == requiredVibeCount) return existingVibes;
    if (existingVibes.length > requiredVibeCount) {
      final sorted = existingVibes.toList()..sort();
      return sorted.take(requiredVibeCount).toSet();
    }

    final vibeIds = Set<String>.of(existingVibes);
    final rankedGenres = likedGenres.where((g) => !vetoedGenres.contains(g)).toList()
      ..sort((a, b) {
        final byAffinity = (affinity[b] ?? 0).compareTo(affinity[a] ?? 0);
        return byAffinity != 0 ? byAffinity : a.id.compareTo(b.id);
      });

    for (final genre in rankedGenres) {
      if (vibeIds.length >= requiredVibeCount) break;
      final vibe = _firstUnpickedVibeFor(genre, mediaType, vibeIds);
      if (vibe != null) vibeIds.add(vibe.id);
    }

    return vibeIds;
  }

  Vibe? _firstUnpickedVibeFor(
    Genre genre,
    MediaType mediaType,
    Set<String> alreadyPicked,
  ) {
    for (final vibe in vibeCatalog.availableFor(mediaType)) {
      if (alreadyPicked.contains(vibe.id)) continue;
      if (vibe.ruleFor(mediaType).genreIds.contains(genre.id)) {
        return vibe;
      }
    }
    return null;
  }
}
