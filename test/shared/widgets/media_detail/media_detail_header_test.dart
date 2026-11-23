import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/theme/app_text_styles.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/core/domain/entities/release_status.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_header.dart';
import 'package:movies/shared/widgets/poster_badge.dart';
import 'package:movies/shared/widgets/media_detail/media_meta_line.dart';
import 'package:movies/shared/widgets/media_detail/rating_ring.dart';

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
      expect(find.text('Coming 12 Jun, 2026'), findsOneWidget);
      // Amber, above the title.
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
      // Same design as "Coming": the amber tag.
      expect(
        tester.widget<PosterBadge>(find.byType(PosterBadge)).amber,
        isTrue,
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

  group('the header rating and meta line', () {
    testWidgets('the ring sits at the right of the title and the meta line '
        'closes the block, language last', (tester) async {
      await tester.pumpWidget(
        _app(
          MediaDetailHeader(
            imageUrl: null,
            title: 'Breaking Bad',
            tagline: 'All bad things must end.',
            metaPrefix: '2008 – 2013 · United States',
            genres: const [_action, _drama],
            language: 'English',
            voteAverage: 8.9,
          ),
        ),
      );

      final ring = tester.getRect(find.byType(RatingRing));
      final title = tester.getRect(find.text('Breaking Bad'));
      expect(ring.left, greaterThan(title.right));
      expect(find.text('8.9'), findsOneWidget);
      final meta = tester.getRect(find.byType(MediaMetaLine));
      expect(
        meta.top,
        greaterThan(tester.getRect(find.byType(RatingRing)).bottom),
      );
      expect(find.text('2008 – 2013 · United States'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      // Left to right: prefix, genres, language.
      expect(
        tester.getRect(find.text('Drama')).left,
        lessThan(tester.getRect(find.text('English')).left),
      );

      // The genres are plain information: nothing to tap.
      expect(
        find.ancestor(
          of: find.text('Action'),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('showRating false (not out yet): no ring', (tester) async {
      await tester.pumpWidget(
        _app(
          const MediaDetailHeader(
            imageUrl: null,
            title: 'Soon',
            voteAverage: 0,
            showRating: false,
          ),
        ),
      );
      expect(find.byType(RatingRing), findsNothing);
    });

    testWidgets('a long title, tagline and meta line survive a small device '
        'at 200% text (es)', (tester) async {
      await tester.pumpWidget(
        _app(
          const MediaDetailHeader(
            imageUrl: null,
            title: 'El señor de los anillos: la comunidad del anillo',
            tagline: 'Un anillo para gobernarlos a todos, un anillo para ...',
            metaPrefix: '2008 – 2013 · Estados Unidos',
            genres: [_action, _drama],
            language: 'Inglés',
            voteAverage: 9,
          ),
          locale: const Locale('es'),
          size: const Size(320, 568),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a long title that ends in an ellipsis uses the taller title '
        'line, so its descenders are not cut', (tester) async {
      await tester.pumpWidget(
        _app(
          const MediaDetailHeader(
            imageUrl: null,
            title:
                'The Lord of the Rings: The Rings of Power and a much longer '
                'name that cannot fit',
            voteAverage: 7.2,
          ),
          size: const Size(390, 844),
        ),
      );

      final title = tester.widget<Text>(
        find.textContaining('The Lord of the Rings'),
      );
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(title.style, AppTextStyles.displayTitle);
      expect(AppTextStyles.displayTitle.height, greaterThanOrEqualTo(1.25));
    });
  });
}
