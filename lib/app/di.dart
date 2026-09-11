import 'package:get_it/get_it.dart';

import '../core/domain/repositories/media_repository.dart';
import '../features/discover/data/fake_media_repository.dart';

/// The app's single `GetIt` instance.
///
/// Source of truth: `docs/STRUCTURE.md` ("DI | `get_it` | Repositories and
/// services registered as lazy singletons in `app/di.dart`; Cubits are
/// created per-screen (not singletons) and pull their dependencies from
/// `GetIt.I`."). Screens pull dependencies via `getIt<T>()` (or
/// `GetIt.I<T>()`) — Cubits/Blocs themselves are never registered here.
final getIt = GetIt.instance;

/// Registers every repository/service as a lazy singleton. Call once,
/// before `runApp`.
void setupDependencies() {
  // TODO: swap for the real `MediaRepositoryImpl` (TMDB) once it exists —
  // see docs/STRUCTURE.md.
  getIt.registerLazySingleton<MediaRepository>(() => FakeMediaRepository());
}
