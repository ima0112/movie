import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';

/// Guards against a real regression found while working on
/// add-runtime-tracking-to-library-entries: `UserProfileRepository` and
/// `TasteProfileRepository` were both `@LazySingleton(as: ...)`-annotated
/// (`global-profile-cubits`) but `di.config.dart` never actually
/// generated their registrations — `dart run build_runner build` hadn't
/// been re-run since those annotations were added. `app/app.dart`'s
/// `MultiBlocProvider` already called `getIt<UserProfileRepository>()` /
/// `getIt<TasteProfileRepository>()` in each Cubit's `create`, so this
/// would have thrown the moment anything actually read either Cubit —
/// but `BlocProvider.create` is lazy by default, and nothing in the
/// screens wired into the router today does, so `test/widget_test.dart`'s
/// full app boot never exercised the broken path and stayed green.
///
/// Checks `isRegistered`, not an actual `getIt<T>()` resolve: doing that
/// would construct the real `AppDatabase` (a genuine on-disk sqlite3
/// connection with its own background isolate/timer), which is exactly
/// what `test/widget_test.dart` already exercises end-to-end — this test
/// only needs to catch "the annotation exists but the registration
/// wasn't generated", which `isRegistered` does without any of that.
void main() {
  setUpAll(() => configureDependencies(fake.name));

  test('every repository app/app.dart resolves via getIt is registered', () {
    expect(getIt.isRegistered<UserLibraryRepository>(), isTrue);
    expect(getIt.isRegistered<UserProfileRepository>(), isTrue);
    expect(getIt.isRegistered<TasteProfileRepository>(), isTrue);
    expect(getIt.isRegistered<SettingsRepository>(), isTrue);
  });
}
