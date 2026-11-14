import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/release_status.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/where_to_watch_section.dart';

const _providers = WatchProviders(
  flatrate: ['Max'],
  rent: [],
  buy: [],
  link: 'https://example.com',
);

void main() {
  group('WhereToWatchSection', () {
    testWidgets('with no provider data it explains why and keeps the country '
        'pill so another country can be picked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhereToWatchSection(
              providers: WatchProviders.empty,
              regionName: 'Cuba',
              onRegionTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Where to watch'), findsOneWidget);
      expect(find.textContaining('Not available'), findsOneWidget);
      expect(find.text('Data from JustWatch'), findsOneWidget);
      await tester.tap(find.text('Cuba'));
      expect(tapped, isTrue);
    });

    testWidgets('shows the region name in gray next to the title', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
            ),
          ),
        ),
      );

      expect(find.text('Where to watch'), findsOneWidget);
      expect(find.text('Spain'), findsOneWidget);
    });

    testWidgets('tapping the region calls onRegionTap when one is given', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
              onRegionTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spain'));
      expect(tapped, isTrue);
    });

    testWidgets('tapping the region is a harmless no-op when '
        'onRegionTap is null (H6/Settings not built yet)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spain'));
      await tester.pump();
      // Nothing to assert beyond "didn't throw" — this is exactly the
      // documented-TODO state the task asked for.
    });

    group('the card layout', () {
      Widget wrap(
        WatchProviders providers, {
        void Function(String)? onProviderTap,
        double textScale = 1,
        Locale? locale,
        Size size = const Size(390, 844),
      }) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: WhereToWatchSection(
                providers: providers,
                regionName: 'Spain',
                onProviderTap: onProviderTap,
              ),
            ),
          ),
        ),
      );

      const all = WatchProviders(
        flatrate: ['Netflix', 'Max'],
        rent: ['Apple TV'],
        buy: ['Rakuten'],
        link: 'https://example.com/watch',
      );

      testWidgets('shows the JustWatch badge, the three group labels, and '
          'the mandatory attribution', (tester) async {
        await tester.pumpWidget(wrap(all));

        expect(find.text('JustWatch'), findsOneWidget);
        expect(find.text('SUBSCRIPTION'), findsOneWidget);
        expect(find.text('RENT'), findsOneWidget);
        expect(find.text('BUY'), findsOneWidget);
        expect(find.text('Data from JustWatch'), findsOneWidget);
        // Streaming tiles show the service name under the logo.
        expect(find.text('Netflix'), findsOneWidget);
      });

      testWidgets('a service with no logo shows its first letter', (
        tester,
      ) async {
        await tester.pumpWidget(wrap(all));

        expect(find.text('N'), findsOneWidget); // Netflix
        expect(find.text('M'), findsOneWidget); // Max
      });

      testWidgets('groups with no data are omitted', (tester) async {
        await tester.pumpWidget(
          wrap(
            const WatchProviders(
              flatrate: ['Max'],
              rent: [],
              buy: [],
              link: null,
            ),
          ),
        );

        expect(find.text('SUBSCRIPTION'), findsOneWidget);
        expect(find.text('RENT'), findsNothing);
        expect(find.text('BUY'), findsNothing);
      });

      testWidgets('more than 5 streaming services collapse into "+N"', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            const WatchProviders(
              flatrate: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
              rent: [],
              buy: [],
              link: null,
            ),
          ),
        );

        expect(find.text('+2'), findsOneWidget);
      });

      testWidgets('tapping a service opens the JustWatch link', (tester) async {
        String? opened;
        await tester.pumpWidget(wrap(all, onProviderTap: (l) => opened = l));

        await tester.tap(find.text('Netflix'));
        expect(opened, 'https://example.com/watch');
      });

      testWidgets('survives a small device at 200% text scale (es)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            all,
            textScale: 2,
            locale: const Locale('es'),
            size: const Size(320, 568),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });

    group('a title that is not out yet, or only in cinemas', () {
      Future<void> pump(WidgetTester tester, ReleaseStatus status) =>
          tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: WhereToWatchSection(
                  providers: WatchProviders.empty,
                  regionName: 'Spain',
                  releaseStatus: status,
                ),
              ),
            ),
          );

      testWidgets('upcoming says it is not out, with the date when known', (
        tester,
      ) async {
        await pump(
          tester,
          ReleaseStatus(ReleaseStage.upcoming, date: DateTime(2026, 6, 12)),
        );
        expect(
          find.textContaining('comes out on 12 Jun, 2026'),
          findsOneWidget,
        );
        expect(find.textContaining('Not available'), findsNothing);

        await pump(tester, const ReleaseStatus(ReleaseStage.upcoming));
        expect(
          find.text("It isn't out yet, so it isn't on any service."),
          findsOneWidget,
        );
      });

      testWidgets('in theaters says so, with the streaming date when known', (
        tester,
      ) async {
        await pump(
          tester,
          ReleaseStatus(
            ReleaseStage.inTheaters,
            date: DateTime(2026, 4, 24),
            streamingDate: DateTime(2026, 6, 25),
          ),
        );
        expect(
          find.textContaining('Expected on streaming on 25 Jun, 2026'),
          findsOneWidget,
        );

        await pump(
          tester,
          ReleaseStatus(ReleaseStage.inTheaters, date: DateTime(2026, 4, 24)),
        );
        expect(find.textContaining('not on any service yet'), findsOneWidget);
      });

      testWidgets('with services listed, the services win over the message', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: WhereToWatchSection(
                providers: _providers,
                regionName: 'Spain',
                releaseStatus: const ReleaseStatus(ReleaseStage.inTheaters),
              ),
            ),
          ),
        );
        expect(find.textContaining('not on any service'), findsNothing);
        expect(find.text('Max'), findsWidgets);
      });
    });
  });
}
