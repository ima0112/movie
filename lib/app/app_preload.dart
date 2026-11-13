import '../core/domain/repositories/media_repository.dart';
import '../core/domain/repositories/onboarding_repository.dart';
import '../core/domain/repositories/settings_repository.dart';
import 'di.dart';

/// A1's preload (`docs/SCREENS.md`: "while theme, language, `/configuration`,
/// and `/trending/all/week` load"), started by `main()` **before the first
/// Flutter frame**, so it runs while the system still shows its (blank, dark)
/// native splash and overlaps the engine's own start-up instead of waiting for
/// the in-app splash to mount.
///
/// Theme is already synchronous (`AppTheme.dark`), so three real waits remain:
/// [OnboardingRepository] and [SettingsRepository] (both needed before
/// `PakoTvApp`'s router redirect, or any TMDB request, reads them) and one
/// [MediaRepository] call, which also warms `/configuration` as a side effect
/// (`TmdbMediaRepository`'s own `_imagesConfig` getter calls
/// `TmdbConfigurationService.load()` on every access, so there is no need to
/// reach that `@real`-only service directly — doing so would crash the `fake`
/// environment).
///
/// Never throws: it is only a head start. If something fails the app still
/// opens and each screen loads (and reports) its own data; an error escaping
/// here would otherwise leave the splash waiting forever.
Future<void> preloadApp() async {
  try {
    await Future.wait([
      getIt<OnboardingRepository>().load(),
      getIt<SettingsRepository>().load(),
      getIt<MediaRepository>().getCarouselSection(
        CarouselSection.popularThisWeek,
      ),
    ]);
  } catch (_) {
    // See above: a failed head start isn't a failed launch.
  }
}
