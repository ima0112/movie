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
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_text_styles.dart';
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
    expect(find.byType(AccentButton), findsOneWidget);
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

  /// A card at [width] logical pixels, in [locale].
  Future<void> pumpAt(
    WidgetTester tester, {
    required double width,
    String locale = 'en',
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: DiscoverTasteCard()),
        ),
      ),
    );
    await settle(tester);
  }

  // The test environment has no Manrope (every glyph is a 20 px square), so
  // real word widths can't be measured here: what is checked is the column the
  // text gets — never under the width its longest word needs — and that the
  // button stays on one line.
  for (final width in [320.0, 340.0, 360.0, 390.0, 430.0]) {
    for (final locale in ['en', 'es']) {
      testWidgets('at $width px in $locale the title gets at least '
          '${TasteCardPosters.minTextWidth} px and the button is one line', (
        tester,
      ) async {
        await pumpAt(tester, width: width, locale: locale);

        final titleFinder = find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.style == AppTextStyles.h2 &&
              w.data != null &&
              w.data!.length > 10,
        );
        expect(titleFinder, findsOneWidget);
        expect(
          tester.getSize(titleFinder).width,
          greaterThanOrEqualTo(TasteCardPosters.minTextWidth),
        );

        // One line: no taller than a single h3 line plus its padding.
        expect(tester.getSize(find.byType(AccentButton)).height, lessThan(56));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('a very narrow card leaves the posters out; a narrow one shows '
      'two; a wide one all three', (tester) async {
    await pumpAt(tester, width: 320);
    expect(find.byType(TasteCardPosters), findsNothing);

    await pumpAt(tester, width: 340);
    expect(
      tester.widget<TasteCardPosters>(find.byType(TasteCardPosters)).compact,
      isTrue,
    );
    expect(
      find.descendant(
        of: find.byType(TasteCardPosters),
        matching: find.byType(Image),
      ),
      findsNWidgets(2),
    );

    await pumpAt(tester, width: 430);
    expect(
      tester.widget<TasteCardPosters>(find.byType(TasteCardPosters)).compact,
      isFalse,
    );
    expect(
      find.descendant(
        of: find.byType(TasteCardPosters),
        matching: find.byType(Image),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets('the button is amber with dark text, per the card\'s design', (
    tester,
  ) async {
    await pumpAt(tester, width: 390);

    final pill = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(AccentButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((pill.decoration as BoxDecoration).color, AppColors.accent);
    expect(
      tester.widget<Text>(find.text('Choose my tastes')).style!.color,
      AppColors.onAccent,
    );
  });

  testWidgets('the posters sit inside the card and stay clear of the text', (
    tester,
  ) async {
    await pumpAt(tester, width: 390);

    final card = tester.getRect(find.byType(CometBorder));
    final posters = tester.getRect(find.byType(TasteCardPosters));
    final title = tester.getRect(find.text('Recommendations tailored to you'));
    expect(posters.right, lessThanOrEqualTo(card.right));
    expect(posters.left, greaterThanOrEqualTo(title.right - 1));
  });
}
