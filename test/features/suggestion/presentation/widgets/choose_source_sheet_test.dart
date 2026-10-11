import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
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
import 'package:movies/features/suggestion/presentation/widgets/choose_source_sheet.dart';
import 'package:movies/features/taste_profile/domain/taste_profile_builder.dart';
import 'package:movies/l10n/app_localizations.dart';

/// A [MatchEngine] that never actually resolves — these tests only
/// care about what happens the instant a button is tapped (which
/// cubit method ran, whether the sheet closed), never about the
/// search that follows.
class _NeverResolvingMatchEngine implements MatchEngine {
  @override
  Future<MatchResult?> resolve(
    MatchQuery query, {
    required MatchOptions options,
  }) => Completer<MatchResult?>().future;
}

class _FakeTasteProfileRepository implements TasteProfileRepository {
  _FakeTasteProfileRepository(this.profile);

  final TasteProfile? profile;

  @override
  Stream<TasteProfile?> watch() => Stream.value(profile);

  @override
  Future<Result<void>> save(TasteProfile profile) async => const Success(null);

  @override
  Future<Result<void>> delete() async => const Success(null);
}

class _FakeUserLibraryRepository implements UserLibraryRepository {
  final List<UserMediaEntry> entries = const [];

  @override
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type}) =>
      Stream.value(entries);

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) => Stream.value(null);

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async =>
      const Success(null);

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
  Future<Result<List<UserMediaEntry>>> all() async => Success(entries);
}

/// A real [SurpriseCubit], driven to a real [ChooseSource] state via
/// [SurpriseCubit.chooseType] — the same way E1 actually reaches it —
/// rather than a hand-rolled fake standing in for the whole state
/// machine.
Future<SurpriseCubit> _cubitAtChooseSource({TasteProfile? profile}) async {
  final cubit = SurpriseCubit(
    _NeverResolvingMatchEngine(),
    TasteProfileBuilder(VibeCatalog(const [])),
    _FakeTasteProfileRepository(profile),
    _FakeUserLibraryRepository(),
  );
  await cubit.chooseType(MediaType.movie);
  return cubit;
}

/// Wraps the sheet in a plain `Scaffold` body — enough to check its
/// own rendering (subtitle per source).
Widget _wrap(SurpriseCubit cubit, ChooseSource state) {
  return BlocProvider<SurpriseCubit>.value(
    value: cubit,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ChooseSourceSheet(state: state)),
    ),
  );
}

/// Opens the sheet the real way (`showModalBottomSheet`), so a tap
/// test can confirm it actually closes, not just that the right cubit
/// method ran.
Widget _wrapAsModalSheet(SurpriseCubit cubit, ChooseSource state) {
  return BlocProvider<SurpriseCubit>.value(
    value: cubit,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ChooseSourceSheet(state: state),
              ),
              child: const Text('Open H11'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ChooseSourceSheet', () {
    testWidgets('shows the profile subtitle when source is profile', (
      tester,
    ) async {
      final cubit = await _cubitAtChooseSource(
        profile: TasteProfile(
          likedGenres: {const Genre(id: 'drama')},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 2000,
          updatedAt: DateTime(2024),
        ),
      );
      addTearDown(cubit.close);
      final state = cubit.state as ChooseSource;
      expect(state.source, SuggestionSource.profile);

      await tester.pumpWidget(_wrap(cubit, state));

      expect(find.text('Based on your tastes'), findsOneWidget);
      expect(find.text('Use my tastes'), findsOneWidget);
      expect(find.text('Answer the quiz instead'), findsOneWidget);
    });

    testWidgets('shows the inferred-list subtitle when source is '
        'inferredList', (tester) async {
      final cubit = await _cubitAtChooseSource(); // no profile at all
      addTearDown(cubit.close);
      final state = const ChooseSource(
        MediaType.movie,
        SuggestionSource.inferredList,
      );

      await tester.pumpWidget(_wrap(cubit, state));

      expect(find.text('Based on your list'), findsOneWidget);
    });

    testWidgets('tapping "Use my tastes" calls useMyTastes() and closes '
        'the sheet', (tester) async {
      final cubit = await _cubitAtChooseSource(
        profile: TasteProfile(
          likedGenres: {const Genre(id: 'drama')},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 2000,
          updatedAt: DateTime(2024),
        ),
      );
      addTearDown(cubit.close);
      final state = cubit.state as ChooseSource;

      await tester.pumpWidget(_wrapAsModalSheet(cubit, state));
      await tester.tap(find.text('Open H11'));
      await tester.pumpAndSettle();
      expect(find.text('Use my tastes'), findsOneWidget);

      await tester.tap(find.text('Use my tastes'));
      await tester.pumpAndSettle();

      expect(cubit.state, isA<Searching>());
      expect(find.text('Use my tastes'), findsNothing); // sheet closed

      // _NeverResolvingMatchEngine never completes — drain the
      // search's own 8s timeout so its Timer doesn't outlive this
      // test (flutter_test fails on any pending Timer at teardown).
      await tester.pump(SurpriseCubit.maxSearchingDuration);
      expect(cubit.state, isA<SurpriseError>());
    });

    testWidgets('tapping "Answer the quiz instead" calls '
        'answerQuizInstead() with the same mediaType', (tester) async {
      final cubit = await _cubitAtChooseSource(
        profile: TasteProfile(
          likedGenres: {const Genre(id: 'drama')},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 2000,
          updatedAt: DateTime(2024),
        ),
      );
      addTearDown(cubit.close);
      final state = cubit.state as ChooseSource;

      await tester.pumpWidget(_wrapAsModalSheet(cubit, state));
      await tester.tap(find.text('Open H11'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Answer the quiz instead'));
      await tester.pumpAndSettle();

      expect(cubit.state, isA<NeedsQuiz>());
      expect((cubit.state as NeedsQuiz).mediaType, MediaType.movie);
      expect(find.text('Answer the quiz instead'), findsNothing);
    });
  });
}
