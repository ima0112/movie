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
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/presentation/widgets/taste_card_posters.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/comet_border.dart';
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

  Future<void> pump(WidgetTester tester, {bool reduceMotion = false}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: const Scaffold(body: DiscoverTasteCard()),
        ),
      );

  /// The comet never stops, so `pumpAndSettle` would never return: let the
  /// repositories' first events through instead.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('shows with no profile and an empty My List, and goes away '
      'once a usable profile exists', (tester) async {
    await pump(tester);
    await settle(tester);
    expect(find.text('Recommendations tailored to you'), findsOneWidget);

    await tastes.save(
      TasteProfile(
        likedGenres: {const Genre(id: 'action')},
        vetoedGenres: const {},
        likedVibes: const {},
        yearFrom: 1990,
        updatedAt: DateTime(2026),
      ),
    );
    await settle(tester);
    expect(find.text('Recommendations tailored to you'), findsNothing);
  });

  testWidgets('the card: a "FOR YOU" eyebrow, the title and a button on the '
      'left; three posters on the right; no round icon and no arrow', (
    tester,
  ) async {
    await pump(tester);
    await settle(tester);

    expect(find.text('FOR YOU'), findsOneWidget);
    expect(find.text('Choose my tastes'), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronRight), findsNothing);

    final title = tester.getRect(find.text('Recommendations tailored to you'));
    final button = tester.getRect(find.text('Choose my tastes'));
    final posters = find.byType(TasteCardPosters);
    expect(posters, findsOneWidget);
    expect(tester.getRect(posters).left, greaterThan(title.right - 1));
    expect(button.top, greaterThan(title.bottom)); // under the title
    // Three real (bundled) posters, each tilted differently.
    final images = find.descendant(of: posters, matching: find.byType(Image));
    expect(images, findsNWidgets(3));
    final angles = {
      for (final t in tester.widgetList<Transform>(
        find.descendant(of: posters, matching: find.byType(Transform)),
      ))
        t.transform.storage[1],
    };
    expect(angles.length, greaterThanOrEqualTo(3));
  });

  testWidgets('a comet runs round the border; with reduce motion it stands '
      'still', (tester) async {
    await pump(tester);
    await settle(tester);
    expect(find.byType(CometBorder), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue);

    await pump(tester, reduceMotion: true);
    await settle(tester);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the card is not tappable, only its button is', (tester) async {
    await pump(tester);
    await settle(tester);

    expect(
      find.ancestor(
        of: find.text('Recommendations tailored to you'),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
    expect(find.byType(PrimaryButton), findsOneWidget);
  });

  testWidgets('it survives a small phone at 200% text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: DiscoverTasteCard()),
        ),
      ),
    );
    await settle(tester);

    expect(find.text('Recommendations tailored to you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
