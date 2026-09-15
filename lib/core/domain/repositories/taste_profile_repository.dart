import '../entities/result.dart';
import '../entities/taste_profile.dart';

/// The local user's taste profile — one row, never a list (same
/// single-row convention as [UserProfileRepository]; see
/// `TasteProfileTable` in `core/persistence/app_database.dart`).
///
/// `@LazySingleton` per CLAUDE.md rule 10: C5 ("My Tastes"), B5's card
/// summarizing it, Discover/Explore's implicit use of it, and the match
/// engine all read the same [watch] stream.
abstract interface class TasteProfileRepository {
  /// `null` = never built one yet — B1's invitation card and B5's "My
  /// Tastes" card both render their own "no taste profile" state for
  /// this, not an empty [TasteProfile].
  Stream<TasteProfile?> watch();

  Future<Result<void>> save(TasteProfile profile);
}
