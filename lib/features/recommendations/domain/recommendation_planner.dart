import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/taste_profile.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import '../../match_engine/domain/vibe.dart';
import '../../match_engine/domain/vibe_catalog.dart';
import 'daily_picker.dart';

/// What a "Because you…" section is built around.
sealed class BecauseSeed {
  const BecauseSeed();
}

/// A saved title ("Because you like {title}") → `/recommendations`.
final class TitleSeed extends BecauseSeed {
  const TitleSeed(this.entry);

  final UserMediaEntry entry;
}

/// A liked genre ("Because you like {genre}") → `/discover`.
final class GenreSeed extends BecauseSeed {
  const GenreSeed(this.genre);

  final Genre genre;
}

/// A liked vibe ("Because you want {vibe}") → `/discover`.
final class VibeSeed extends BecauseSeed {
  const VibeSeed(this.vibe);

  final Vibe vibe;
}

/// What B1's recommendation sections show today: the "For you" request, and
/// the seeds of the "Because you…" sections. A `null` field = that section
/// doesn't exist today (no signal).
class RecommendationPlan {
  const RecommendationPlan({this.forYou, this.becauseLike, this.becauseWant});

  static const empty = RecommendationPlan();

  final DiscoverFilter? forYou;

  /// "Because you like …" — a title (Movies/TV Shows) or a genre (All).
  final BecauseSeed? becauseLike;

  /// "Because you want {vibe}" — the All tab only.
  final VibeSeed? becauseWant;
}

/// Decides, per segment and per day, what B1's recommendation sections are
/// about (`docs/DECISIONS.md` F1b). No AI and no network: it rotates through
/// the user's own signal with [DailyPicker], so what they see changes from
/// day to day — and with their tastes and My List — without ever being random
/// within a day.
///
/// - **All** follows the *taste profile* only: no usable profile, no sections.
///   "For you" mixes up to two liked genres/vibes; "Because you like" is one
///   liked genre; "Because you want" is one liked vibe.
/// - **Movies / TV Shows** follow *My List* only: "For you" is built from up
///   to two genres the user has positive signal for (favorites and ≥4★
///   watches, minus what they rated badly); "Because you like" is one saved
///   title.
///
/// A title can seed "Because you like" only if it is a favorite, was watched
/// and rated ≥4★, or is in Watch later (the weakest signal). Something
/// watched and rated ≤3★ — or watched and never rated — never is: there is
/// no evidence they liked it.
class RecommendationPlanner {
  const RecommendationPlanner(this.vibeCatalog);

  final VibeCatalog vibeCatalog;

  /// Weights of a saved title as a seed.
  static const int favoriteWeight = 3;
  static const int lovedWeight = 3; // rated 5★
  static const int likedWeight = 2; // rated 4★
  static const int watchLaterWeight = 1;

  RecommendationPlan plan({
    required MediaType? type,
    required TasteProfile? profile,
    required List<UserMediaEntry> library,
    required DateTime today,
  }) {
    final picker = DailyPicker(today);
    return type == null
        ? _fromTastes(profile, picker)
        : _fromLibrary(type, library, picker);
  }

  // --- All: the taste profile ---------------------------------------------

