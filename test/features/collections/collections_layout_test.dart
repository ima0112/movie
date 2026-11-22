import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_collections_section.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_collection_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/explore_filter_sheet.dart';

/// CLAUDE.md rule 14 for what the collections added: a small phone (320×568),
/// 200% text and a long language (Spanish) — nothing overflows, everything is
/// reachable by scrolling. (The notch and the keyboard are the device's job.)
final _catalog = CollectionCatalog.fromJsonString(
  File('assets/collections.json').readAsStringSync(),
);

Widget _app(Widget home, {Locale locale = const Locale('es')}) => MaterialApp(
  theme: AppTheme.dark,
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: const TextScaler.linear(2)),
    child: child!,
  ),
  home: home,
);

void _smallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the quiz\'s collection step, every group, scrolls without '
      'overflow', (tester) async {
    _smallPhone(tester);
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: QuizCollectionStep(
              collectionCatalog: _catalog,
              mediaType: MediaType.tvShow,
              selected: const {'anime'},
              onToggle: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The last group is reachable.
    await tester.scrollUntilVisible(find.text('Para niños'), 200);
    expect(find.text('Para niños'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('My Tastes\' collections section wraps at 200% text', (
    tester,
  ) async {
    _smallPhone(tester);
    final profile = TasteProfileCubit(InMemoryTasteProfileRepository());
    final tastes = MyTastesCubit(
      profile,
      VibeCatalog.fromJson(const {'vibes': []}),
      _catalog,
    );
    addTearDown(() async {
      await tastes.close();
      await profile.close();
    });
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: BlocProvider.value(
            value: tastes,
            child: const SingleChildScrollView(
              child: TasteCollectionsSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Series latinoamericanas'), findsOneWidget);
    expect(find.text('Para niños'), findsNothing); // not offered here
  });

  testWidgets('the filters sheet with a collection, on a small phone at 200% '
      'text: the sheet scrolls and "See results" stays in reach', (
    tester,
  ) async {
    _smallPhone(tester);
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: ExploreFilterSheet(
            initialFilter: DiscoverFilter(
              type: MediaType.tvShow,
              collection: _catalog.byId('turkish_series'),
            ),
            mediaRepository: FakeMediaRepository(),
            regionName: 'España',
            onApply: (_) {},
            collectionCatalog: Future.value(_catalog),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Ver'), findsWidgets);
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final button = tester.getRect(find.textContaining('Ver').last);
    expect(button.bottom, lessThanOrEqualTo(size.height));
    await tester.pump(const Duration(seconds: 1));
  });
}
