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
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_platform_tile.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_platforms_section.dart';
import 'package:movies/l10n/app_localizations.dart';

class _Services implements MediaRepository {
  _Services(this.outcome);

  Result<List<StreamingService>> outcome;
  int calls = 0;

  @override
  Future<Result<List<StreamingService>>> streamingServices({
    MediaType? type,
  }) async {
    calls++;
    return outcome;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _netflix = StreamingService(id: 8, name: 'Netflix');
const _max = StreamingService(id: 1899, name: 'Max');

void main() {
  setUpAll(() => configureDependencies(fake.name));

  Future<MyTastesCubit> pump(
    WidgetTester tester,
    _Services repo, {
    Locale? locale,
  }) async {
    getIt.unregister<MediaRepository>();
    getIt.registerSingleton<MediaRepository>(repo);
    final profile = TasteProfileCubit(InMemoryTasteProfileRepository());
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

  testWidgets('the region\'s services as logo tiles; tapping toggles them '
      'in the taste profile', (tester) async {
    final tastes = await pump(
      tester,
      _Services(const Success([_netflix, _max])),
    );

    expect(find.text('My platforms'), findsOneWidget);
    expect(find.byType(TastePlatformTile), findsNWidgets(2));
    expect(tastes.state.platformIds, isEmpty);

    await tester.tap(find.bySemanticsLabel('Netflix'));
    await tester.pump();
    expect(tastes.state.platformIds, {8});
    final tile = tester.widget<TastePlatformTile>(
      find.byType(TastePlatformTile).first,
    );
    expect(tile.selected, isTrue);

    await tester.tap(find.bySemanticsLabel('Netflix'));
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

  testWidgets('a failed load: a retry row that loads again', (tester) async {
    final repo = _Services(Failure(FailureReason.network));
    await pump(tester, repo);
    expect(find.text('Retry'), findsOneWidget);

    repo.outcome = const Success([_netflix]);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repo.calls, 2);
    expect(find.byType(TastePlatformTile), findsOneWidget);
  });

  testWidgets('Spanish heading', (tester) async {
    await pump(
      tester,
      _Services(const Success([_netflix])),
      locale: const Locale('es'),
    );

    expect(find.text('Mis plataformas'), findsOneWidget);
  });
}