  RecommendationPlan _fromTastes(TasteProfile? profile, DailyPicker picker) {
    if (profile == null || !profile.isUsableForSuggestions) {
      return RecommendationPlan.empty;
    }
    final genres = profile.likedGenres.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final vibes =
        profile.likedVibes
            .map(vibeCatalog.byId)
            .nonNulls
            .where((v) => v.isMeaningfulFor(MediaType.movie))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    final likeGenre = picker.pick([
      for (final g in genres) (g, 1),
    ], salt: 'all-like');
    final wantVibe = picker.pick([
      for (final v in vibes) (v, 1),
    ], salt: 'all-want');

    // "For you" mixes up to two tastes, preferring ones the other two
    // sections aren't already about.
    final units = <Object>[for (final g in genres) g, for (final v in vibes) v];
    final fresh = units.where((u) => u != likeGenre && u != wantVibe).toList();
    final pool = fresh.isEmpty ? units : fresh;
    final chosen = picker.pickMany(
      [for (final u in pool) (u, 1)],
      count: 2,
      salt: 'all-for-you',
    );

    final withGenres = <Genre>{};
    final keywords = <int>{};
    for (final u in chosen) {
      if (u is Genre) {
        withGenres.add(u);
      } else if (u is Vibe) {
        withGenres.addAll(u.genresFor(MediaType.movie));
        keywords.addAll(u.keywordIdsFor(MediaType.movie));
      }
    }
    return RecommendationPlan(
      forYou: withGenres.isEmpty && keywords.isEmpty
          ? null
          : DiscoverFilter(
              withGenres: withGenres,
              withoutGenres: profile.vetoedGenres,
              withKeywords: keywords,
            ),
      becauseLike: likeGenre == null ? null : GenreSeed(likeGenre),
      becauseWant: wantVibe == null ? null : VibeSeed(wantVibe),
    );
  }

  /// The filter behind a "Because you…" genre or vibe section.
  DiscoverFilter filterForSeed(BecauseSeed seed, TasteProfile? profile) =>
      switch (seed) {
        GenreSeed(:final genre) => DiscoverFilter(
          withGenres: {genre},
          withoutGenres: profile?.vetoedGenres ?? const {},
        ),
        VibeSeed(:final vibe) => DiscoverFilter(
          withGenres: vibe.genresFor(MediaType.movie),
          withoutGenres: profile?.vetoedGenres ?? const {},
          withKeywords: vibe.keywordIdsFor(MediaType.movie),
          yearTo: vibe.maxReleaseYear,
          minVoteAverage: vibe.minVoteAverage,
        ),
        TitleSeed() => throw ArgumentError(
          'a title seed uses /recommendations',
        ),
      };

  // --- Movies / TV Shows: My List -----------------------------------------

  RecommendationPlan _fromLibrary(
    MediaType type,
    List<UserMediaEntry> library,
    DailyPicker picker,
  ) {
    final entries = library.where((e) => e.key.type == type).toList()
      ..sort((a, b) => a.key.tmdbId.compareTo(b.key.tmdbId));

    final seeds = <(UserMediaEntry, int)>[
      for (final e in entries)
        if (seedWeight(e) case final w when w > 0) (e, w),
    ];
    final title = picker.pick(seeds, salt: 'title-$type');

    final affinity = genreAffinityFrom(entries);
    final liked = <(Genre, int)>[
      for (final e in affinity.entries)
        if (e.value > 0) (e.key, e.value),
    ]..sort((a, b) => a.$1.id.compareTo(b.$1.id));
    final chosen = picker.pickMany(liked, count: 2, salt: 'for-you-$type');
    final disliked = {
      for (final e in affinity.entries)
        if (e.value < 0) e.key,
    };

    return RecommendationPlan(
      forYou: chosen.isEmpty
          ? null
          : DiscoverFilter(
              type: type,
              withGenres: chosen.toSet(),
              withoutGenres: disliked.difference(chosen.toSet()),
            ),
      becauseLike: title == null ? null : TitleSeed(title),
    );
  }

  /// How worth basing a recommendation on [entry] is: 0 = not at all.
  static int seedWeight(UserMediaEntry entry) {
    final rating = entry.rating;
    final watched = entry.watchedAt != null;
    // Rated badly (or ≤3★ at all): they saw it and didn't love it.
    if (rating != null && rating <= 3) return 0;
    if (rating == 5) return lovedWeight;
    if (entry.isFavorite) return favoriteWeight;
    if (rating == 4) return likedWeight;
    // Watched with no rating and not a favorite: no evidence either way.
    if (watched) return 0;
    return entry.isWatchLater ? watchLaterWeight : 0;
  }
}
