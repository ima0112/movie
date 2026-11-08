import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/tv_detail/presentation/widgets/season_episode_row.dart';

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
    testWidgets('shows the episode number and title together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      expect(find.text('1. Silence'), findsOneWidget);
    });

    testWidgets('an aired episode\'s date renders muted, not amber', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      final dateText = tester.widget<Text>(find.text('2020-01-01'));
      expect(dateText.style!.color, AppColors.inkMuted);
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
          home: Scaffold(body: SeasonEpisodeRow(episode: future)),
        ),
      );

      final dateFinder = find.textContaining('-');
      final dateText = tester.widget<Text>(dateFinder);
      expect(dateText.style!.color, AppColors.accent);
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
          home: Scaffold(body: SeasonEpisodeRow(episode: noDate)),
        ),
      );

      expect(find.text('TBA'), findsOneWidget);
    });

    testWidgets('synopsis starts folded and expands on "Read more"', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SeasonEpisodeRow(episode: _aired)),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(_aired.overview));
      expect(textWidget.maxLines, 2);
      expect(find.text('Read more'), findsOneWidget);

      await tester.tap(find.text('Read more'));
      await tester.pump();

      final expandedText = tester.widget<Text>(find.text(_aired.overview));
      expect(expandedText.maxLines, isNull);
      expect(find.text('Read more'), findsNothing);
    });
  });
}
