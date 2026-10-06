import 'dart:async';

import '../../domain/entities/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// In-memory stand-in for [UserProfileRepository]. Superseded by
/// `DriftUserProfileRepository` as the app's real storage — kept,
/// unannotated, as a fast, dependency-free test double for full-app
/// widget tests (e.g. `onboarding_redirect_test.dart`'s own flow walk),
/// which otherwise hit the real Drift repository through the global
/// `UserProfileCubit` and need `path_provider`'s native platform
/// channel — unavailable in `flutter test`'s host environment, same
/// reasoning as `InMemoryUserLibraryRepository`'s own doc comment.
/// Not `@LazySingleton`: only one implementation may be registered
/// `as: UserProfileRepository`.
class InMemoryUserProfileRepository implements UserProfileRepository {
  UserProfile? _profile;
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> watch() async* {
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> save(UserProfile profile) async {
    _profile = profile;
    _controller.add(profile);
    return const Success(null);
  }
}
