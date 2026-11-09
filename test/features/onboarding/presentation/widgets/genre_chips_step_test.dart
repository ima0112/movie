import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/features/onboarding/presentation/widgets/genre_chips_step.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _wrap(
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  Locale? locale,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 47, bottom: 34),
        textScaler: TextScaler.linear(textScale),
      ),
      child: child,
    ),
  );
}

void main() {
  const action = Genre(id: 'action');

  testWidgets('shows the copy and every genre chip; tapping toggles', (
    tester,
  ) async {
    Genre? toggled;
    await tester.pumpWidget(
      _wrap(
        GenreChipsStep(
          selected: const {},
          onToggle: (g) => toggled = g,
          onSkip: () {},
          onNext: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('MAKE IT YOURS'), findsOneWidget);
    expect(find.text('What do you like?'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Action'));
    expect(toggled, action);
  });

  testWidgets('Skip and Next call their own callbacks', (tester) async {
    var skipped = 0;
    var next = 0;
    await tester.pumpWidget(
      _wrap(
        GenreChipsStep(
          selected: const {},
          onToggle: (_) {},
          onSkip: () => skipped++,
          onNext: () => next++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Skip'));
    await tester.tap(find.text('Next'));
    expect((skipped, next), (1, 1));
  });

  testWidgets('survives a small device at 200% text scale (es) without '
      'overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GenreChipsStep(
          selected: {action},
          onToggle: (_) {},
          onSkip: () {},
          onNext: () {},
        ),
        size: const Size(320, 568),
        textScale: 2,
        locale: const Locale('es'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Siguiente'), findsOneWidget);
  });
}
