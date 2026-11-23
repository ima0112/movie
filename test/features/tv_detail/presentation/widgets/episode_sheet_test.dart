import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_sheet.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_sheet_header.dart';
import 'package:movies/l10n/app_localizations.dart';

final _episode = Episode(
  episodeNumber: 4,
  name: 'Hands',
  overview:
      'Carmy tries to keep the kitchen together while a long night '
      'tests everyone on the line.',
  stillPath: null,
  airDate: DateTime(2022, 6, 23),
  runtimeMinutes: 32,
);

Widget _wrap(
  Widget child, {
  Locale? locale,
  Size size = const Size(390, 844),
  double textScale = 1,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: child),
    ),
  );
}

/// A phone-sized screen: on the default 800x600 test surface the 16:9 still is
/// ~450 px tall and pushes the chips below the fold (so they are never built).
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows the S1 · E4 pill, name, one meta line and the full '
      'synopsis', (tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(
      _wrap(EpisodeSheet(seasonNumber: 1, episode: _episode)),
    );

    expect(find.text('S1 · E4'), findsOneWidget);
    expect(find.text('Hands'), findsOneWidget);
    // One plain line, no chips.
    expect(find.textContaining('23 Jun, 2022 · 32 min'), findsOneWidget);
    final overview = tester.widget<Text>(find.textContaining('Carmy'));
    expect(overview.maxLines, isNull);
  });

  testWidgets('season 0 is captioned "Specials · E4"', (tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(
      _wrap(EpisodeSheet(seasonNumber: 0, episode: _episode)),
    );

    expect(find.text('Specials · E4'), findsOneWidget);
  });

  testWidgets('an unaired date-less episode shows TBA and no runtime', (
    tester,
  ) async {
    _usePhoneScreen(tester);
    final tba = Episode(
      episodeNumber: 5,
      name: 'Tbd',
      overview: '',
      stillPath: null,
      airDate: null,
      runtimeMinutes: null,
    );
    await tester.pumpWidget(_wrap(EpisodeSheet(seasonNumber: 2, episode: tba)));

    expect(find.text('TBA'), findsOneWidget);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('shows the rating and the guest stars, and tapping a guest '
      'calls onPersonTap', (tester) async {
    _usePhoneScreen(tester);
    Person? tapped;
    final rated = Episode(
      episodeNumber: 4,
      name: 'Hands',
      overview: 'Short.',
      stillPath: null,
      airDate: DateTime(2022, 6, 23),
      runtimeMinutes: 32,
      voteAverage: 8.5,
      guestStars: const [
        CastMember(
          person: Person(
            id: 11,
            name: 'Ana Soto',
            profilePath: null,
            knownForDepartment: null,
          ),
          character: 'Dr. Vega',
          order: 0,
        ),
      ],
    );
    await tester.pumpWidget(
      _wrap(
        EpisodeSheet(
          seasonNumber: 1,
          episode: rated,
          onPersonTap: (p) => tapped = p,
        ),
      ),
    );

    expect(find.textContaining('8.5'), findsOneWidget);
    expect(find.byIcon(AppIcons.starFill), findsOneWidget);
    expect(find.text('GUEST STARS'), findsOneWidget);
    expect(find.text('Dr. Vega'), findsOneWidget);

    await tester.tap(find.text('Ana Soto'));
    expect(tapped?.id, 11);
  });

  testWidgets('no rating and no guest-stars section when there is '
      'neither', (tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(
      _wrap(EpisodeSheet(seasonNumber: 1, episode: _episode)),
    );

    expect(find.text('GUEST STARS'), findsNothing);
    expect(find.byIcon(AppIcons.starFill), findsNothing);
  });

  testWidgets('survives a small device at 200% text scale (es)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        EpisodeSheet(seasonNumber: 1, episode: _episode),
        locale: const Locale('es'),
        size: const Size(320, 568),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('T1 · E4'), findsOneWidget);
  });

  testWidgets('the still is edge to edge with the code pill over it and the '
      'sheet\'s own handle', (tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(
      _wrap(EpisodeSheet(seasonNumber: 1, episode: _episode)),
    );

    final header = tester.getRect(find.byType(EpisodeSheetHeader));
    expect(header.width, 390); // no side margin
    expect(header.top, 0);
    final pill = tester.getRect(find.text('S1 · E4'));
    expect(header.contains(pill.center), isTrue);
    // The pill is at the lower left, and the title is under the still.
    expect(pill.left, lessThan(60));
    expect(
      tester.getRect(find.text('Hands')).top,
      greaterThanOrEqualTo(header.bottom),
    );
  });

  testWidgets('a really small phone at 200% text: no overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _wrap(
        EpisodeSheet(seasonNumber: 1, episode: _episode),
        locale: const Locale('es'),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
