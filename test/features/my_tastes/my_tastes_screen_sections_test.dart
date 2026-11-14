import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_avoided_genres_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_footer.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_liked_genres_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_type_section.dart';
import 'package:movies/l10n/app_localizations.dart';

Future<({MyTastesCubit tastes, TasteProfileCubit profile})> _pump(
  WidgetTester tester, {
  Locale? locale,
}) async {
  final profile = TasteProfileCubit(InMemoryTasteProfileRepository());
  final tastes = MyTastesCubit(
    profile,
    VibeCatalog.fromJson(const {'vibes': []}),
  );
  addTearDown(() async {
    await tastes.close();
    await profile.close();
  });
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: tastes,
        child: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                TasteTypeSection(),
                TasteLikedGenresSection(),
                TasteAvoidedGenresSection(),
                TasteFooter(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (tastes: tastes, profile: profile);
}

/// Lets the "Saved" indicator's 2-second timer run out, so none is left
/// pending when the test ends.
Future<void> _letSavedFade(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 3));

void main() {
  testWidgets('"What do you usually watch?": picks a type, then Both '
      'clears it', (tester) async {
    final c = await _pump(tester);
    expect(find.text('What do you usually watch?'), findsOneWidget);

    await tester.tap(find.text('TV Shows'));
    await tester.pump();
    expect(c.tastes.state.preferredType, MediaType.tvShow);

    await tester.tap(find.text('Both'));
    await tester.pump();
    expect(c.tastes.state.preferredType, isNull);
    await _letSavedFade(tester);
  });

  testWidgets('liked genres: tapping one picks it', (tester) async {
    final c = await _pump(tester);

    await tester.tap(find.text('Drama').first);
    await tester.pump();

    expect(c.tastes.state.likedGenres.map((g) => g.id), ['drama']);
    await _letSavedFade(tester);
  });

  testWidgets('avoided genres: starts with just "Add"; the picker adds one '
      'as a struck-through chip, and tapping that chip takes it back', (
    tester,
  ) async {
    final c = await _pump(tester);
    expect(find.text('Genres you avoid'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add a genre to avoid'), findsOneWidget);

    // The picker lists the genres; pick Horror (the last Horror chip is the
    // sheet's — the page's liked list has its own).
    await tester.tap(find.text('Horror').last);
    await tester.pumpAndSettle();
    expect(find.text('Add a genre to avoid'), findsNothing);
    expect(c.tastes.state.vetoedGenres.map((g) => g.id), ['horror']);

    // Now an avoided chip: tap to take it back.
    final avoided = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          w.data == 'Horror' &&
          (w.style?.decoration == TextDecoration.lineThrough),
    );
    expect(avoided, findsOneWidget);
    await tester.tap(avoided);
    await tester.pump();
    expect(c.tastes.state.vetoedGenres, isEmpty);
    await _letSavedFade(tester);
  });

  testWidgets('avoiding a liked genre moves it out of the liked ones', (
    tester,
  ) async {
    final c = await _pump(tester);
    await tester.tap(find.text('Horror').first);
    await tester.pump();
    expect(c.tastes.state.likedGenres.map((g) => g.id), ['horror']);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horror').last);
    await tester.pumpAndSettle();

    expect(c.tastes.state.likedGenres, isEmpty);
    expect(c.tastes.state.vetoedGenres.map((g) => g.id), ['horror']);
    await _letSavedFade(tester);
  });

  testWidgets('the footer says where it is saved and shows "Saved" after a '
      'change', (tester) async {
    final c = await _pump(tester);
    expect(
      find.text('Everything is saved only on your device.'),
      findsOneWidget,
    );
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(TasteFooter),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(opacity(), 0);

    c.tastes.setPreferredType(MediaType.movie);
    await tester.pump(); // the stream event
    await tester.pump(); // the rebuild it asks for
    expect(opacity(), 1);

    await tester.pump(const Duration(seconds: 3));
    expect(opacity(), 0);
  });

  testWidgets('Spanish titles', (tester) async {
    await _pump(tester, locale: const Locale('es'));

    expect(find.text('¿Qué sueles ver?'), findsOneWidget);
    expect(find.text('Ambas'), findsOneWidget);
    expect(find.text('Géneros que me gustan'), findsOneWidget);
    expect(find.text('Géneros que evito'), findsOneWidget);
    expect(find.text('Añadir'), findsOneWidget);
  });
}
