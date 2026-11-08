import '../entities/result.dart';
import '../entities/user_profile.dart';

/// The local user's own profile — one row, never a list (see
/// `docs/DECISIONS.md` section 7, `UserProfileTable` in
/// `core/persistence/app_database.dart`).
///
/// `@LazySingleton` per CLAUDE.md rule 10: B5's header, H10's edit sheet,
/// and anywhere a room shows "You'll join as Daniel · Host" (E2/E3b) all
/// read the same [watch] stream rather than each holding their own copy.
abstract interface class UserProfileRepository {
  /// `null` = no profile saved yet — B5 renders Pako's silhouette and
  /// "Tap to set your name" for that case, not an empty [UserProfile].
  Stream<UserProfile?> watch();

  Future<Result<void>> save(UserProfile profile);
}
