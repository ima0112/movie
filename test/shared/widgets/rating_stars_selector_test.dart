import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/mark_as_watched_sheet.dart';
import 'package:movies/shared/widgets/rating_stars_selector.dart';

Widget _app(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('filled up to the rating, outline after it, each star labelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RatingStarsSelector(rating: 3, onChanged: (_) {})),
    );

    expect(find.byIcon(AppIcons.starFill), findsNWidgets(3));
    expect(find.byIcon(AppIcons.star), findsNWidgets(2));
    expect(find.bySemanticsLabel('1 of 5'), findsOneWidget);
    expect(find.bySemanticsLabel('5 of 5'), findsOneWidget);
  });

  testWidgets('tapping a star rates; tapping the current rating clears it', (
    tester,
  ) async {
    int? rating = 2;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _app(
          RatingStarsSelector(
            rating: rating,
            onChanged: (value) => setState(() => rating = value),
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('4 of 5'));
    await tester.pump();
    expect(rating, 4);

    await tester.tap(find.bySemanticsLabel('4 of 5'));
    await tester.pump();
    expect(rating, isNull);
  });

  testWidgets('the whole sheet survives a small device at 200% text scale '
      '(es)', (tester) async {
    await tester.pumpWidget(
      _app(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: MarkAsWatchedSheet(
            mediaKey: const MediaKey(type: MediaType.movie, tmdbId: 1),
            userLibraryRepository: InMemoryUserLibraryRepository(),
          ),
        ),
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('FECHA'), findsOneWidget);
  });
}
