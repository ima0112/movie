import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_genre_step.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_vibe_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';

Widget _host(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Vibe _vibe(String id, String icon) => Vibe(
  id: id,
  icon: icon,
  movie: const VibeRule(genreIds: ['comedy'], keywordIds: []),
  tv: const VibeRule(genreIds: [], keywordIds: []),
);

List<ChipState> _states(WidgetTester tester) => [
  for (final c in tester.widgetList<AppChip>(find.byType(AppChip))) c.state,
];

void main() {
  group('QuizGenreStep', () {
    testWidgets('the headline with a red NOT, the subtitle and every genre '
        'as a chip — Music, War and Western included', (tester) async {
      await tester.pumpWidget(
        _host(QuizGenreStep(selected: const {}, onToggle: (_) {})),
      );

      expect(
        find.text('What are you NOT in the mood for today?'),
        findsOneWidget,
      );
      final spans =
          (tester.widget<Text>(find.byType(Text).first).textSpan! as TextSpan)
              .children!
              .cast<TextSpan>();
      expect(spans[1].text, 'NOT');
      expect(spans[1].style?.color, AppColors.danger);
      expect(find.text('Skip 1 to 3 genres'), findsOneWidget);
      expect(find.byType(AppChip), findsNWidgets(GenreCatalog.all.length));
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('War'), findsOneWidget);
      expect(find.text('Western'), findsOneWidget);
    });

    testWidgets('on TV the genres are the 16 TMDB has, with the combined '
        'ones named so', (tester) async {
      await tester.pumpWidget(
        _host(
          QuizGenreStep(
            selected: const {},
            mediaType: MediaType.tvShow,
            onToggle: (_) {},
          ),
        ),
      );

      expect(find.byType(AppChip), findsNWidgets(16));
      expect(find.text('Action & Adventure'), findsOneWidget);
      expect(find.text('Sci-Fi & Fantasy'), findsOneWidget);
      expect(find.text('Adventure'), findsNothing);
    });

    testWidgets('a vetoed genre is struck out and tapping toggles it', (
      tester,
    ) async {
      Genre? toggled;
      await tester.pumpWidget(
        _host(
          QuizGenreStep(
            selected: {const Genre(id: 'horror')},
            onToggle: (g) => toggled = g,
          ),
        ),
      );

      expect(_states(tester).where((s) => s == ChipState.vetoed), hasLength(1));
      await tester.tap(find.text('Horror'));
      expect(toggled, const Genre(id: 'horror'));
    });

    testWidgets('at the cap the rest dim and do nothing; a vetoed one still '
        'comes back out', (tester) async {
      final taps = <Genre>[];
      await tester.pumpWidget(
        _host(
          QuizGenreStep(
            selected: {
              const Genre(id: 'horror'),
              const Genre(id: 'action'),
              const Genre(id: 'comedy'),
            },
            onToggle: taps.add,
          ),
        ),
      );

      await tester.tap(find.text('Drama'));
      expect(taps, isEmpty);
      await tester.tap(find.text('Horror'));
      expect(taps, [const Genre(id: 'horror')]);
    });

    testWidgets('the Spanish copy', (tester) async {
      await tester.pumpWidget(
        _host(
          QuizGenreStep(selected: const {}, onToggle: (_) {}),
          locale: const Locale('es'),
        ),
      );

      expect(find.text('¿Qué NO te apetece hoy?'), findsOneWidget);
      expect(find.text('Descarta de 1 a 3 géneros'), findsOneWidget);
      expect(find.text('Música'), findsOneWidget);
    });
  });

  group('QuizVibeStep', () {
    final catalog = VibeCatalog([
      _vibe('feel_good', 'smile'),
      _vibe('monster', 'smile'),
      _vibe('superhero', 'smile'),
      _vibe('gritty', 'smile'),
    ]);

    testWidgets('headline with an amber "vibes", subtitle, a chip per vibe', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          QuizVibeStep(
            vibeCatalog: catalog,
            mediaType: MediaType.movie,
            selected: const {},
            onToggle: (_) {},
          ),
        ),
      );

      expect(
        find.text('Which vibes are you in the mood for today?'),
        findsOneWidget,
      );
      expect(find.text('Pick 1 to 3 vibes'), findsOneWidget);
      expect(find.byType(AppChip), findsNWidgets(4));
      expect(_states(tester).every((s) => s == ChipState.normal), isTrue);
    });

    testWidgets('chosen vibes are filled; at three the fourth does nothing', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _host(
          QuizVibeStep(
            vibeCatalog: catalog,
            mediaType: MediaType.movie,
            selected: const {'feel_good', 'monster', 'superhero'},
            onToggle: taps.add,
          ),
        ),
      );

      expect(_states(tester).where((s) => s == ChipState.solid), hasLength(3));
      // The fourth chip is the only dimmed one.
      expect(find.byType(Opacity), findsOneWidget);
      await tester.tap(find.byType(AppChip).at(3));
      expect(taps, isEmpty);
      await tester.tap(find.byType(AppChip).at(0));
      expect(taps, ['feel_good']);
    });
  });
}
