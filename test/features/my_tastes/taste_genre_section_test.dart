import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_genre_section.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';

const _action = Genre(id: 'action');
const _comedy = Genre(id: 'comedy');

Widget _wrap(Widget child, {double textScale = 1, Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          size: const Size(320, 568),
          textScaler: TextScaler.linear(textScale),
        ),
        child: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the title, hint and a chip per genre; tap toggles', (
    tester,
  ) async {
    Genre? toggled;
    await tester.pumpWidget(
      _wrap(
        TasteGenreSection(
          title: 'Genres you like',
          hint: 'Choose as many as you like.',
          genres: const [_action, _comedy],
          selected: {_comedy},
          onToggle: (g) => toggled = g,
        ),
      ),
    );

    expect(find.text('Genres you like'), findsOneWidget);
    expect(find.text('Choose as many as you like.'), findsOneWidget);
    expect(
      tester.widgetList<AppChip>(find.byType(AppChip)).map((c) => c.state),
      [ChipState.normal, ChipState.selected],
    );

    await tester.tap(find.text('Action'));
    expect(toggled, _action);
  });

  testWidgets('a picked genre in the "avoid" section uses the vetoed look', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TasteGenreSection(
          title: 'Genres you never want',
          hint: "We won't show them in recommendations.",
          genres: const [_action, _comedy],
          selected: {_action},
          onToggle: (_) {},
          selectedState: ChipState.vetoed,
        ),
      ),
    );

    expect(
      tester.widgetList<AppChip>(find.byType(AppChip)).map((c) => c.state),
      [ChipState.vetoed, ChipState.normal],
    );
    final text = tester.widget<Text>(find.text('Action'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('wraps without overflow at 200% text scale (es)', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TasteGenreSection(
          title: 'Géneros que nunca quieres',
          hint: 'No los mostramos en recomendaciones.',
          genres: const [_action, _comedy],
          selected: <Genre>{},
          onToggle: (_) {},
        ),
        textScale: 2,
        locale: const Locale('es'),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
