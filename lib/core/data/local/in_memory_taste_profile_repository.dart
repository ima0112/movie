import 'dart:async';

import '../../domain/entities/result.dart';
import '../../domain/entities/taste_profile.dart';
import '../../domain/repositories/taste_profile_repository.dart';

/// In-memory stand-in for [TasteProfileRepository] — same reasoning as
/// `InMemoryUserProfileRepository`'s own doc comment, for the same
/// full-app-test need. Not `@LazySingleton`: only one implementation
/// may be registered `as: TasteProfileRepository`.
class InMemoryTasteProfileRepository implements TasteProfileRepository {
  TasteProfile? _profile;
  final _controller = StreamController<TasteProfile?>.broadcast();

  @override
  Stream<TasteProfile?> watch() async* {
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> save(TasteProfile profile) async {
    _profile = profile;
    _controller.add(profile);
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    _profile = null;
    _controller.add(null);
    return const Success(null);
  }
}
