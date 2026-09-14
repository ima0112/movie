import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: this is a session-local stand-in. Once `UserLibraryRepository`
// exists, the hero's save button should read/write real Watch later
// state through it instead, and this Cubit goes away.
/// Tracks which [MediaItem.id]s have been toggled "saved" (Watch later)
/// from the Discover hero, in memory, for the lifetime of the app.
///
/// Deliberately separate from [DiscoverCubit]: toggling one item's saved
/// state has nothing to do with "is Discover's catalog data loading, or
/// did it fail" — keeping it a distinct piece of state is what lets a
/// single hero card's save button be the only thing that rebuilds when
/// it's tapped (see the project's CLAUDE.md rule 9).
class SavedIdsCubit extends Cubit<Set<int>> {
  SavedIdsCubit() : super(const {});

  void toggle(int id) {
    final next = Set<int>.of(state);
    if (!next.remove(id)) {
      next.add(id);
    }
    emit(next);
  }
}
