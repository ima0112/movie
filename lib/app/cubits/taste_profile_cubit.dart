import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/entities/result.dart';
import '../../core/domain/entities/taste_profile.dart';
import '../../core/domain/repositories/taste_profile_repository.dart';

/// The local user's taste profile, kept live for the whole app.
///
/// **Global**, per CLAUDE.md rule 10: C5 ("My Tastes"), B5's summary
/// card, B1's invitation card, and the match engine all need the same
/// current value, not each their own copy. Provided once in
/// `app/app.dart`, above `MaterialApp.router`.
///
/// State is `null` both before the repository's first emission and when
/// no taste profile has ever been built — same "none yet" meaning
/// [TasteProfileRepository.watch] itself uses; B1/B5 already render
/// their own "no taste profile" empty state for the latter, so a brief
/// `null` on cold start while the first value loads needs no separate
/// handling here.
class TasteProfileCubit extends Cubit<TasteProfile?> {
  TasteProfileCubit(this._repository) : super(null) {
    _subscription = _repository.watch().listen(emit);
  }

  final TasteProfileRepository _repository;
  late final StreamSubscription<TasteProfile?> _subscription;

  /// C5 auto-saves on every edit — the new value reaches [state] via
  /// [_repository]'s own stream re-emitting, not by emitting here
  /// directly.
  Future<Result<void>> save(TasteProfile profile) => _repository.save(profile);

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
