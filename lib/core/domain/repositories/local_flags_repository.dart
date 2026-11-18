import '../entities/result.dart';

/// Small on/off facts the app remembers on the device, by name — "has this
/// one-time hint been shown yet". Local only; not a setting the user edits
/// (those live in `SettingsRepository`).
abstract interface class LocalFlagsRepository {
  /// Whether [flag] was set; `false` for one never set.
  Future<bool> isSet(LocalFlag flag);

  Future<Result<void>> set(LocalFlag flag);
}

/// The flags the app keeps. Add a value here, not a loose string.
enum LocalFlag {
  /// Surprise me's first-time tour (swipe, tap to turn over, double-tap to
  /// choose) was finished or skipped.
  surpriseTourSeen,
}
