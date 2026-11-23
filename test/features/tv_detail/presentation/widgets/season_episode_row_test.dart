import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_text_styles.dart';
import 'package:movies/shared/widgets/outlined_text.dart';
import 'package:movies/features/tv_detail/presentation/widgets/season_episode_row.dart';
import 'package:movies/l10n/app_localizations.dart';

final _aired = Episode(
  episodeNumber: 1,
  name: 'Silence',
  overview:
      'A long synopsis that should be folded to just two lines until the '
      'reader taps "Read more" to see the rest of it spelled out in full.',
  stillPath: null,
  airDate: DateTime(2020, 1, 1),
  runtimeMinutes: 54,
);

void main() {
  group('SeasonEpisodeRow', () {
    testWidgets('shows the title, with the episode number big at the right', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      expect(find.text('Silence'), findsOneWidget);
      // The outlined "Top today" rank typography, at the right.
      final number = find.byType(OutlinedText);
      expect(number, findsOneWidget);
      expect(tester.widget<OutlinedText>(number).text, '01');
      expect(
        tester.widget<OutlinedText>(number).style,
        AppTextStyles.rankCompact,
      );
      expect(
        tester.getRect(number).left,
        greaterThan(tester.getRect(find.text('Silence')).right),
      );
      expect(find.byIcon(AppIcons.chevronRight), findsNothing);
    });

    testWidgets('an aired episode\'s date renders muted, not amber', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      final richText = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.textSpan?.toPlainText().contains('1 Jan, 2020') ?? false),
        ),
      );
      final line = richText.textSpan! as TextSpan;
      // The line is muted; the date doesn't override it (amber only if future).
      expect(line.style!.color, AppColors.inkMuted);
      expect((line.children!.first as TextSpan).style, isNull);
    });

    testWidgets('an episode airing in the future renders its date in '
        'amber', (tester) async {
      final future = Episode(
        episodeNumber: 2,
        name: 'Depth',
        overview: '',
        stillPath: null,
        airDate: DateTime.now().add(const Duration(days: 30)),
        runtimeMinutes: 50,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SeasonEpisodeRow(episode: future)),
        ),
      );

      final richText = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.textSpan?.toPlainText().contains(',') ?? false),
        ),
      );
      final dateSpan = (richText.textSpan! as TextSpan).children!.first;
      expect((dateSpan as TextSpan).style!.color, AppColors.accent);
    });

    testWidgets('an episode with no air date shows "TBA"', (tester) async {
      final noDate = Episode(
        episodeNumber: 3,
        name: 'Unknown',
        overview: '',
        stillPath: null,
        airDate: null,
        runtimeMinutes: null,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SeasonEpisodeRow(episode: noDate)),
        ),
      );

      expect(find.text('TBA'), findsOneWidget);
    });

    testWidgets('the synopsis is clipped to 1 line, with no inline Read more '
        '(the full text lives in the episode sheet)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(_aired.overview));
      expect(textWidget.maxLines, 1);
      expect(find.text('Read more'), findsNothing);
    });

    test('the number is two digits at least, and as is beyond that', () {
      expect(SeasonEpisodeRow.numberLabel(1), '01');
      expect(SeasonEpisodeRow.numberLabel(0), '00'); // a special
      expect(SeasonEpisodeRow.numberLabel(12), '12');
      expect(SeasonEpisodeRow.numberLabel(103), '103');
    });

    testWidgets('the meta line has date, runtime and rating; each part is '
        'left out when unknown', (tester) async {
      Future<String> meta(Episode e) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SeasonEpisodeRow(episode: e)),
          ),
        );
        return tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.textSpan?.toPlainText() ?? '')
            .firstWhere((t) => t.contains('2020') || t == 'TBA');
      }

      Episode ep({int? runtime, double? rating}) => Episode(
        episodeNumber: 1,
        name: 'E',
        overview: '',
        stillPath: null,
        airDate: DateTime(2020, 1, 1),
        runtimeMinutes: runtime,
        voteAverage: rating,
      );

      final full = await meta(ep(runtime: 59, rating: 8.9));
      expect(full, contains('59 min'));
      expect(full, contains('8.9'));
      final bare = await meta(ep());
      expect(bare, isNot(contains('min')));
      expect(bare, isNot(contains('·')));
      expect(find.byIcon(AppIcons.starFill), findsNothing);
    });

    testWidgets('a really small phone at 200% text: no overflow, the long '
        'title is cut with an ellipsis', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: SeasonEpisodeRow(
                episode: Episode(
                  episodeNumber: 103,
                  name: 'Un nombre de episodio larguísimo que no cabe',
                  overview: 'Una sinopsis larga que tampoco cabe en una línea.',
                  stillPath: null,
                  airDate: DateTime(2008, 1, 20),
                  runtimeMinutes: 59,
                  voteAverage: 8.9,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
