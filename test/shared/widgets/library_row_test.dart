import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/library_row.dart';

Widget _pumpTrailing(LibraryRowTrailing trailing) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: LibraryRow(
        posterUrl: null,
        title: 'Dune: Part Two',
        metadata: '2024 · Movie · 2 h 46 min',
        trailing: trailing,
      ),
    ),
  );
}

void main() {
  group('LibraryRowTrailing.starsWithDate', () {
    testWidgets('renders 5 stars and a relative date at once', (tester) async {
      await tester.pumpWidget(
        _pumpTrailing(
          LibraryRowTrailing.starsWithDate(
            rating: 4,
            watchedAt: DateTime.now(),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.starFill), findsNWidgets(5));
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('a null rating renders all five stars, not zero of them', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pumpTrailing(
          LibraryRowTrailing.starsWithDate(
            rating: null,
            watchedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.starFill), findsNWidgets(5));
      expect(find.text('Yesterday'), findsOneWidget);
    });
  });
}
