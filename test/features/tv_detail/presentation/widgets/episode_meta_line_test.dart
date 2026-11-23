import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_meta_line.dart';
import 'package:movies/l10n/app_localizations.dart';

Episode _ep({DateTime? date, int? runtime, double? rating}) => Episode(
  episodeNumber: 1,
  name: 'E',
  overview: '',
  stillPath: null,
  airDate: date,
  runtimeMinutes: runtime,
  voteAverage: rating,
);

Future<void> _pump(WidgetTester tester, Episode e, {int? maxLines = 1}) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EpisodeMetaLine(
            episode: e,
            style: const TextStyle(color: AppColors.inkMuted),
            starSize: 12,
            maxLines: maxLines,
          ),
        ),
      ),
    );

String _plain(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).textSpan!.toPlainText();

void main() {
  testWidgets('date, runtime and rating, with the star in amber', (
    tester,
  ) async {
    await _pump(
      tester,
      _ep(date: DateTime(2008, 1, 20), runtime: 59, rating: 8.9),
    );
    final text = _plain(tester);
    expect(text, contains('59 min'));
    expect(text, contains('8.9'));
    expect(
      tester.widget<Icon>(find.byIcon(AppIcons.starFill)).color,
      AppColors.accent,
    );
  });

  testWidgets('each unknown part is left out; no date says TBA', (
    tester,
  ) async {
    await _pump(tester, _ep());
    expect(_plain(tester).replaceAll('￼', ''), 'TBA');
    expect(find.byIcon(AppIcons.starFill), findsNothing);
  });

  testWidgets('a date still ahead is amber; maxLines null lets it wrap', (
    tester,
  ) async {
    await _pump(
      tester,
      _ep(date: DateTime.now().add(const Duration(days: 30))),
      maxLines: null,
    );
    final line = tester.widget<Text>(find.byType(Text));
    expect(line.maxLines, isNull);
    expect(
      ((line.textSpan! as TextSpan).children!.first as TextSpan).style!.color,
      AppColors.accent,
    );
  });
}
