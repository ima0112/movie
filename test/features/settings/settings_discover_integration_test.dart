import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:movies/features/settings/presentation/cubit/settings_cubit.dart';

/// End-to-end proof for this branch's own manual-verification claim
/// ("cambiar el idioma... y ver cambiar... Descubrir sin reiniciar"):
/// the real action a tap on H5 performs — `SettingsCubit.setLanguage`,
/// not a raw repository write — reaches `DiscoverCubit` through the
/// one shared `SettingsRepository`, with no restart and no direct link
/// between the two Cubits.
class _CountingDiscoverCubit extends DiscoverCubit {
  _CountingDiscoverCubit(super.mediaRepository, super.settingsRepository);

  int loadCount = 0;

  @override
  Future<void> loadDiscover(MediaSegment segment) {
    loadCount++;
    return super.loadDiscover(segment);
  }
}

void main() {
  test(
    'SettingsCubit.setLanguage (H5\'s own "tap to apply") reloads an '
    'already-open Discover exactly once, through the shared '
    'SettingsRepository — no direct reference between the two Cubits',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final settingsRepository = DriftSettingsRepository(db);

      final discoverCubit = _CountingDiscoverCubit(
        FakeMediaRepository(),
        settingsRepository,
      );
      addTearDown(discoverCubit.close);
      await discoverCubit.loadDiscover(MediaSegment.all);
      expect(discoverCubit.loadCount, 1);

      final settingsCubit = SettingsCubit(settingsRepository);
      addTearDown(settingsCubit.close);

      await settingsCubit.setLanguage('es');
      await pumpEventQueue();

      expect(settingsCubit.state.languageCode, 'es');
      expect(discoverCubit.loadCount, 2);

      // Let the triggered reload fully settle before either Cubit
      // closes, so no in-flight emit races a close().
      await discoverCubit.stream.firstWhere((s) => s is DiscoverLoaded);
    },
  );
}
