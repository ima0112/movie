import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/tv_detail/presentation/widgets/tv_status_pill.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';

void main() {
  group('TvStatusPill', () {
    testWidgets('"Returning Series" renders as the selected (amber) '
        '"Airing" chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TvStatusPill(status: 'Returning Series')),
        ),
      );

      expect(find.text('Airing'), findsOneWidget);
      final chip = tester.widget<AppChip>(find.byType(AppChip));
      expect(chip.state, ChipState.selected);
    });

    testWidgets('"Ended" renders as the neutral "Ended" chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TvStatusPill(status: 'Ended')),
        ),
      );

      expect(find.text('Ended'), findsOneWidget);
      final chip = tester.widget<AppChip>(find.byType(AppChip));
      expect(chip.state, ChipState.normal);
    });

    testWidgets('"Canceled" renders as the neutral "Cancelled" chip', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TvStatusPill(status: 'Canceled')),
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
      final chip = tester.widget<AppChip>(find.byType(AppChip));
      expect(chip.state, ChipState.normal);
    });

    testWidgets('an unexpected TMDB status falls back to the "Airing" '
        'treatment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TvStatusPill(status: 'Pilot')),
        ),
      );

      expect(find.text('Airing'), findsOneWidget);
    });
  });
}
