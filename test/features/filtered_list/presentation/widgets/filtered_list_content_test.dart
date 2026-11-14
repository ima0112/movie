import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_preset.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_cubit.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_state.dart';
import 'package:movies/features/filtered_list/presentation/widgets/filtered_list_content.dart';
import 'package:movies/features/filtered_list/presentation/widgets/filtered_list_filter_button.dart';
import 'package:movies/l10n/app_localizations.dart';

Future<FilteredListCubit> _pump(
  WidgetTester tester,
  DiscoverFilter filter,
) async {
  final cubit = FilteredListCubit(FakeMediaRepository(), filter);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          appBar: AppBar(actions: [FilteredListFilterButton(onPressed: () {})]),
          body: const FilteredListContent(),
        ),
      ),
    ),
  );
  await tester.runAsync(cubit.load);
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('chips for the platform (by name), genre and rating; the badge '
      'counts them; × drops one', (tester) async {
    final cubit = await _pump(
      tester,
      DiscoverFilter(
        type: MediaType.movie,
        withWatchProviders: const {8},
        withGenres: {const Genre(id: 'action')},
        minVoteAverage: 5,
      ),
    );

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('5.0+ rating'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // the badge

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    expect(cubit.state.filter.withWatchProviders, isEmpty);
    expect(find.text('Netflix'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('with no filter set there are no chips and no badge, and the '
      'count line shows the total with the sort', (tester) async {
    await _pump(tester, const DiscoverFilter(type: MediaType.movie));

    expect(find.text('1'), findsNothing);
    expect(find.textContaining(' results'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
  });

  testWidgets('the sort at the right opens the sheet; picking one re-sorts', (
    tester,
  ) async {
    final cubit = await _pump(
      tester,
      const DiscoverFilter(type: MediaType.movie),
    );

    await tester.tap(find.text('Popular'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Top rated'));
    await tester.pumpAndSettle();

    expect(cubit.state.filter.sortBy, DiscoverSortBy.rating);
    expect(find.text('Top rated'), findsOneWidget); // now the line's label
  });

  testWidgets('nothing matching: the message keeps the chips and "Clear '
      'filters" goes back to every title of the segment', (tester) async {
    final cubit = await _pump(
      tester,
      const DiscoverFilter(type: MediaType.movie, minVoteAverage: 9.9),
    );

    expect(cubit.state, isA<FilteredListLoaded>());
    expect(find.text('Nothing with those filters'), findsOneWidget);
    expect(find.text('9.9+ rating'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(cubit.state.filter, const DiscoverFilter(type: MediaType.movie));
    expect(find.text('Nothing with those filters'), findsNothing);
    expect(find.text('9.9+ rating'), findsNothing);
  });

  testWidgets('chips for the preset, the rating range and the original '
      'language; each × drops its own', (tester) async {
    final cubit = await _pump(
      tester,
      const DiscoverFilter(
        type: MediaType.tvShow,
        minVoteAverage: 4.5,
        maxVoteAverage: 8,
        originalLanguage: 'ko',
      ).withPreset(DiscoverPreset.finished),
    );

    expect(find.text('Finished'), findsOneWidget);
    expect(find.text('Rating 4.5–8.0'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // the badge

    await tester.tap(find.text('Finished'));
    await tester.pumpAndSettle();
    expect(cubit.state.filter.preset, isNull);
    expect(cubit.state.filter.tvStatus, isNull);

    await tester.tap(find.text('Rating 4.5–8.0'));
    await tester.pumpAndSettle();
    expect(cubit.state.filter.hasRatingRange, isFalse);
  });
}
