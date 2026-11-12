import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/media_detail/media_stat_cards.dart';

Widget _host(List<MediaStat> stats) => MaterialApp(
  home: MediaQuery(
    data: const MediaQueryData(
      size: Size(320, 568),
      textScaler: TextScaler.linear(2),
    ),
    child: Scaffold(body: MediaStatCards(stats: stats)),
  ),
);

void main() {
  testWidgets('lays two stats out side by side at 200% text on a small phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const [
        MediaStat(label: 'Duración', value: '2 h 46 min'),
        MediaStat(label: 'Clasificación', value: 'PG-13'),
      ]),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Duración'), findsOneWidget);
    expect(find.text('PG-13'), findsOneWidget);
  });

  testWidgets('no stats renders nothing', (tester) async {
    await tester.pumpWidget(_host(const []));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('a stat with onTap is a button with a chevron', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host([
        const MediaStat(label: 'Status', value: 'Ended'),
        MediaStat(
          label: 'Seasons',
          value: '5 · 62 episodes',
          onTap: () => taps++,
        ),
      ]),
    );

    expect(find.byIcon(AppIcons.chevronRight), findsOneWidget);
    await tester.tap(find.text('5 · 62 episodes'));
    expect(taps, 1);
  });

  testWidgets(
    'a value too long for its card ends in an ellipsis, on one line',
    (tester) async {
      await tester.pumpWidget(
        _host(const [
          MediaStat(label: 'Status', value: 'Airing'),
          MediaStat(label: 'Seasons', value: '12 · 1204 episodios más largos'),
        ]),
      );

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.textContaining('1204'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    },
  );
}
