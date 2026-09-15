import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/entities/result.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/repositories/user_profile_repository.dart';

/// The local user's own profile, kept live for the whole app.
///
/// **Global**, per CLAUDE.md rule 10: its lifecycle isn't tied to any one
/// screen — B5's header, H10's edit sheet, and (v1.1) a Matcher room's
/// "You'll join as Daniel" row all need the same current value, not each
/// their own copy. Provided once in `app/app.dart`, above
/// `MaterialApp.router`.
///
/// State is `null` both before the repository's first emission and when
/// no profile has ever been saved — same "no profile yet" meaning
/// [UserProfileRepository.watch] itself uses; B5 already has to render a
/// "no name" empty state for the latter, so a brief `null` on cold start
/// while the first value loads needs no separate handling here.
class UserProfileCubit extends Cubit<UserProfile?> {
  UserProfileCubit(this._repository) : super(null) {
    _subscription = _repository.watch().listen(emit);
  }

  final UserProfileRepository _repository;
  late final StreamSubscription<UserProfile?> _subscription;

  /// H10's "Save" — the new value reaches [state] via [_repository]'s own
  /// stream re-emitting, not by emitting here directly.
  Future<Result<void>> save(UserProfile profile) => _repository.save(profile);

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
