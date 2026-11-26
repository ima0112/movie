import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:movies/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester,
  Future<void> Function() clear, {
  Locale locale = const Locale('en'),
}) => tester.pumpWidget(
  MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: SettingsDataSection(
          userLibraryRepository: InMemoryUserLibraryRepository(),
          tasteProfileRepository: InMemoryTasteProfileRepository(),
          surpriseHistoryRepository: InMemorySurpriseHistoryRepository(),
          clearCache: clear,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('tapping "Clear cache" clears at once and confirms', (
    tester,
  ) async {
    var cleared = 0;
    await _pump(tester, () async => cleared++);

    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();

    expect(cleared, 1);
    expect(find.text('Cache cleared'), findsOneWidget);
  });

  testWidgets('a failure says so instead of confirming', (tester) async {
    await _pump(tester, () async => throw StateError('disk'));

    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't clear the cache"), findsOneWidget);
    expect(find.text('Cache cleared'), findsNothing);
  });

  testWidgets('it is in Spanish too', (tester) async {
    await _pump(tester, () async {}, locale: const Locale('es'));

    await tester.tap(find.text('Borrar caché'));
    await tester.pumpAndSettle();

    expect(find.text('Caché borrada'), findsOneWidget);
  });
}
