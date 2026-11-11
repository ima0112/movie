import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/core/domain/entities/release_status.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_header.dart';
import 'package:movies/shared/widgets/poster_badge.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_info_card.dart';

const _action = Genre(id: 'action');
const _drama = Genre(id: 'drama');

Widget _app(
  Widget child, {
  Locale? locale,
  Size size = const Size(390, 844),
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('MediaDetailHeader', () {
    testWidgets('is 420 px tall with the title and tagline left-aligned '
        'over it', (tester) async {
      await tester.pumpWidget(
        _app(
          const MediaDetailHeader(
            imageUrl: null,
            title: 'Inception',
            tagline: 'Your mind is the scene of the crime.',
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(MediaDetailHeader)).height,
        MediaDetailHeader.height,
      );
      expect(find.text('Inception'), findsOneWidget);
      final tagline = tester.widget<Text>(find.textContaining('scene of'));
      expect(tagline.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('a status tag sits above the title: Coming soon, Coming with '
        'its date, or In theaters; none for an ordinary title', (tester) async {
      Future<void> pump(ReleaseStatus? status) => tester.pumpWidget(
        _app(
          MediaDetailHeader(
            imageUrl: null,
            title: 'Inception',
            releaseStatus: status,
          ),
        ),
      );

      await pump(null);
      expect(find.byType(PosterBadge), findsNothing);

      await pump(const ReleaseStatus(ReleaseStage.upcoming));
      expect(find.text('Coming soon'), findsOneWidget);

      await pump(
        ReleaseStatus(ReleaseStage.upcoming, date: DateTime(2026, 6, 12)),
      );
      expect(find.text('Coming Jun 12, 2026'), findsOneWidget);
      // Amber for "not out yet", above the title.
      final tag = tester.getRect(find.byType(PosterBadge));
      expect(tag.bottom, lessThan(tester.getRect(find.text('Inception')).top));
      expect(
        tester.widget<PosterBadge>(find.byType(PosterBadge)).amber,
        isTrue,
      );

      await pump(
        ReleaseStatus(ReleaseStage.inTheaters, date: DateTime(2026, 4, 24)),
      );
      expect(find.text('In theaters'), findsOneWidget);
      expect(
        tester.widget<PosterBadge>(find.byType(PosterBadge)).amber,
        isFalse,
      );
    });

    testWidgets('no tagline still lays out', (tester) async {
      await tester.pumpWidget(
        _app(const MediaDetailHeader(imageUrl: null, title: 'Breaking Bad')),
      );

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MediaDetailInfoCard', () {
    testWidgets('shows year, tappable genres, rating and extra chips, and '
        'the actions slot', (tester) async {
      Genre? tapped;
      await tester.pumpWidget(
        _app(
          MediaDetailInfoCard(
            posterUrl: null,
            metaPrefix: '2010',
            genres: const [_action, _drama],
            voteAverage: 8.4,
            extraChips: const ['2 h 28 min', 'PG-13'],
            onGenreTap: (g) => tapped = g,
            actions: const Text('ACTIONS'),
          ),
        ),
      );

      expect(find.text('2010'), findsOneWidget);
      expect(find.text('8.4'), findsOneWidget);
      expect(find.text('2 h 28 min'), findsOneWidget);
      expect(find.text('PG-13'), findsOneWidget);
      expect(find.text('ACTIONS'), findsOneWidget);

      await tester.tap(find.text('Action'));
      expect(tapped, _action);
    });

    testWidgets('survives a small device at 200% text scale (es)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const MediaDetailInfoCard(
            posterUrl: null,
            metaPrefix: '2008–2013 · 5 temporadas · 62 episodios',
            genres: [_action, _drama],
            voteAverage: 9,
            extraChips: ['2 h 28 min', 'PG-13'],
            actions: Text('ACTIONS'),
          ),
          locale: const Locale('es'),
          size: const Size(320, 568),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
