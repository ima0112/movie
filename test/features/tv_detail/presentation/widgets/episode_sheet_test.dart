import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_nav_button.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_sheet.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_sheet_handle.dart';
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

  group('moving through the season', () {
    Episode ep(int n) => Episode(
      episodeNumber: n,
      name: 'Episode $n',
      overview: 'Synopsis $n.',
      stillPath: null,
      airDate: DateTime(2022, 6, n),
      runtimeMinutes: 30 + n,
    );
    final all = [ep(1), ep(2), ep(3)];

    // A new key each time: a fresh sheet, not the previous one updated.
    Future<void> open(WidgetTester tester, int at) => tester.pumpWidget(
      _wrap(
        EpisodeSheet(
          key: UniqueKey(),
          seasonNumber: 1,
          episode: all[at],
          episodes: all,
        ),
      ),
    );

    testWidgets('the foot says Previous · E1 and Next · E3 around E2', (
      tester,
    ) async {
      _usePhoneScreen(tester);
      await open(tester, 1);

      expect(find.text('Previous · E1'), findsOneWidget);
      expect(find.text('Next · E3'), findsOneWidget);
      expect(find.text('Episode 2'), findsOneWidget);
    });

    testWidgets('Next cross-fades to the next episode in the same sheet, and '
        'Previous goes back', (tester) async {
      _usePhoneScreen(tester);
      await open(tester, 1);

      await tester.tap(find.text('Next · E3'));
      await tester.pumpAndSettle();
      expect(find.text('Episode 3'), findsOneWidget);
      expect(find.text('Episode 2'), findsNothing);
      expect(find.text('S1 · E3'), findsOneWidget);
      expect(find.text('Previous · E2'), findsOneWidget);

      await tester.tap(find.text('Previous · E2'));
      await tester.pumpAndSettle();
      expect(find.text('Episode 2'), findsOneWidget);
    });

    testWidgets('the new episode starts at the top again', (tester) async {
      _usePhoneScreen(tester);
      final long = [
        Episode(
          episodeNumber: 1,
          name: 'Long',
          overview: List.filled(80, 'A long synopsis sentence.').join(' '),
          stillPath: null,
          airDate: null,
          runtimeMinutes: null,
        ),
        ep(2),
      ];
      await tester.pumpWidget(
        _wrap(EpisodeSheet(seasonNumber: 1, episode: long[0], episodes: long)),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();

      await tester.tap(find.text('Next · E2'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Episode 2')).top, lessThan(600));
      expect(tester.getRect(find.byType(EpisodeSheetHeader)).top, 0);
    });

    testWidgets('the first episode\'s Previous and the last one\'s Next are '
        'dimmed and do nothing', (tester) async {
      _usePhoneScreen(tester);
      await open(tester, 0);
      expect(find.text('Previous'), findsOneWidget);
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(find.text('Episode 1'), findsOneWidget);
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.text('Previous'),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        lessThan(1),
      );

      await open(tester, 2);
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Episode 3'), findsOneWidget);
    });

    testWidgets('a season with a single episode has no foot', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        _wrap(
          EpisodeSheet(seasonNumber: 1, episode: all[0], episodes: [all[0]]),
        ),
      );
      expect(find.byType(EpisodeNavButton), findsNothing);
    });

    testWidgets('the foot is pinned: it stays put while the content scrolls', (
      tester,
    ) async {
      _usePhoneScreen(tester);
      await open(tester, 1);
      final before = tester.getRect(find.text('Next · E3'));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(tester.getRect(find.text('Next · E3')), before);
    });

    testWidgets('at 200% text on a small phone the buttons stack, no '
        'overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _wrap(
          EpisodeSheet(seasonNumber: 1, episode: all[1], episodes: all),
          locale: const Locale('es'),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      final next = tester.getRect(find.text('Siguiente · E3'));
      final previous = tester.getRect(find.text('Anterior · E1'));
      expect(previous.top, greaterThan(next.bottom));
    });
  });

  group('closing it with a swipe down', () {
    Future<void> openModal(WidgetTester tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: false,
                    builder: (_) =>
                        EpisodeSheet(seasonNumber: 1, episode: _episode),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsOneWidget);
    }

    testWidgets('pulling the handle down closes the sheet', (tester) async {
      await openModal(tester);

      await tester.fling(
        find.byType(EpisodeSheetHandle),
        const Offset(0, 500),
        1500,
      );
      await tester.pumpAndSettle();

      expect(find.byType(EpisodeSheet), findsNothing);
    });

    testWidgets('pulling the content (the still, the title) down past its top '
        'closes it too', (tester) async {
      await openModal(tester);
      await tester.flingFrom(
        tester.getCenter(find.byType(EpisodeSheetHeader)),
        const Offset(0, 500),
        1500,
      );
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsNothing);

      await openModal(tester);
      await tester.flingFrom(
        tester.getCenter(find.text('Hands')),
        const Offset(0, 500),
        1500,
      );
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsNothing);
    });

    testWidgets('the same pull closes it with iOS bouncing physics', (
      tester,
    ) async {
      await openModal(tester);
      await tester.flingFrom(
        tester.getCenter(find.byType(EpisodeSheetHeader)),
        const Offset(0, 500),
        1500,
      );
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('a swipe up scrolls the content and does not close the '
        'sheet', (tester) async {
      await openModal(tester);
      await tester.flingFrom(
        tester.getCenter(find.byType(EpisodeSheetHeader)),
        const Offset(0, -300),
        1500,
      );
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsOneWidget);
    });

    testWidgets('scrolling back up to the top by a small drag does not close '
        'it', (tester) async {
      await openModal(tester);
      await tester.dragFrom(
        tester.getCenter(find.byType(EpisodeSheetHeader)),
        const Offset(0, 30),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsOneWidget);
    });

    testWidgets('the handle is drawn over the still, outside the scrolling '
        'list', (tester) async {
      await openModal(tester);

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(EpisodeSheetHandle),
        ),
        findsNothing,
      );
      final handle = tester.getRect(find.byType(EpisodeSheetHandle));
      final header = tester.getRect(find.byType(EpisodeSheetHeader));
      expect(handle.top, header.top);
    });
  });
}
