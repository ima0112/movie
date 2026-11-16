import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_avoided_genres_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_eras_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_era_range.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_footer.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_vibes_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_liked_genres_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_type_section.dart';
import 'package:movies/l10n/app_localizations.dart';

final Map<String, dynamic> _vibes = {
  'vibes': [
    for (final (id, icon) in [
      ('feel_good', 'vibeFeelGood'),
      ('indie', 'vibeIndie'),
      ('monster', 'vibeMonster'),
      ('detective', 'vibeDetective'),
      ('classic', 'vibeClassic'),
      ('superhero', 'vibeSuperhero'),
    ])
      {
        'id': id,
        'icon': icon,
        'movie': {'genreIds': <String>[], 'keywordIds': <String>[]},
        'tv': {'genreIds': <String>[], 'keywordIds': <String>[]},
      },
  ],
};

Future<({MyTastesCubit tastes, TasteProfileCubit profile})> _pump(
  WidgetTester tester, {
  Locale? locale,
}) async {
  final profile = TasteProfileCubit(InMemoryTasteProfileRepository());
  final tastes = MyTastesCubit(profile, VibeCatalog.fromJson(_vibes));
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
                TasteVibesSection(),
                TasteErasSection(),
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

  testWidgets('vibes: chips with their icons, up to 5; the sixth is dimmed '
      'and inert until one is dropped', (tester) async {
    final c = await _pump(tester);
    expect(find.text('Favorite vibes'), findsOneWidget);
    expect(
      find.text('Up to 5. They set the tone of what we suggest.'),
      findsOneWidget,
    );

    for (final id in [
      'feel_good',
      'indie',
      'monster',
      'detective',
      'classic',
    ]) {
      c.tastes.toggleVibe(id);
    }
    await tester.pump();
    await tester.pump();

    // The sixth chip (Superhero) is dimmed...
    final sixth = find.ancestor(
      of: find.text('Superhero'),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(sixth.first).opacity, lessThan(1));
    // ...and tapping it picks nothing.
    await tester.tap(find.text('Superhero'));
    await tester.pump();
    expect(c.tastes.state.likedVibes.length, 5);

    // Dropping one frees it.
    await tester.tap(find.text('Feel Good'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Superhero'));
    await tester.pump();
    expect(c.tastes.state.likedVibes.contains('superhero'), isTrue);
    await _letSavedFade(tester);
  });

  testWidgets('eras: dragging a handle saves once, when the finger lifts; a '
      'range ending today is stored as no upper bound', (tester) async {
    final c = await _pump(tester);
    expect(find.text('Eras'), findsOneWidget);
    final latest = DateTime.now().year;
    expect(find.text('1990 – $latest'), findsOneWidget);

    final saves = <Object?>[];
    c.profile.stream.listen(saves.add);
    await tester.ensureVisible(find.byType(RangeSlider));
    await tester.pump();
    // Where the left handle sits: 1990 on a 1950–today track, inset by the
    // slider's 24 px overlay padding.
    final rect = tester.getRect(find.byType(RangeSlider));
    final thumbX =
        rect.left + 24 + (1990 - 1950) / (latest - 1950) * (rect.width - 48);
    final left = Offset(thumbX, rect.center.dy);
    final gesture = await tester.startGesture(left);
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    expect(saves, isEmpty); // nothing saved mid-drag
    await gesture.up();
    await tester.pump();
    await tester.pump();

    expect(c.tastes.state.yearFrom, greaterThan(1990));
    expect(c.tastes.state.yearTo, isNull); // still ends today
    await _letSavedFade(tester);
  });

  testWidgets('TasteEraRange alone: shows the span and the bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TasteEraRange(
            from: 2000,
            to: 2020,
            minYear: 1950,
            maxYear: 2026,
            onChanged: (_, _) {},
          ),
        ),
      ),
    );

    expect(find.text('2000 – 2020'), findsOneWidget);
    expect(find.text('1950'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
  });
}
