import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:movies/features/settings/presentation/cubit/settings_cubit.dart';

/// A fresh repository/cubit pair over an in-memory database — never
/// touches disk or `path_provider`, same reasoning as every other
/// drift-backed test in this app.
SettingsCubit _cubit() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return SettingsCubit(DriftSettingsRepository(db));
}

void main() {
  group('SettingsCubit', () {
    test('starts at the repository\'s own current value', () {
      final cubit = _cubit();

      expect(
        cubit.state,
        const AppSettings(languageCode: 'en', regionCode: 'US'),
      );

      cubit.close();
    });

    test('setLanguage saves the new language, keeping the current region', (
    ) async {
      final cubit = _cubit();

      await cubit.setLanguage('es');

      expect(cubit.state.languageCode, 'es');
      expect(cubit.state.regionCode, 'US');

      await cubit.close();
    });

    test('setRegion saves the new region, keeping the current language', (
    ) async {
      final cubit = _cubit();

      await cubit.setRegion('ES');

      expect(cubit.state.languageCode, 'en');
      expect(cubit.state.regionCode, 'ES');

      await cubit.close();
    });

    test(
      'setLanguage then setRegion ends with both new values, not one '
      'overwriting the other back to a stale default',
      () async {
        final cubit = _cubit();

        await cubit.setLanguage('es');
        await cubit.setRegion('MX');

        expect(
          cubit.state,
          const AppSettings(languageCode: 'es', regionCode: 'MX'),
        );

        await cubit.close();
      },
    );

    test('close() leaves no live subscription on the repository', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftSettingsRepository(db);
      final cubit = SettingsCubit(repository);
      await pumpEventQueue();

      await cubit.close();
      await pumpEventQueue();

      // A closed Cubit throws if anything still delivers to it — proven
      // indirectly: a further repository write must not crash despite
      // no one being subscribed to react to it.
      await repository.save(
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      );
      await pumpEventQueue();
    });
  });
}
