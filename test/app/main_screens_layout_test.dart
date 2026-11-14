import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/app/cubits/connectivity_cubit.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/network/network_status.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/features/discover/presentation/screens/discover_screen.dart';
import 'package:movies/features/explore/domain/search_history_repository.dart';
import 'package:movies/features/explore/presentation/screens/explore_screen.dart';
import 'package:movies/features/my_list/presentation/screens/my_list_screen.dart';
import 'package:movies/features/you/presentation/screens/you_screen.dart';
import 'package:movies/l10n/app_localizations.dart';

/// In-memory stand-in for [SearchHistoryRepository] — same shape as
/// `explore_cubit_test.dart`'s own copy. Needed here because
/// [ExploreScreen] resolves it straight off `getIt` (rule 10's "no
/// Cubit takes a repository by constructor in a test-friendly way"
/// trade-off for a screen-local Cubit) rather than this test being
/// able to inject it directly — the real Drift-backed implementation
/// needs a native sqlite file `flutter test`'s host can't give it.
class _InMemorySearchHistoryRepository implements SearchHistoryRepository {
  List<String> _history = [];
  final _controller = StreamController<List<String>>.broadcast();

  @override
  Stream<List<String>> watch() async* {
    yield _history;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> record(String query) async {
    _history = [query, ..._history.where((q) => q != query)].take(10).toList();
    _controller.add(_history);
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String query) async {
    _history = _history.where((q) => q != query).toList();
    _controller.add(_history);
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    _history = [];
    _controller.add(_history);
    return const Success(null);
  }
}

/// CLAUDE.md rule 14's own screen checklist ("verify it... on a small
/// device..., with the keyboard open, and at 200% text scale"), turned
/// into an automated regression guard across the four tab roots (B1
/// Discover, B2 Explore, B4 My List, B5 You) — same reasoning as
/// `region_sheet_test.dart`'s own doc comment, just at screen scope
/// instead of one sheet. `es` on top of that: Spanish strings run
/// longer than their English source in several spots this migration
/// touched (e.g. "Delete My Tastes" → "Eliminar mis gustos"), so this
/// is also the regression guard for the l10n migration itself, not
/// just a general layout check.
void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // UserLibraryRepository/UserProfileRepository/TasteProfileRepository
    // are all real, Drift-backed singletons with no `fake` environment
    // split (CLAUDE.md rule 10's own repositories) — same native-sqlite
    // problem `onboarding_redirect_test.dart` already swaps around.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<UserProfileRepository>();
    getIt.registerLazySingleton<UserProfileRepository>(
      InMemoryUserProfileRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
    getIt.unregister<SearchHistoryRepository>();
    getIt.registerLazySingleton<SearchHistoryRepository>(
      _InMemorySearchHistoryRepository.new,
    );
  });

  /// A small device ("iPhone SE"-sized, same as `region_sheet_test.dart`),
  /// the keyboard open, Spanish, and text at 200% — all four worst-case
  /// conditions at once, since that's exactly when a layout actually
  /// breaks, not when only one of them is true.
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: BlocProvider(
        // The root tabs read the connection (the app provides it globally).
        create: (_) => ConnectivityCubit(NetworkStatus()),
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 667),
            padding: EdgeInsets.only(top: 20, bottom: 0),
            viewInsets: EdgeInsets.only(bottom: 300),
            textScaler: TextScaler.linear(2),
          ),
          child: child,
        ),
      ),
    );
  }

  testWidgets('Discover (B1) survives es + small device + open keyboard + 200% '
      'text scale with no RenderFlex overflow', (tester) async {
    await tester.pumpWidget(wrap(const DiscoverScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Explore (B2) survives es + small device + open keyboard + 200% '
      'text scale with no RenderFlex overflow', (tester) async {
    await tester.pumpWidget(wrap(const ExploreScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('My List (B4) survives es + small device + open keyboard + 200% '
      'text scale with no RenderFlex overflow', (tester) async {
    await tester.pumpWidget(wrap(const MyListScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('You (B5) survives es + small device + open keyboard + 200% text '
      'scale with no RenderFlex overflow', (tester) async {
    // UserProfileCubit/TasteProfileCubit are genuinely global (rule
    // 10) — provided once above MaterialApp.router in app/app.dart,
    // not by YouScreen itself. Mirrored here the same way, rather
    // than reaching into app.dart's widget tree.
    await tester.pumpWidget(
      wrap(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => UserProfileCubit(getIt<UserProfileRepository>()),
            ),
            BlocProvider(
              create: (_) => TasteProfileCubit(getIt<TasteProfileRepository>()),
            ),
          ],
          child: const YouScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
