import 'dart:ui' show Locale;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/persistence/app_database.dart';

/// A fresh repository over an in-memory database — see
/// `drift_onboarding_repository_test.dart`'s own version of this helper
/// for why (never touches disk or `path_provider`).
DriftSettingsRepository _repository({Locale systemLocale = const Locale('en', 'US')}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftSettingsRepository.withSystemLocale(db, () => systemLocale);
}

void main() {
  group('DriftSettingsRepository', () {
    test('current starts at the en/US fallback, before load() ever runs', () {
      final repository = _repository();

      expect(
        repository.current,
        const AppSettings(languageCode: 'en', regionCode: 'US'),
      );
    });

    test(
      'load() on a first launch (nothing saved) derives the language from '
      'a Spanish system locale and the region from its country code',
      () async {
        final repository = _repository(
          systemLocale: const Locale('es', 'MX'),
        );

        await repository.load();

        expect(
          repository.current,
          const AppSettings(languageCode: 'es', regionCode: 'MX'),
        );
      },
    );

    test(
      'load() falls back to en for any non-Spanish system locale',
      () async {
        final repository = _repository(
          systemLocale: const Locale('fr', 'FR'),
        );

        await repository.load();

        expect(repository.current.languageCode, 'en');
      },
    );

    test(
      'load() falls back to region US when the system locale has no '
      'country code',
      () async {
        final repository = _repository(systemLocale: const Locale('es'));

        await repository.load();

        expect(
          repository.current,
          const AppSettings(languageCode: 'es', regionCode: 'US'),
        );
      },
    );

    test(
      'load() persists the first-launch default, so a second instance over '
      'the same database loads it back instead of recomputing it from a '
      'now-different system locale',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        await DriftSettingsRepository.withSystemLocale(
          db,
          () => const Locale('es', 'MX'),
        ).load();

        final reloaded = DriftSettingsRepository.withSystemLocale(
          db,
          () => const Locale('fr', 'FR'),
        );
        await reloaded.load();

        expect(
          reloaded.current,
          const AppSettings(languageCode: 'es', regionCode: 'MX'),
        );
      },
    );

    test(
      'save() persists immediately and is reflected by current with no '
      'load() needed',
      () async {
        final repository = _repository();
        const settings = AppSettings(languageCode: 'es', regionCode: 'ES');

        final result = await repository.save(settings);

        expect(result, isA<Success<void>>());
        expect(repository.current, settings);
      },
    );

    test(
      'load() picks up a previously saved AppSettings from a fresh '
      'instance over the same database, not the system-locale default',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        await DriftSettingsRepository.withSystemLocale(
          db,
          () => const Locale('en', 'US'),
        ).save(const AppSettings(languageCode: 'es', regionCode: 'ES'));

        final reloaded = DriftSettingsRepository.withSystemLocale(
          db,
          () => const Locale('fr', 'FR'),
        );
        await reloaded.load();

        expect(
          reloaded.current,
          const AppSettings(languageCode: 'es', regionCode: 'ES'),
        );
      },
    );

    test('watch() emits the current settings, and again after save()', () async {
      final repository = _repository(systemLocale: const Locale('en', 'US'));
      await repository.load();

      final emitted = <AppSettings>[];
      final subscription = repository.watch().listen(emitted.add);
      addTearDown(subscription.cancel);

      await repository.save(
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      );
      await pumpEventQueue();

      expect(emitted, [
        const AppSettings(languageCode: 'en', regionCode: 'US'),
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      ]);
    });
  });
}
