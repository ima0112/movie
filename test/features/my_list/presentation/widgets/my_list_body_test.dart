import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/my_list/presentation/cubit/my_list_cubit.dart';
import 'package:movies/features/my_list/presentation/widgets/my_list_body.dart';
import 'package:movies/l10n/app_localizations.dart';

/// `_sort`'s own 3 real cases — H9's Title A-Z / Year / TMDB rating —
/// exercised through the rendered row order, since `MyListBody._sort`
/// is private. All three entries are Favorites (`isFavorite: true`) so
/// none of this depends on My List's filter/tab logic, only its sort.
const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _bear = MediaKey(type: MediaType.tvShow, tmdbId: 101);
const _boys = MediaKey(type: MediaType.tvShow, tmdbId: 106);

Future<void> _pump(
  WidgetTester tester,
  InMemoryUserLibraryRepository repository,
  MyListSort sort,
) {
  final cubit = MyListCubit()..selectSort(sort);
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<MyListCubit>.value(
        value: cubit,
        child: Scaffold(
          body: MyListBody(userLibraryRepository: repository),
        ),
      ),
    ),
  );
}

const _knownTitles = {'zeta', 'Alpha', 'Beta'};

List<String> _renderedTitles(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .where(_knownTitles.contains)
    .toList();

void main() {
  group('MyListBody sorting', () {
    testWidgets('Title A-Z sorts case-insensitively by title', (
      tester,
    ) async {
      final repository = InMemoryUserLibraryRepository();
      // "zeta" lowercase on purpose — sorting is case-insensitive, so
      // it must still land last, not first (a plain string compare
      // would put it before every uppercase title).
      await repository.upsert(
        const UserMediaEntry(key: _dune, title: 'zeta', isFavorite: true),
      );
      await repository.upsert(
        const UserMediaEntry(key: _bear, title: 'Alpha', isFavorite: true),
      );
      await repository.upsert(
        const UserMediaEntry(key: _boys, title: 'Beta', isFavorite: true),
      );

      await _pump(tester, repository, MyListSort.titleAZ);
      await tester.pumpAndSettle();

      expect(_renderedTitles(tester), ['Alpha', 'Beta', 'zeta']);
    });

    testWidgets('Year sorts most recent first, with no-year entries last, '
        'tied years broken by title', (tester) async {
      final repository = InMemoryUserLibraryRepository();
      // Alpha and Beta share a year on purpose, to exercise the
      // stable-by-title tiebreak rather than relying on List.sort's own
      // (unspecified) stability.
      await repository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Beta',
          isFavorite: true,
          year: 2020,
        ),
      );
      await repository.upsert(
        const UserMediaEntry(key: _bear, title: 'zeta', isFavorite: true),
      );
      await repository.upsert(
        const UserMediaEntry(
          key: _boys,
          title: 'Alpha',
          isFavorite: true,
          year: 2020,
        ),
      );

      await _pump(tester, repository, MyListSort.year);
      await tester.pumpAndSettle();

      // Both 2020 (Alpha before Beta, alphabetically), then the entry
      // with no year at all goes last regardless of its own title.
      expect(_renderedTitles(tester), ['Alpha', 'Beta', 'zeta']);
    });

    testWidgets('TMDB rating sorts highest first, with no-rating entries '
        'last', (tester) async {
      final repository = InMemoryUserLibraryRepository();
      await repository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Alpha',
          isFavorite: true,
          voteAverage: 9.0,
        ),
      );
      await repository.upsert(
        const UserMediaEntry(key: _bear, title: 'zeta', isFavorite: true),
      );
      await repository.upsert(
        const UserMediaEntry(
          key: _boys,
          title: 'Beta',
          isFavorite: true,
          voteAverage: 7.0,
        ),
      );

      await _pump(tester, repository, MyListSort.tmdbRating);
      await tester.pumpAndSettle();

      expect(_renderedTitles(tester), ['Alpha', 'Beta', 'zeta']);
    });
  });
}
