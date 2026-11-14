import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/repositories/recently_viewed_repository.dart';

/// Home's "Recently viewed" (All tab): the titles whose detail the user
/// opened last, newest first, at most 10 — straight from
/// [RecentlyViewedRepository.watch], so it follows every detail opened
/// without anything having to refresh it.
///
/// Screen-local (CLAUDE.md rule 10): the list lives and dies with Home, and
/// nothing else reads it. The state is just the list (empty = the section
/// isn't drawn).
class RecentlyViewedCubit extends Cubit<List<MediaItem>> {
  RecentlyViewedCubit(RecentlyViewedRepository repository) : super(const []) {
    _subscription = repository.watch().listen(emit);
  }

  late final StreamSubscription<List<MediaItem>> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
