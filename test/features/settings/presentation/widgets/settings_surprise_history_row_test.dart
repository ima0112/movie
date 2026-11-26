import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:movies/l10n/app_localizations.dart';

Future<InMemorySurpriseHistoryRepository> _pump(
  WidgetTester tester, {
  int shown = 0,
  Locale locale = const Locale('en'),
}) async {
  final history = InMemorySurpriseHistoryRepository();
  await history.recordShown([
    for (var i = 0; i < shown; i++)
      SurpriseHistoryEntry(
        key: MediaKey(type: MediaType.movie, tmdbId: i),
        sessionId: 's',
        shownAt: DateTime(2026, 11, 16),
      ),
  ]);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SettingsDataSection(
            userLibraryRepository: InMemoryUserLibraryRepository(),
            tasteProfileRepository: InMemoryTasteProfileRepository(),
            surpriseHistoryRepository: history,
            clearCache: () async {},
          ),
        ),
      ),
    ),
  );
  return history;
}

void main() {
  testWidgets('the row asks first, saying how many it forgets, and cancelling '
      'keeps the history', (tester) async {
    final history = await _pump(tester, shown: 3);

    await tester.tap(find.text('Delete Surprise me history'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your Surprise me history?'), findsOneWidget);
    expect(find.textContaining('3 items'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      (await history.all() as Success<List<SurpriseHistoryEntry>>).value,
      hasLength(3),
    );
  });

  testWidgets('confirming forgets everything and says so', (tester) async {
    final history = await _pump(tester, shown: 3);

    await tester.tap(find.text('Delete Surprise me history'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(
      (await history.all() as Success<List<SurpriseHistoryEntry>>).value,
      isEmpty,
    );
    expect(find.text('Surprise me history deleted'), findsOneWidget);
  });

  testWidgets('the Spanish copy', (tester) async {
    await _pump(tester, shown: 1, locale: const Locale('es'));

    await tester.tap(find.text('Eliminar historial de Sorpréndeme'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar tu historial de Sorpréndeme?'), findsOneWidget);
    expect(find.textContaining('1 elemento'), findsOneWidget);
  });
}
