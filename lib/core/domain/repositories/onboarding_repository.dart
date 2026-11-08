import '../entities/result.dart';

/// Whether this device has ever finished A2 (Onboarding) —
/// `docs/SCREENS.md` A2. One flag, not derived from [UserProfile]
/// (`core/domain/entities/user_profile.dart`) existing: onboarding
/// completion and "has a saved name" are kept as separate facts on
/// purpose, so a future "clear profile" action doesn't accidentally
/// re-trigger onboarding just because it wiped the name along with it.
///
/// `domain` contract only, per CLAUDE.md rule 2 — `app/router.dart`'s
/// own top-level `redirect` reads [isCompleted] (via `getIt`, the same
/// way its `MediaDetailNavigation` extension reads other repositories)
/// to send every route to `/welcome` until it's `true`, and `/welcome`
/// itself back to Discover once it is.
///
/// [isCompleted] is synchronous and always available — the same
/// "cache a plain value, swap it once the real load resolves" shape
/// `TmdbConfigurationService.current` already uses, and for the same
/// reason: `GoRouter`'s `redirect` runs on *every* navigation
/// (including pops), so making it `async` would add a real timing gap
/// to every single one — this app's own widget tests caught exactly
/// that as cross-test Cubit-after-close flakiness once a `redirect`
/// callback existed at all. [load] is called once, during app startup
/// (`main.dart`) before `runApp`, so [isCompleted] is already accurate
/// by the time anything — in particular that first redirect — reads
/// it.
abstract interface class OnboardingRepository {
  bool get isCompleted;

  /// Reads the persisted flag into [isCompleted]. Idempotent — safe to
  /// call more than once, though nothing in this app does.
  Future<void> load();

  Future<Result<void>> markCompleted();
}
