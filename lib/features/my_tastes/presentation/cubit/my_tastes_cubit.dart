import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import 'my_tastes_state.dart';

/// Orchestrates C5's editing UI on top of the *global* [TasteProfileCubit]
/// (CLAUDE.md rule 10) — this Cubit never becomes a second source of
/// truth for the taste profile. It:
/// - subscribes to [TasteProfileCubit]'s stream so its own state stays in
///   sync with the real profile, including a change made elsewhere (a
///   future onboarding flow, say) while C5 happens to be open;
/// - optimistically updates its own state on every edit and fires the
///   write at [TasteProfileCubit] itself (`unawaited`, the same toggle
///   pattern `MovieActionRow` already uses for My List) rather than
///   waiting for the round trip — this isn't a competing copy of the
///   profile, it's this one screen's own editing-session view of it,
///   always written back through the same global Cubit;
/// - reads [VibeCatalog] once to populate "Vibes you like"'s options —
///   the global `TasteProfileCubit` only knows which vibes are *liked*,
///   not the full catalog of choices to render as tappable tiles.
///
/// **Known gap, out of this Cubit's scope**: "Genres you like"/"Genres
/// you never want" need a fixed list of every selectable genre to
/// render their own grids, and there's no such catalog anywhere in
/// `core/domain` yet — the same gap `DriftTasteProfileRepository`'s own
/// doc comment already flags ("there isn't a normalized genre catalog
/// in core/domain yet"). This Cubit only knows how to toggle whichever
/// `Genre` it's handed via [toggleLikedGenre]/[toggleVetoedGenre];
/// enumerating the full genre list is left for whoever assembles C5's
/// actual screen.
class MyTastesCubit extends Cubit<MyTastesState> {
  MyTastesCubit(this._tasteProfileCubit, VibeCatalog vibeCatalog)
    : super(
        MyTastesState.fromProfile(_tasteProfileCubit.state, vibeCatalog.all()),
      ) {
    _subscription = _tasteProfileCubit.stream.listen(_onProfileChanged);
  }

  final TasteProfileCubit _tasteProfileCubit;
  late final StreamSubscription<TasteProfile?> _subscription;
  Timer? _savedIndicatorTimer;

  static const _savedIndicatorDuration = Duration(seconds: 2);

  void _onProfileChanged(TasteProfile? profile) {
    final next = MyTastesState.fromProfile(profile, state.availableVibes);
    // The save we just made echoes back through the global cubit: keep the
    // sets we already hold when they are equal, so the sections watching them
    // (each with its own selector) don't rebuild for their own edit.
    Set<T> keep<T>(Set<T> current, Set<T> incoming) =>
        setEquals(current, incoming) ? current : incoming;
    emit(
      next.copyWith(
        likedGenres: keep(state.likedGenres, next.likedGenres),
        vetoedGenres: keep(state.vetoedGenres, next.vetoedGenres),
        likedVibes: keep(state.likedVibes, next.likedVibes),
        platformIds: keep(state.platformIds, next.platformIds),
        justSaved: state.justSaved,
      ),
    );
  }

  /// "Genres you like" — mutually exclusive with vetoed
  /// (`docs/SCREENS.md` C5): liking a genre clears it from "never want"
  /// if it was there.
  void toggleLikedGenre(Genre genre) {
    final liked = _toggled(state.likedGenres, genre);
    final stillLiked = liked.contains(genre);
    final vetoed = stillLiked
        ? (Set<Genre>.of(state.vetoedGenres)..remove(genre))
        : state.vetoedGenres;
    _apply(state.copyWith(likedGenres: liked, vetoedGenres: vetoed));
  }

  /// "Genres you never want" — same mutual exclusivity, the other way.
  void toggleVetoedGenre(Genre genre) {
    final vetoed = _toggled(state.vetoedGenres, genre);
    final stillVetoed = vetoed.contains(genre);
    final liked = stillVetoed
        ? (Set<Genre>.of(state.likedGenres)..remove(genre))
        : state.likedGenres;
    _apply(state.copyWith(likedGenres: liked, vetoedGenres: vetoed));
  }

  /// "Vibes you like" — up to [MyTastesState.maxVibes]: picking another one
  /// past the limit does nothing (deselecting always works).
  void toggleVibe(String vibeId) {
    final liked = state.likedVibes;
    if (!liked.contains(vibeId) && liked.length >= MyTastesState.maxVibes) {
      return;
    }
    _apply(state.copyWith(likedVibes: _toggled(liked, vibeId)));
  }

  /// "Eras": the release years [from]–[to] we lean towards. A [to] of
  /// [latestYear] means "up to today" and is kept as `null`.
  void setYearRange(int from, int to, {required int latestYear}) {
    _apply(
      to >= latestYear
          ? state.copyWith(yearFrom: from, clearYearTo: true)
          : state.copyWith(yearFrom: from, yearTo: to),
    );
  }

  /// "What do you usually watch?": a type, or `null` for both.
  void setPreferredType(MediaType? type) => _apply(
    type == null
        ? state.copyWith(clearPreferredType: true)
        : state.copyWith(preferredType: type),
  );

  /// "My platforms": a streaming service on or off (TMDB provider id).
  void togglePlatform(int providerId) {
    _apply(
      state.copyWith(platformIds: _toggled(state.platformIds, providerId)),
    );
  }

  /// C5's "Reset" link — clears every selection back to a blank slate,
  /// not a delete: `TasteProfileRepository` has no delete, only `save`.
  void reset() {
    _apply(
      MyTastesState(
        likedGenres: const {},
        vetoedGenres: const {},
        likedVibes: const {},
        yearFrom: MyTastesState.defaultYearFrom,
        availableVibes: state.availableVibes,
      ),
    );
  }

  void _apply(MyTastesState next) {
    emit(next.copyWith(justSaved: true));
    unawaited(
      _tasteProfileCubit.save(
        TasteProfile(
          likedGenres: next.likedGenres,
          vetoedGenres: next.vetoedGenres,
          likedVibes: next.likedVibes,
          yearFrom: next.yearFrom,
          yearTo: next.yearTo,
          preferredType: next.preferredType,
          platformIds: next.platformIds,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _savedIndicatorTimer?.cancel();
    _savedIndicatorTimer = Timer(_savedIndicatorDuration, () {
      if (!isClosed) emit(state.copyWith(justSaved: false));
    });
  }

  static Set<T> _toggled<T>(Set<T> set, T value) {
    final next = Set<T>.of(set);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  @override
  Future<void> close() {
    _savedIndicatorTimer?.cancel();
    unawaited(_subscription.cancel());
    return super.close();
  }
}
