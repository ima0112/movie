import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_card_back.dart';
import 'package:movies/l10n/app_localizations.dart';

const _tom = Person(id: 1, name: 'Tom', profilePath: null);
const _ana = Person(id: 2, name: 'Ana', profilePath: null);

List<CastMember> _cast(int n) => [
  for (var i = 0; i < n; i++)
    CastMember(
      person: Person(id: 10 + i, name: 'Actor $i', profilePath: null),
      character: 'Role $i',
      order: i,
    ),
];

SurpriseSuggestion _movie({
  String overview = 'A long road home.',
  int cast = 5,
  List<Person> directors = const [_tom, _ana],
  List<Genre> genres = const [Genre(id: 'sci-fi'), Genre(id: 'drama')],
}) {
  final item = Movie(
    id: 1,
    title: 'Dune',
    posterUrl: null,
    genres: genres,
    releaseDate: DateTime(2024),
    voteAverage: 8.2,
    voteCount: 10,
  );
  return SurpriseSuggestion(
    detail: MovieDetail(
      item: item,
      overview: overview,
      cast: _cast(cast),
      crew: [
        for (final d in directors)
          CrewMember(person: d, job: 'Director', department: 'Directing'),
        const CrewMember(person: _tom, job: 'Writer', department: 'Writing'),
      ],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: null,
      status: 'Released',
      watchProviders: WatchProviders.empty,
      runtimeMinutes: 120,
      releaseDate: item.releaseDate,
      certification: null,
    ),
    affinityPercent: 88,
  );
}

SurpriseSuggestion _show() {
  final item = TvShow(
    id: 2,
    title: 'Dark',
    posterUrl: null,
    genres: const [Genre(id: 'mystery')],
    releaseDate: DateTime(2017),
    voteAverage: 8.7,
    voteCount: 10,
  );
  return SurpriseSuggestion(
    detail: TvShowDetail(
      item: item,
      overview: 'A child vanishes.',
      cast: _cast(3),
      crew: const [],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: null,
      status: 'Ended',
      watchProviders: WatchProviders.empty,
      creators: const [_tom],
      seasons: const [],
      numberOfEpisodes: 26,
      episodeRuntimeMinutes: 50,
      firstAirDate: DateTime(2017),
      lastAirDate: DateTime(2020),
      inProduction: false,
      certification: null,
    ),
    affinityPercent: 90,
  );
}

Widget _host(
  SurpriseSuggestion s, {
  Locale locale = const Locale('en'),
  double textScale = 1,
  Size size = const Size(300, 460),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: SurpriseCardBack(
          suggestion: s,
          number: 3,
          topAction: const SizedBox(key: Key('action'), width: 44, height: 44),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('a film: title, genres, synopsis, "Directed by" and only the '
      'three leading actors', (tester) async {
    await tester.pumpWidget(_host(_movie()));

    expect(find.text('03'), findsWidgets);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('2024 · 2 h'), findsOneWidget);
    expect(find.text('8.2'), findsOneWidget);
    expect(find.text('Science Fiction'), findsOneWidget);
    expect(find.text('SYNOPSIS'), findsOneWidget);
    expect(find.text('A long road home.'), findsOneWidget);
    expect(find.text('Directed by '), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Cast'), findsOneWidget);
    expect(find.text('Actor 0'), findsOneWidget);
    expect(find.text('Role 2'), findsOneWidget);
    expect(find.text('Actor 3'), findsNothing);
    expect(find.byKey(const Key('action')), findsOneWidget);
  });

  testWidgets('a series says "Created by"', (tester) async {
    await tester.pumpWidget(_host(_show()));

    expect(find.text('Created by '), findsOneWidget);
    expect(find.text('Directed by '), findsNothing);
    expect(find.text('Tom'), findsOneWidget);
  });

  testWidgets('what the title lacks is left out; fewer actors keep their '
      'columns', (tester) async {
    await tester.pumpWidget(
      _host(
        _movie(overview: '', cast: 1, directors: const [], genres: const []),
      ),
    );

    expect(find.text('SYNOPSIS'), findsNothing);
    expect(find.textContaining('Directed'), findsNothing);
    expect(find.text('Cast'), findsOneWidget);
    expect(find.text('Actor 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('in Spanish', (tester) async {
    await tester.pumpWidget(_host(_show(), locale: const Locale('es')));

    expect(find.text('Creada por '), findsOneWidget);
    expect(find.text('SINOPSIS'), findsOneWidget);
    expect(find.text('Reparto'), findsOneWidget);
  });

  testWidgets('at 200 % text on a small card it scrolls, nothing overflows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(_movie(), textScale: 2, size: const Size(280, 400)),
    );

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    expect(find.text('Role 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the scrolling content fades out into the card at the top and '
      'bottom instead of running into the number', (tester) async {
    await tester.pumpWidget(_host(_movie()));

    final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    expect(mask.blendMode, BlendMode.dstIn);
    expect(
      find.descendant(
        of: find.byType(ShaderMask),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    // At rest the title is below the veiled zone: nothing is hidden.
    final titleTop = tester.getTopLeft(find.text('Dune')).dy;
    final cardTop = tester.getTopLeft(find.byType(SurpriseCardBack)).dy;
    expect(titleTop - cardTop, greaterThanOrEqualTo(128));
  });
}
