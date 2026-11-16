import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_platform_tile.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_platforms_sheet.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_platforms_section.dart';
import 'package:movies/l10n/app_localizations.dart';

class _Services implements MediaRepository {
  _Services(this.outcome);

  Result<List<StreamingService>> outcome;
  int calls = 0;
  bool? lastAll;

  @override
  Future<Result<List<StreamingService>>> streamingServices({
    MediaType? type,
    bool all = false,
  }) async {
    calls++;
    lastAll = all;
    return outcome;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _netflix = StreamingService(id: 8, name: 'Netflix');
const _max = StreamingService(id: 1899, name: 'Max');
const _prime = StreamingService(id: 9, name: 'Prime Video');

void main() {
  setUpAll(() => configureDependencies(fake.name));

  Future<MyTastesCubit> pump(
    WidgetTester tester,
    _Services repo, {
    Locale? locale,
    Set<int> picked = const {},
  }) async {
    getIt.unregister<MediaRepository>();
    getIt.registerSingleton<MediaRepository>(repo);
    final profileRepo = InMemoryTasteProfileRepository();
    if (picked.isNotEmpty) {
      await profileRepo.save(
        TasteProfile(
          likedGenres: const {},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 1990,
          platformIds: picked,
          updatedAt: DateTime(2026),
        ),
      );
    }
    final profile = TasteProfileCubit(profileRepo);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    final tastes = MyTastesCubit(
      profile,
      VibeCatalog.fromJson(const {'vibes': []}),
    );
    addTearDown(() async {
      await tastes.close();
      await profile.close();
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: tastes,
          child: const Scaffold(
            body: SingleChildScrollView(child: TastePlatformsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tastes;
  }

  testWidgets('nothing picked: just the "Add" chip; the picked ones are '
      'logos you can tap off', (tester) async {
    final tastes = await pump(
      tester,
      _Services(const Success([_netflix, _max])),
      picked: {8},
    );

    expect(find.text('My platforms'), findsOneWidget);
    expect(find.byType(TastePlatformTile), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Remove Netflix'));
    await tester.pump();
    expect(tastes.state.platformIds, isEmpty);
    await tester.pump();
    expect(find.byType(TastePlatformTile), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('"Add" opens a sheet with every service (not the capped '
      'list); picking adds it to the page as a logo', (tester) async {
    final repo = _Services(const Success([_netflix, _max, _prime]));
    final tastes = await pump(tester, repo);
    expect(find.byType(TastePlatformTile), findsNothing);
    expect(repo.lastAll, isTrue);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add platforms'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Prime Video'), findsOneWidget);

    await tester.tap(find.text('Netflix'));
    await tester.pump();
    await tester.tap(find.text('Prime Video'));
    await tester.pump();
    expect(tastes.state.platformIds, {8, 9});

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Add platforms'), findsNothing);
    expect(find.byType(TastePlatformTile), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('the sheet\'s search narrows the list; picked rows show a '
      'check and tapping again deselects', (tester) async {
    final tastes = await pump(
      tester,
      _Services(const Success([_netflix, _max, _prime])),
      picked: {1899},
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'prime');
    await tester.pump();
    expect(find.text('Prime Video'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No matches'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    // Max is already picked: it has the check, and a tap deselects it.
    expect(find.byIcon(AppIcons.check), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(TastePlatformsSheet),
        matching: find.text('Max'),
      ),
    );
    await tester.pump();
    expect(tastes.state.platformIds, isEmpty);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a region with no services: nothing, not even the heading', (
    tester,
  ) async {
    await pump(tester, _Services(const Success([])));

    expect(find.text('My platforms'), findsNothing);
  });

  testWidgets('a failed load: the sheet says so and Retry loads again', (
    tester,
  ) async {
    final repo = _Services(Failure(FailureReason.network));
    await pump(tester, repo);
    // The section still offers "Add"; the failure shows in the sheet.
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    repo.outcome = const Success([_netflix]);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repo.calls, 2);
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('Spanish copy', (tester) async {
    await pump(
      tester,
      _Services(const Success([_netflix])),
      locale: const Locale('es'),
    );

    expect(find.text('Mis plataformas'), findsOneWidget);
    await tester.tap(find.text('Añadir'));
    await tester.pumpAndSettle();
    expect(find.text('Añadir plataformas'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
  });
}
