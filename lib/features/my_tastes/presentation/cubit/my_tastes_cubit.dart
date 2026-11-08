import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../core/domain/entities/genre.dart';
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
    emit(MyTastesState.fromProfile(profile, state.availableVibes));
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

  /// "Vibes you like" — no exclusivity, no limit (same as onboarding's
  /// own genre step: "multi-select, no limit").
  void toggleVibe(String vibeId) {
    _apply(state.copyWith(likedVibes: _toggled(state.likedVibes, vibeId)));
  }

  /// "How far back".
  void setYearFrom(int year) => _apply(state.copyWith(yearFrom: year));

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
