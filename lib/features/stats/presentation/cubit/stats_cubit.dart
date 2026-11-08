import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../domain/library_stats.dart';
import '../../domain/library_stats_calculator.dart';

/// C4 (Stats)'s state: the current "All · Movies · TV Shows" filter
/// (`docs/SCREENS.md` C4's own chips) plus the [LibraryStats] computed
/// for it. Reuses [MediaType]? directly (`null` = "All") rather than a
/// new enum — it's exactly what [calculateLibraryStats]'s own
/// `filterType` parameter already takes.
class StatsState {
  const StatsState({required this.filterType, required this.stats});

  final MediaType? filterType;
  final LibraryStats stats;
}

/// Screen-local Cubit for C4 — created where its `BlocProvider` is
/// placed (the Stats screen), never registered in `di.config.dart`.
///
/// This is **not** the Cubit CLAUDE.md rule 10 warns against ("don't
/// create a library-wide Cubit holding an in-memory copy of the whole
/// list"): that rule targets a *shared* cache other screens would
/// piggyback on instead of subscribing to [UserLibraryRepository]
/// themselves (a favorite icon, a single entry's status...). Stats is
/// the opposite case — its one screen's entire purpose is an aggregate
/// over the whole watched list, so holding that aggregate as this
/// Cubit's own, screen-local state is the same shape as `DiscoverCubit`
/// (a Cubit owning computed state for its own screen), not the shared
/// cache rule 10 rules out.
///
/// Subscribes to [UserLibraryRepository.watch] — not `.all()`, which is
/// a one-shot `Future`, not a stream; this needs to live-update as
/// entries are watched/unwatched while C4 stays open, and recomputes
/// [LibraryStats] on every emission via [calculateLibraryStats].
class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._userLibraryRepository)
    : super(
        StatsState(filterType: null, stats: calculateLibraryStats(const [])),
      ) {
    _subscription = _userLibraryRepository.watch().listen(_onEntries);
  }

  final UserLibraryRepository _userLibraryRepository;
  late final StreamSubscription<List<UserMediaEntry>> _subscription;
  List<UserMediaEntry> _entries = const [];

  /// `null` selects "All".
  void selectFilter(MediaType? filterType) {
    emit(
      StatsState(
        filterType: filterType,
        stats: calculateLibraryStats(_entries, filterType: filterType),
      ),
    );
  }

  void _onEntries(List<UserMediaEntry> entries) {
    _entries = entries;
    emit(
      StatsState(
        filterType: state.filterType,
        stats: calculateLibraryStats(entries, filterType: state.filterType),
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
