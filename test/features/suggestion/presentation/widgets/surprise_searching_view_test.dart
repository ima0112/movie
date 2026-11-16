import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/surprise_searching_view.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _host({
  required VoidCallback onCancel,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: SurpriseSearchingView(onCancel: onCancel),
);

void main() {
  testWidgets('the copy, in English and Spanish, and the × calls onCancel', (
    tester,
  ) async {
    var cancelled = 0;
    await tester.pumpWidget(_host(onCancel: () => cancelled++));

    expect(find.text('SURPRISE ME'), findsOneWidget);
    expect(find.text('Shuffling your 5 surprises'), findsOneWidget);
    expect(
      find.text("Mixing what you like with what you don't expect"),
      findsOneWidget,
    );
    await tester.tap(find.byType(IconButton));
    expect(cancelled, 1);

    await tester.pumpWidget(_host(onCancel: () {}, locale: const Locale('es')));
    await tester.pump();
    expect(find.text('SORPRÉNDEME'), findsOneWidget);
    expect(find.text('Barajando tus 5 sorpresas'), findsOneWidget);
    expect(
      find.text('Mezclando lo que te gusta con lo que no esperas'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a short, narrow phone at 200% text: nothing overflows and the '
      'text block is still there', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(onCancel: () {}, textScale: 2));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Shuffling your 5 surprises'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
