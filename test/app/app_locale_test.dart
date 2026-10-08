import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';

/// A controllable stand-in for [SettingsRepository] — see
/// `discover_cubit_test.dart`'s own copy of this class for why
/// `watch()` is shaped this way (replays [_current] to every new
/// subscriber, then forwards whatever the test pushes through
/// [controller]). Avoids a real drift-backed [AppDatabase]: its own
/// reactive-query teardown schedules a timer that `testWidgets`'
/// strict "no pending timers" check doesn't tolerate, independent of
/// this app's own code.
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._current);

  AppSettings _current;
  final StreamController<AppSettings> controller =
      StreamController<AppSettings>.broadcast();

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
    yield* controller.stream;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    _current = settings;
    controller.add(settings);
    return const Success(null);
  }
}

/// `PakoTvApp`'s own locale wiring — CLAUDE.md rule 9 applied to the
/// root: only this one widget subscribes to `SettingsRepository.watch`
/// for `MaterialApp.router`'s `locale`, `.distinct()`-ed over the
/// derived `Locale` itself (not the whole `AppSettings`), so a
/// region-only change is a no-op here.
void main() {
  late _FakeSettingsRepository settingsRepository;

  setUpAll(() => configureDependencies(fake.name));

  setUp(() {
    // Same swaps as router_test.dart's own setUp — the real drift-backed
    // UserLibraryRepository/OnboardingRepository need path_provider,
    // unavailable in flutter test's host environment.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      InMemoryOnboardingRepository.new,
    );

    settingsRepository = _FakeSettingsRepository(
      const AppSettings(languageCode: 'en', regionCode: 'US'),
    );
    getIt.unregister<SettingsRepository>();
    getIt.registerLazySingleton<SettingsRepository>(() => settingsRepository);
  });

  // `find.byType(MaterialApp)`'s own element sits *outside* the
  // Localizations widget MaterialApp itself inserts as a child — the
  // "PakoTV" wordmark (discover_screen_test.dart's own anchor) is a
  // reliable descendant actually inside it.
  Locale rootLocale(WidgetTester tester) =>
      Localizations.localeOf(tester.element(find.text('PakoTV')));

  testWidgets(
    "switching the stored language updates MaterialApp.router's own "
    'locale, with no restart',
    (tester) async {
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();
      expect(rootLocale(tester), const Locale('en'));

      await settingsRepository.save(
        const AppSettings(languageCode: 'es', regionCode: 'US'),
      );
      await tester.pumpAndSettle();

      expect(rootLocale(tester), const Locale('es'));
    },
  );

  testWidgets(
    'a region-only settings change leaves the resolved locale untouched',
    (tester) async {
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();
      expect(rootLocale(tester), const Locale('en'));

      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'MX'),
      );
      await tester.pumpAndSettle();

      expect(rootLocale(tester), const Locale('en'));
    },
  );
}
