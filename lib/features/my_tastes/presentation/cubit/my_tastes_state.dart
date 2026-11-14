import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_type.dart';
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
    this.yearTo,
    this.preferredType,
    this.platformIds = const {},
    this.justSaved = false,
  });

  /// "Up to 5" vibes (C5: "Hasta 5. Marcan el tono de lo que te sugerimos.").
  static const int maxVibes = 5;

  /// A brand-new profile's "How far back" default. No doc gives one
  /// explicitly; 1990 matches the sample value this codebase's own
  /// `TasteProfile` test fixtures already use.
  static const int defaultYearFrom = 1990;

  final Set<Genre> likedGenres;
  final Set<Genre> vetoedGenres;
  final Set<String> likedVibes;
  final int yearFrom;

  /// The eras' upper bound; `null` = today.
  final int? yearTo;

  /// "What do you usually watch?": a type, or `null` for both.
  final MediaType? preferredType;

  /// Selected streaming services (TMDB provider ids).
  final Set<int> platformIds;

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
      yearTo: profile?.yearTo,
      preferredType: profile?.preferredType,
      platformIds: profile?.platformIds ?? const {},
      availableVibes: availableVibes,
    );
  }

  MyTastesState copyWith({
    Set<Genre>? likedGenres,
    Set<Genre>? vetoedGenres,
    Set<String>? likedVibes,
    int? yearFrom,
    int? yearTo,
    bool clearYearTo = false,
    MediaType? preferredType,
    bool clearPreferredType = false,
    Set<int>? platformIds,
    bool? justSaved,
  }) {
    return MyTastesState(
      likedGenres: likedGenres ?? this.likedGenres,
      vetoedGenres: vetoedGenres ?? this.vetoedGenres,
      likedVibes: likedVibes ?? this.likedVibes,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: clearYearTo ? null : (yearTo ?? this.yearTo),
      preferredType: clearPreferredType
          ? null
          : (preferredType ?? this.preferredType),
      platformIds: platformIds ?? this.platformIds,
      availableVibes: availableVibes,
      justSaved: justSaved ?? this.justSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MyTastesState &&
      setEquals(other.likedGenres, likedGenres) &&
      setEquals(other.vetoedGenres, vetoedGenres) &&
      setEquals(other.likedVibes, likedVibes) &&
      other.yearFrom == yearFrom &&
      other.yearTo == yearTo &&
      other.preferredType == preferredType &&
      setEquals(other.platformIds, platformIds) &&
      other.justSaved == justSaved;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(likedGenres),
    Object.hashAllUnordered(vetoedGenres),
    Object.hashAllUnordered(likedVibes),
    yearFrom,
    yearTo,
    preferredType,
    Object.hashAllUnordered(platformIds),
    justSaved,
  );
}
