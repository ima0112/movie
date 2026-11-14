import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/explore/presentation/cubit/explore_browse_cubit.dart';
import 'package:movies/features/explore/presentation/widgets/explore_genre_pills.dart';
import 'package:movies/features/explore/presentation/widgets/explore_platform_pills.dart';
import 'package:movies/l10n/app_localizations.dart';

const _netflix = StreamingService(id: 8, name: 'Netflix');
const _max = StreamingService(id: 1899, name: 'Max');
const _prime = StreamingService(id: 9, name: 'Prime Video');

class _Repo extends FakeMediaRepository {
  @override
  Future<Result<List<StreamingService>>> streamingServices({type}) async =>
      const Success([_netflix, _max, _prime]);
}

class _Settings implements SettingsRepository {
  final _current = const AppSettings(languageCode: 'en', regionCode: 'US');

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async => const Success(null);
}

Future<TasteProfileCubit> _pump(
  WidgetTester tester, {
  TasteProfile? profile,
}) async {
  final taste = InMemoryTasteProfileRepository();
  if (profile != null) await taste.save(profile);
  final tasteCubit = TasteProfileCubit(taste);
  final browse = ExploreBrowseCubit(_Repo(), _Settings());
  addTearDown(() async {
    await browse.close();
    await tasteCubit.close();
  });
  await browse.start(MediaSegment.all);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: browse),
          BlocProvider.value(value: tasteCubit),
        ],
        child: const Scaffold(
          body: Column(children: [ExploreGenrePills(), ExplorePlatformPills()]),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tasteCubit;
}

/// Left edges of [labels], in the order they are laid out.
List<String> _order(WidgetTester tester, List<String> labels) {
  final sorted = [...labels]
    ..sort(
      (a, b) => tester
          .getTopLeft(find.text(a))
          .dx
          .compareTo(tester.getTopLeft(find.text(b)).dx),
    );
  return sorted;
}

TasteProfile _profile({
  Set<Genre> genres = const {},
  Set<int> platforms = const {},
}) => TasteProfile(
  likedGenres: genres,
  vetoedGenres: const {},
  likedVibes: const {},
  yearFrom: 1990,
  platformIds: platforms,
  updatedAt: DateTime(2026),
);

void main() {
  testWidgets('no taste profile: the catalog\'s own order', (tester) async {
    await _pump(tester);

    expect(_order(tester, ['Action', 'Adventure', 'Animation']), [
      'Action',
      'Adventure',
      'Animation',
    ]);
    expect(_order(tester, ['Netflix', 'Max', 'Prime Video']), [
      'Netflix',
      'Max',
      'Prime Video',
    ]);
  });

  testWidgets('the liked genres and the user\'s platforms come first, the '
      'rest keep their order', (tester) async {
    await _pump(
      tester,
      profile: _profile(
        genres: {
          const Genre(id: 'horror'),
          const Genre(id: 'drama'),
        },
        platforms: {9},
      ),
    );

    // Drama and Horror ahead of Action, in catalog order between them.
    expect(_order(tester, ['Action', 'Drama', 'Horror']), [
      'Drama',
      'Horror',
      'Action',
    ]);
    // Prime Video (id 9) ahead of Netflix and Max.
    expect(_order(tester, ['Netflix', 'Max', 'Prime Video']), [
      'Prime Video',
      'Netflix',
      'Max',
    ]);
  });

  testWidgets('changing tastes reorders the pills live', (tester) async {
    final taste = await _pump(tester);

    await taste.save(_profile(platforms: {1899}));
    await tester.pumpAndSettle();

    expect(_order(tester, ['Netflix', 'Max']).first, 'Max');
  });
}
