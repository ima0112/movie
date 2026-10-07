import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent implementation of [SettingsRepository] — SQLite (drift)
/// via [AppDatabase]. Always reads/writes row `id = 0`
/// ([SettingsTable]'s single-row convention, same as
/// [DriftOnboardingRepository]'s own table).
///
/// `@LazySingleton`, no environment split. [current] starts at the same
/// `en`/`US` fallback [LocaleInterceptor] itself defaults to, until
/// [load] resolves — see [SettingsRepository]'s own interface doc
/// comment for why it's synchronous at all.
@LazySingleton(as: SettingsRepository)
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db) : _systemLocale = _defaultSystemLocale;

  /// Test-only seam: injectable can only generate a registration for
  /// the default constructor above, so the overridable system-locale
  /// resolver lives on this second, named constructor instead of an
  /// optional parameter on it.
  DriftSettingsRepository.withSystemLocale(this._db, this._systemLocale);

  final AppDatabase _db;

  /// A seam so tests can simulate any system locale without touching
  /// the real platform binding — defaults to the actual device locale.
  final Locale Function() _systemLocale;

  static Locale _defaultSystemLocale() => PlatformDispatcher.instance.locale;

  AppSettings _current = const AppSettings(
    languageCode: 'en',
    regionCode: 'US',
  );

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {
    final query = _db.select(_db.settingsTable)
      ..where((row) => row.id.equals(0));
    final row = await query.getSingleOrNull();
    if (row != null) {
      _current = _toSettings(row);
      return;
    }
    // Nothing saved yet (this device's first launch) — compute a
    // default from the system locale and persist it immediately, so
    // it stays stable even if the system locale changes later without
    // the user ever opening Settings (see SettingsRepository.load's
    // own doc comment).
    await _persist(_defaultFromSystemLocale());
  }

  @override
  Stream<AppSettings> watch() {
    final query = _db.select(_db.settingsTable)
      ..where((row) => row.id.equals(0));
    return query.watchSingleOrNull().map(
      (row) => row == null ? _current : _toSettings(row),
    );
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      await _persist(settings);
      return const Success(null);
    } catch (e) {
      return Failure('Could not save settings: $e');
    }
  }

  Future<void> _persist(AppSettings settings) async {
    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(
          SettingsTableCompanion.insert(
            id: const Value(0),
            languageCode: settings.languageCode,
            regionCode: settings.regionCode,
          ),
        );
    _current = settings;
  }

  /// "idioma es o en según el locale del sistema (si es otro, en);
  /// región del countryCode del locale (si no existe, US)".
  AppSettings _defaultFromSystemLocale() {
    final locale = _systemLocale();
    return AppSettings(
      languageCode: locale.languageCode == 'es' ? 'es' : 'en',
      regionCode: locale.countryCode ?? 'US',
    );
  }

  AppSettings _toSettings(SettingsRow row) =>
      AppSettings(languageCode: row.languageCode, regionCode: row.regionCode);
}
