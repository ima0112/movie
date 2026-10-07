import '../entities/app_settings.dart';
import '../entities/result.dart';

/// The user's own TMDB content preferences (F11) — `domain` contract
/// only, per CLAUDE.md rule 2. There is no global preferences Cubit on
/// top of this: `SettingsCubit` (Settings screen only, a later branch)
/// is the single, screen-local subscriber; anything else that needs a
/// current value (e.g. a future locale-aware `ApiClient` interceptor)
/// reads [current] or [watch] directly.
///
/// [current] is synchronous and always available — the same "cache a
/// plain value, swap it once the real load resolves" shape
/// `OnboardingRepository.isCompleted` already uses, and for the same
/// reason: this must have a usable value before the router or any TMDB
/// request reads it, and neither of those can await an async load on
/// every access. [load] is called once, during app startup, before
/// either of those can run — see `app/splash_gate.dart`.
abstract interface class SettingsRepository {
  AppSettings get current;

  /// Reads the persisted settings into [current]. On this device's
  /// very first launch (nothing saved yet), computes a default from the
  /// system locale and persists it immediately, so [current] and
  /// [watch] agree from the very first read and don't silently drift if
  /// the system locale changes later without the user ever opening
  /// Settings. Idempotent — safe to call more than once, though nothing
  /// in this app does.
  Future<void> load();

  /// Reactive stream for a future `SettingsCubit` to subscribe to,
  /// mirroring `UserLibraryRepository.watch` (rule 10) rather than a
  /// library-wide Cubit holding its own copy.
  Stream<AppSettings> watch();

  Future<Result<void>> save(AppSettings settings);
}
