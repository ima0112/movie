import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/state_views.dart';

Widget _host(Widget child, {Locale? locale, double bottomInset = 0}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('FailureStateView', () {
    testWidgets('a network failure is the offline state, with an amber '
        'Retry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        _host(
          FailureStateView(
            reason: FailureReason.network,
            onRetry: () => retried++,
          ),
        ),
      );

      expect(find.byIcon(AppIcons.wifiOff), findsOneWidget);
      expect(find.text("You're offline"), findsOneWidget);
      expect(find.byType(AccentButton), findsOneWidget);
      expect(find.text('Go to My List'), findsNothing);

      await tester.tap(find.text('Retry'));
      expect(retried, 1);
    });

    testWidgets('the root tabs add "Go to My List", which calls back', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        _host(
          FailureStateView(
            reason: FailureReason.network,
            onRetry: () {},
            onGoToMyList: () => opened++,
          ),
        ),
      );

      await tester.tap(find.text('Go to My List'));
      expect(opened, 1);
    });

    testWidgets('any other cause is the error state with that cause\'s '
        'message, never offline', (tester) async {
      await tester.pumpWidget(
        _host(FailureStateView(reason: FailureReason.quota, onRetry: () {})),
      );

      expect(find.byIcon(AppIcons.cloudOff), findsOneWidget);
      expect(find.text("Couldn't load"), findsOneWidget);
      expect(
        find.text('Too many requests — try again in a moment.'),
        findsOneWidget,
      );
      expect(find.byIcon(AppIcons.wifiOff), findsNothing);
    });

    testWidgets('the Spanish copy', (tester) async {
      await tester.pumpWidget(
        _host(
          FailureStateView(reason: FailureReason.network, onRetry: () {}),
          locale: const Locale('es'),
        ),
      );
      expect(find.text('Estás sin conexión'), findsOneWidget);
      expect(
        find.text(
          'Para descubrir y buscar necesitas internet. Tu lista sigue disponible.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('server error in Spanish: "No pudimos cargar" and the server '
        'text', (tester) async {
      await tester.pumpWidget(
        _host(
          FailureStateView(reason: FailureReason.server, onRetry: () {}),
          locale: const Locale('es'),
        ),
      );
      expect(find.text('No pudimos cargar'), findsOneWidget);
      expect(
        find.text(
          'Algo falló al conectar con el servidor. Inténtalo de nuevo en unos segundos.',
        ),
        findsOneWidget,
      );
    });
  });

  group('StateLayout', () {
    testWidgets('centers in the room above the tab bar, not the whole body', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StateLayout(icon: AppIcons.search, title: 'T', body: 'B'),
          bottomInset: 100,
        ),
      );

      final area = tester.getSize(find.byType(StateLayout));
      final center = tester.getCenter(find.text('T'));
      expect(center.dy, lessThan(area.height / 2));
    });

    testWidgets('an empty state\'s CTA stays outlined, an error\'s Retry is '
        'amber', (tester) async {
      await tester.pumpWidget(
        _host(
          const EmptyStateView(
            icon: AppIcons.search,
            title: 'Nothing',
            body: 'Body',
            ctaLabel: 'Explore',
          ),
        ),
      );
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.byType(AccentButton), findsNothing);

      await tester.pumpWidget(
        _host(const ErrorStateView(title: 'T', body: 'B')),
      );
      expect(find.byType(AccentButton), findsOneWidget);
      final accent = tester.widget<AccentButton>(find.byType(AccentButton));
      expect(accent.label, 'Retry');
      expect(AppColors.accent, isNotNull);
    });
  });
}
