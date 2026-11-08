import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../match_engine/domain/vibe.dart';

/// C5 ("My Tastes")'s editing state — always renderable, never null.
/// `docs/SCREENS.md` C5's own "States: none special" means every
/// section (genres, vibes, "how far back") shows ready to edit even
/// before a [TasteProfile] exists yet, defaulting to empty selections
/// rather than a dedicated "no profile" screen state.
///
/// Split out of `my_tastes_cubit.dart` per CLAUDE.md rule 11.
class MyTastesState {
  const MyTastesState({
    required this.likedGenres,
    required this.vetoedGenres,
    required this.likedVibes,
    required this.yearFrom,
    required this.availableVibes,
    this.justSaved = false,
  });

  /// A brand-new profile's "How far back" default. No doc gives one
  /// explicitly; 1990 matches the sample value this codebase's own
  /// `TasteProfile` test fixtures already use.
  static const int defaultYearFrom = 1990;

  final Set<Genre> likedGenres;
  final Set<Genre> vetoedGenres;
  final Set<String> likedVibes;
  final int yearFrom;

  /// The full 16-vibe catalog (`VibeCatalog.all()`), resolved once at
  /// construction — the catalog itself never changes at runtime, unlike
  /// [likedVibes].
  final List<Vibe> availableVibes;

  /// Drives C5's "discreet 'Saved' text on change" — briefly `true`
  /// right after any edit, cleared a couple seconds later by
  /// `MyTastesCubit`'s own timer.
  final bool justSaved;

  factory MyTastesState.fromProfile(
    TasteProfile? profile,
    List<Vibe> availableVibes,
  ) {
    return MyTastesState(
      likedGenres: profile?.likedGenres ?? const {},
      vetoedGenres: profile?.vetoedGenres ?? const {},
      likedVibes: profile?.likedVibes ?? const {},
      yearFrom: profile?.yearFrom ?? defaultYearFrom,
      availableVibes: availableVibes,
    );
  }

  MyTastesState copyWith({
    Set<Genre>? likedGenres,
    Set<Genre>? vetoedGenres,
    Set<String>? likedVibes,
    int? yearFrom,
    bool? justSaved,
  }) {
    return MyTastesState(
      likedGenres: likedGenres ?? this.likedGenres,
      vetoedGenres: vetoedGenres ?? this.vetoedGenres,
      likedVibes: likedVibes ?? this.likedVibes,
      yearFrom: yearFrom ?? this.yearFrom,
      availableVibes: availableVibes,
      justSaved: justSaved ?? this.justSaved,
    );
  }
}
