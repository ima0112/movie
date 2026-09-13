import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

/// The app's single `GetIt` instance.
///
/// Source of truth: `docs/STRUCTURE.md` ("DI | `get_it` | Repositories and
/// services registered as lazy singletons in `app/di.dart`; Cubits are
/// created per-screen (not singletons) and pull their dependencies from
/// `GetIt.I`."). Screens pull dependencies via `getIt<T>()` (or
/// `GetIt.I<T>()`) — Cubits/Blocs themselves are never registered here.
final getIt = GetIt.instance;

/// Registers every `@injectable`/`@LazySingleton`-annotated class found
/// under `lib/`. Call once, before `runApp`. `di.config.dart` is
/// generated — run `dart run build_runner build
/// --delete-conflicting-outputs` after adding or changing an annotation.
@InjectableInit()
void configureDependencies() => getIt.init();
