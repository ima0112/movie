import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_avoided_genres_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_eras_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_footer.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_vibes_section.dart';
import 'package:movies/features/my_tastes/presentation/widgets/taste_liked_genres_section.dart';
import 'package:movies/l10n/app_localizations.dart';

final Map<String, dynamic> _vibes = {
  'vibes': [
    for (final (id, icon) in [
      ('feel_good', 'vibeFeelGood'),
      ('indie', 'vibeIndie'),
      ('monster', 'vibeMonster'),
      ('sports', 'vibeSports'),
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
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const TasteLikedGenresSection(),
                const TasteAvoidedGenresSection(),
                const TasteVibesSection(),
                TasteErasSection(library: InMemoryUserLibraryRepository()),
                const TasteFooter(),
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
  testWidgets('liked genres: tapping one picks it', (tester) async {
    final c = await _pump(tester);

    await tester.tap(find.text('Drama').first);
    await tester.pump();

    expect(c.tastes.state.likedGenres.map((g) => g.id), ['drama']);
    await _letSavedFade(tester);
  });

  testWidgets('avoided genres: every genre is listed on the page like the '
      'liked ones; tapping avoids it (struck through) and again takes it '
      'back', (tester) async {
    final c = await _pump(tester);
    expect(find.text('Genres you avoid'), findsOneWidget);
    // Each genre appears twice: once under "like", once under "avoid".
    expect(find.text('Horror'), findsNWidgets(2));
    expect(find.text('Add'), findsNothing);

    await tester.tap(find.text('Horror').last);
    await tester.pump();
    expect(c.tastes.state.vetoedGenres.map((g) => g.id), ['horror']);
    final struck = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          w.data == 'Horror' &&
          w.style?.decoration == TextDecoration.lineThrough,
    );
    expect(struck, findsOneWidget);

    await tester.tap(struck);
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

    await tester.tap(find.text('Horror').last);
    await tester.pump();

    expect(c.tastes.state.likedGenres, isEmpty);
    expect(c.tastes.state.vetoedGenres.map((g) => g.id), ['horror']);
    await _letSavedFade(tester);
  });

  testWidgets('the footer shows a discreet "Saved" after a change', (
    tester,
  ) async {
    final c = await _pump(tester);
    expect(find.textContaining('device'), findsNothing); // no note any more
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(TasteFooter),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(opacity(), 0);

    c.tastes.toggleLikedGenre(const Genre(id: 'drama'));
    await tester.pump(); // the stream event
    await tester.pump(); // the rebuild it asks for
    expect(opacity(), 1);

    await tester.pump(const Duration(seconds: 3));
    expect(opacity(), 0);
  });

  testWidgets('Spanish titles', (tester) async {
    await _pump(tester, locale: const Locale('es'));

    expect(find.text('¿Qué sueles ver?'), findsNothing); // gone
    expect(find.text('Géneros que me gustan'), findsOneWidget);
    expect(find.text('Géneros que evito'), findsOneWidget);
  });

  testWidgets('vibes: chips with their icons, up to 5; the sixth is dimmed '
      'and inert until one is dropped', (tester) async {
    final c = await _pump(tester);
    expect(find.text('Favorite vibes'), findsOneWidget);
    expect(
      find.text('Up to 5. They set the tone of what we suggest.'),
      findsOneWidget,
    );

    for (final id in ['feel_good', 'indie', 'monster', 'sports', 'classic']) {
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
    await tester.ensureVisible(find.text('Superhero'));
    await tester.tap(find.text('Superhero'));
    await tester.pump();
    expect(c.tastes.state.likedVibes.length, 5);

    // Dropping one frees it.
    await tester.ensureVisible(find.text('Feel Good'));
    await tester.tap(find.text('Feel Good'));
    await tester.pump();
    await tester.pump();
    await tester.ensureVisible(find.text('Superhero'));
    await tester.tap(find.text('Superhero'));
    await tester.pump();
    expect(c.tastes.state.likedVibes.contains('superhero'), isTrue);
    await _letSavedFade(tester);
  });

  testWidgets('eras: FROM / TO cards, presets, and the range saved as '
      'chosen — a range ending today is no upper bound', (tester) async {
    final c = await _pump(tester);
    final latest = DateTime.now().year;
    expect(find.text('Eras'), findsOneWidget);
    expect(find.text('Choose a release range'), findsOneWidget);
    expect(find.text('FROM'), findsOneWidget);
    expect(find.text('TO'), findsOneWidget);
    expect(find.text('1990'), findsOneWidget); // the default start
    expect(find.text('Today'), findsNWidgets(2)); // the TO card and the track

    await tester.ensureVisible(find.text('2010s'));
    await tester.tap(find.text('2010s'));
    await tester.pump();
    expect(c.tastes.state.yearFrom, 2010);
    expect(c.tastes.state.yearTo, 2019);

    await tester.tap(find.text('2020s'));
    await tester.pump();
    expect(c.tastes.state.yearFrom, 2020);
    expect(c.tastes.state.yearTo, isNull); // ends today

    await tester.tap(find.text('2000s'));
    await tester.pump();
    expect(c.tastes.state.yearFrom, 2000);
    expect(c.tastes.state.yearTo, 2009);

    await tester.tap(find.text('Earlier'));
    await tester.pump();
    expect(c.tastes.state.yearFrom, 1950);
    expect(c.tastes.state.yearTo, 1999); // before 2000

    await tester.tap(find.text('All').last); // the preset, not the segment
    await tester.pump();
    expect(c.tastes.state.yearFrom, 1950);
    expect(c.tastes.state.yearTo, isNull);
    expect(latest, greaterThan(2019));
    await _letSavedFade(tester);
  });

  testWidgets('eras: dragging a handle saves once, when the finger lifts', (
    tester,
  ) async {
    final c = await _pump(tester);
    final latest = DateTime.now().year;
    final saves = <Object?>[];
    c.profile.stream.listen(saves.add);
    await tester.ensureVisible(find.byType(RangeSlider));
    await tester.pump();
    // Where the left handle sits: 1990 on a 1950–today track, inset by the
    // slider's 24 px overlay padding.
    final rect = tester.getRect(find.byType(RangeSlider));
    final thumbX =
        rect.left + 24 + (1990 - 1950) / (latest - 1950) * (rect.width - 48);
    final gesture = await tester.startGesture(Offset(thumbX, rect.center.dy));
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
}
