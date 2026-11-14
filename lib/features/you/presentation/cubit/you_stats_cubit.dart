import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/domain/stats/library_stats_calculator.dart';

/// The statistics You shows, recomputed whenever My List changes: `null`
/// until the first read, then a [LibraryStats] over every entry.
///
/// **Screen-local** (CLAUDE.md rule 10): it lives as long as the You page. It
/// holds the derived numbers, never a copy of the list — the repository's
/// stream is the source — and every section reads only its own slice with a
/// `BlocSelector` (rule 9); `LibraryStats` is value-equal, so a change that
/// leaves the numbers alone emits nothing.
class YouStatsCubit extends Cubit<LibraryStats?> {
  YouStatsCubit(UserLibraryRepository repository, {DateTime Function()? clock})
    : super(null) {
    _subscription = repository.watch().listen(
      (entries) => emit(calculateLibraryStats(entries, now: clock?.call())),
    );
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
