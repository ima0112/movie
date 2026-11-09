import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/match_engine/domain/match_engine.dart';
import 'package:movies/features/match_engine/domain/match_query.dart';
import 'package:movies/features/match_engine/domain/match_result.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_cubit.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/suggestion/presentation/widgets/surprise_result_content.dart';
import 'package:movies/features/taste_profile/domain/taste_profile_builder.dart';
import 'package:movies/l10n/app_localizations.dart';

class _NoopMatchEngine implements MatchEngine {
  @override
  Future<MatchResult?> resolve(
    MatchQuery query, {
    required MatchOptions options,
  }) async => null;
}

class _FakeTasteProfileRepository implements TasteProfileRepository {
  @override
  Stream<TasteProfile?> watch() => const Stream.empty();

  @override
  Future<Result<void>> save(TasteProfile profile) async => const Success(null);

  @override
  Future<Result<void>> delete() async => const Success(null);
}

class _FakeUserLibraryRepository implements UserLibraryRepository {
  final List<UserMediaEntry> upserted = [];

  @override
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type}) =>
      Stream.value(const []);

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) => Stream.value(null);

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async {
    upserted.add(entry);
    return const Success(null);
  }

  @override
  Future<Result<void>> updateCatalogSnapshot(
    MediaKey key, {
    required String title,
    required List<Genre> genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  }) async => const Success(null);

  @override
  Future<Result<void>> remove(MediaKey key) async => const Success(null);

  @override
  Future<Result<void>> clearAll() async => const Success(null);

  @override
  Future<Result<List<MediaKey>>> watchedKeys(
    MediaType type, {
    int limit = 500,
  }) async => const Success([]);

  @override
  Future<Result<List<UserMediaEntry>>> all() async => const Success([]);
}

final _movie = Movie(
  id: 1,
  title: 'Dune: Part Two',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2024),
  voteAverage: 8.4,
);

SurpriseResult _resultState(SuggestionSource source) {
  return SurpriseResult(
    candidates: [_movie],
    index: 0,
    relaxationsApplied: const [],
    source: source,
  );
}

/// A real go_router with exactly the two routes this link's navigation
/// touches — `/surprise/result` (this widget) and `/surprise/quiz` (a
/// marker screen standing in for the real `SurpriseQuizScreen`, so
/// this test only has to prove *this* widget's own navigation call,
/// not re-walk the whole 4-step quiz). `SurpriseQuizScreen` itself is
/// unchanged by this branch — its own `pushReplacement` back to a
/// fresh E3 is already established, pre-existing behavior.
Widget _wrap(SurpriseCubit cubit, SurpriseResult state) {
  final router = GoRouter(
    initialLocation: AppRoutes.surpriseResult,
    routes: [
      GoRoute(
        path: AppRoutes.surpriseResult,
        builder: (context, routerState) => BlocProvider<SurpriseCubit>.value(
          value: cubit,
          child: Scaffold(body: SurpriseResultContent(state: state)),
        ),
      ),
      GoRoute(
        path: AppRoutes.surpriseQuiz,
        builder: (context, routerState) =>
            const Scaffold(body: Center(child: Text('E2 quiz placeholder'))),
      ),
    ],
  );

  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  group('SurpriseResultContent — source subtitle', () {
    testWidgets('profile source shows "Based on your tastes"', (tester) async {
      final cubit = SurpriseCubit(
        _NoopMatchEngine(),
        TasteProfileBuilder(VibeCatalog(const [])),
        _FakeTasteProfileRepository(),
        _FakeUserLibraryRepository(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(cubit, _resultState(SuggestionSource.profile)),
      );

      expect(find.text('Based on your tastes'), findsOneWidget);
    });

    testWidgets('quiz source now shows its own subtitle too, not '
        'nothing', (tester) async {
      final cubit = SurpriseCubit(
        _NoopMatchEngine(),
        TasteProfileBuilder(VibeCatalog(const [])),
        _FakeTasteProfileRepository(),
        _FakeUserLibraryRepository(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(cubit, _resultState(SuggestionSource.quiz)),
      );

      expect(find.text('Based on your answers'), findsOneWidget);
    });
  });

  group('SurpriseResultContent — "Answer the quiz instead" link', () {
    testWidgets('shown for profile/inferredList, opens E2 via '
        'pushReplacement when tapped', (tester) async {
      final cubit = SurpriseCubit(
        _NoopMatchEngine(),
        TasteProfileBuilder(VibeCatalog(const [])),
        _FakeTasteProfileRepository(),
        _FakeUserLibraryRepository(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(cubit, _resultState(SuggestionSource.profile)),
      );
      expect(find.text('Answer the quiz instead'), findsOneWidget);

      await tester.ensureVisible(find.text('Answer the quiz instead'));
      await tester.tap(find.text('Answer the quiz instead'));
      await tester.pumpAndSettle();

      // pushReplacement, not push — E3 is gone, not just covered, so
      // the back gesture from whatever follows lands past it.
      expect(find.text('E2 quiz placeholder'), findsOneWidget);
      expect(find.byType(SurpriseResultContent), findsNothing);
    });

    testWidgets('not shown for quiz — nothing left to offer', (tester) async {
      final cubit = SurpriseCubit(
        _NoopMatchEngine(),
        TasteProfileBuilder(VibeCatalog(const [])),
        _FakeTasteProfileRepository(),
        _FakeUserLibraryRepository(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(cubit, _resultState(SuggestionSource.quiz)),
      );

      expect(find.text('Answer the quiz instead'), findsNothing);
    });
  });

  group('SurpriseResultContent — "Add to watch later"', () {
    testWidgets('persists voteAverage and year from the suggested item, '
        'not just title/genres', (tester) async {
      // "Add to watch later" reaches for the global `getIt` directly
      // (surprise_result_content.dart's own `_addToWatchLater`) rather
      // than a repository passed in by this widget's constructor —
      // unlike every other write site in this branch, so the fake has
      // to go through `getIt` too, not just `SurpriseCubit`'s own.
      final userLibraryRepository = _FakeUserLibraryRepository();
      getIt.registerSingleton<UserLibraryRepository>(userLibraryRepository);
      addTearDown(() => getIt.unregister<UserLibraryRepository>());
      final cubit = SurpriseCubit(
        _NoopMatchEngine(),
        TasteProfileBuilder(VibeCatalog(const [])),
        _FakeTasteProfileRepository(),
        userLibraryRepository,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(cubit, _resultState(SuggestionSource.profile)),
      );
      await tester.ensureVisible(find.text('Add to Watch later'));
      await tester.tap(find.text('Add to Watch later'));
      await tester.pumpAndSettle();

      final saved = userLibraryRepository.upserted.single;
      expect(saved.title, 'Dune: Part Two');
      expect(saved.voteAverage, 8.4);
      expect(saved.year, 2024);
    });
  });
}
