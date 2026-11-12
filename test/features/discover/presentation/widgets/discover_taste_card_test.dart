import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/presentation/widgets/discover_taste_card.dart';
import 'package:movies/l10n/app_localizations.dart';

void main() {
  late InMemoryTasteProfileRepository tastes;

  setUp(() {
    configureDependencies(fake.name);
    tastes = InMemoryTasteProfileRepository();
    getIt.unregister<TasteProfileRepository>();
    getIt.registerSingleton<TasteProfileRepository>(tastes);
    getIt.unregister<UserLibraryRepository>();
    getIt.registerSingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository(),
    );
  });
  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DiscoverTasteCard()),
    ),
  );

  testWidgets('shows with no profile and an empty My List, and goes away '
      'once a usable profile exists', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.text('Make Home yours'), findsOneWidget);

    await tastes.save(
      TasteProfile(
        likedGenres: {const Genre(id: 'action')},
        vetoedGenres: const {},
        likedVibes: const {},
        yearFrom: 1990,
        updatedAt: DateTime(2026),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Make Home yours'), findsNothing);
  });
}
