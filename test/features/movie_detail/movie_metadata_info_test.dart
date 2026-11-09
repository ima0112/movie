import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/movie_detail/presentation/widgets/movie_metadata.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/l10n/locale_names.dart';

MovieDetail _detail({
  String? language,
  List<String> countries = const [],
  int? runtime,
  String? certification,
  DateTime? release,
  List<CrewMember> crew = const [],
}) => MovieDetail(
  item: Movie(
    id: 1,
    title: 'T',
    posterUrl: null,
    genres: const [],
    releaseDate: release,
    voteAverage: 8,
  ),
  overview: '',
  cast: const [],
  crew: crew,
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: 'Released',
  watchProviders: WatchProviders.empty,
  originalLanguage: language,
  countryCodes: countries,
  runtimeMinutes: runtime,
  releaseDate: release,
  certification: certification,
);

Future<String> _prefix(
  WidgetTester tester,
  MovieDetail detail,
  String lang,
) async {
  late String result;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(lang),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        LocaleNamesLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          result = movieMetaPrefix(context, detail);
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('movieMetaPrefix is "year · country name" in the app language', (
    tester,
  ) async {
    final detail = _detail(
      countries: ['US', 'GB'],
      release: DateTime(2010, 7, 16),
    );
    expect(await _prefix(tester, detail, 'en'), '2010 · United States');
    expect(await _prefix(tester, detail, 'es'), '2010 · Estados Unidos');
    expect(
      await _prefix(tester, _detail(release: DateTime(2010)), 'en'),
      '2010',
    );
  });

  testWidgets('languageDisplayName uses the app language, then the code', (
    tester,
  ) async {
    late String en;
    late String es;
    late String unknown;
    for (final lang in ['en', 'es']) {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            LocaleNamesLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              if (lang == 'en') {
                en = languageDisplayName(context, 'fr');
              } else {
                es = languageDisplayName(context, 'en');
                unknown = languageDisplayName(context, 'zz');
              }
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(en, 'French');
    expect(es, 'Inglés');
    expect(unknown, 'ZZ');
  });

  test('territoryFromLocaleName reads the last parenthesised part', () {
    expect(territoryFromLocaleName('English (United States)'), 'United States');
    expect(territoryFromLocaleName('Chinese (Simplified, China)'), 'China');
    expect(territoryFromLocaleName('English'), isNull);
  });

  test('movieDirectors: crew with job Director, each person once', () {
    const nolan = Person(
      id: 7,
      name: 'Christopher Nolan',
      profilePath: null,
      knownForDepartment: 'Directing',
    );
    const thomas = Person(
      id: 8,
      name: 'Emma Thomas',
      profilePath: null,
      knownForDepartment: 'Production',
    );
    final detail = _detail(
      crew: [
        const CrewMember(
          person: nolan,
          job: 'Director',
          department: 'Directing',
        ),
        const CrewMember(
          person: thomas,
          job: 'Producer',
          department: 'Production',
        ),
        const CrewMember(
          person: nolan,
          job: 'Director',
          department: 'Directing',
        ),
      ],
    );
    expect(movieDirectors(detail), [nolan]);
  });
}
