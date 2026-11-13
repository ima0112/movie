import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_recently_viewed_repository.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/presentation/cubit/recently_viewed_cubit.dart';
import 'package:movies/features/discover/presentation/widgets/discover_recently_viewed_section.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_card.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: 7,
);

TvShow _show(int id) => TvShow(
  id: id,
  title: 'Show $id',
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: 7,
);

void main() {
  group('RecentlyViewedCubit', () {
    test('starts empty and follows the repository, newest first', () async {
      final repo = InMemoryRecentlyViewedRepository();
      final cubit = RecentlyViewedCubit(repo);
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isEmpty);

      await repo.record(_movie(1));
      await repo.record(_show(2));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.map((i) => i.id), [2, 1]);
    });

    test('shows what was already stored from the first frame on', () async {
      final repo = InMemoryRecentlyViewedRepository([_movie(7)]);
      final cubit = RecentlyViewedCubit(repo);
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.single.id, 7);
    });
  });

  group('DiscoverRecentlyViewedSection', () {
    Future<void> pump(
      WidgetTester tester,
      InMemoryRecentlyViewedRepository repo,
    ) async {
      final cubit = RecentlyViewedCubit(repo);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const DiscoverRecentlyViewedSection(),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('draws nothing until something has been viewed', (
      tester,
    ) async {
      await pump(tester, InMemoryRecentlyViewedRepository());

      expect(find.text('Recently viewed'), findsNothing);
      expect(find.byType(MediaCard), findsNothing);
    });

    testWidgets('a poster per title, newest first, the TV tag on shows only, '
        'and it grows as titles are opened', (tester) async {
      final repo = InMemoryRecentlyViewedRepository([_movie(1), _show(2)]);
      await pump(tester, repo);

      expect(find.text('Recently viewed'), findsOneWidget);
      expect(find.byType(MediaCard), findsNWidgets(2));
      expect(find.text('TV'), findsOneWidget);

      await repo.record(_movie(3));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MediaCard), findsNWidgets(3));
      // The new title leads the row.
      final lefts = [
        for (final card in tester.widgetList<MediaCard>(find.byType(MediaCard)))
          tester.getTopLeft(find.byWidget(card)).dx,
      ];
      expect(lefts, orderedEquals([...lefts]..sort()));
      expect(
        tester.widgetList<MediaCard>(find.byType(MediaCard)).first.title,
        'Movie 3',
      );
    });
  });
}
