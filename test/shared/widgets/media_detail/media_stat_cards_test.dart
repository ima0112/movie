import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
