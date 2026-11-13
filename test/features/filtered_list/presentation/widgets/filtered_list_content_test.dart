import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_preset.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/cubit/listing_providers_cubit.dart';
import 'package:movies/shared/widgets/scroll_edge_fade.dart';
import 'package:movies/shared/widgets/listing_platform_logo.dart';
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider(
            create: (_) => ListingProvidersCubit(FakeMediaRepository()),
          ),
        ],
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

  testWidgets('with no filter set there are no chips and no badge, and no '
      'count or sort row either', (tester) async {
    await _pump(tester, const DiscoverFilter(type: MediaType.movie));

    expect(find.text('1'), findsNothing);
    // The results are the grid itself: no "N results" line and no quick sort
    // (the order is chosen in the filters).
    expect(find.textContaining(' results'), findsNothing);
    expect(find.byIcon(AppIcons.chevronDown), findsNothing);
    expect(find.byType(ScrollEdgeFade), findsOneWidget);
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

  testWidgets('with no platform picked each poster asks for its platform logo '
      '(top-right); with one picked there are none', (tester) async {
    await _pump(tester, const DiscoverFilter(type: MediaType.movie));
    expect(find.byType(ListingPlatformLogo), findsWidgets);

    await _pump(
      tester,
      const DiscoverFilter(type: MediaType.movie, withWatchProviders: {8}),
    );
    expect(find.byType(ListingPlatformLogo), findsNothing);
  });
}
