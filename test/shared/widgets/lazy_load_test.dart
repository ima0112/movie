import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/lazy_load.dart';

Widget _host(Widget child, {double height = 600}) => MaterialApp(
  home: Scaffold(
    body: SizedBox(height: height, child: child),
  ),
);

Widget _block(int i, List<int> fired, {Object? key, double height = 200}) =>
    LazyLoad(
      loadKey: key,
      distance: 100,
      onNear: () => fired.add(i),
      child: SizedBox(height: height, child: Text('Block $i')),
    );

void main() {
  testWidgets('only the blocks near the viewport fire, in a lazy list; '
      'scrolling brings the next ones', (tester) async {
    final fired = <int>[];
    await tester.pumpWidget(
      _host(
        ListView.builder(
          itemCount: 20,
          itemBuilder: (context, i) => _block(i, fired),
        ),
      ),
    );
    await tester.pump();

    // 600 px visible + 100 px lead = blocks 0..3 (0-200, 200-400, 400-600,
    // 600-800 start at 600 <= 700).
    expect(fired, [0, 1, 2, 3]);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();
    await tester.pump();
    expect(fired.toSet().containsAll([5, 6, 7, 8]), isTrue);
    expect(fired.contains(15), isFalse);
    // Each at most once.
    expect(fired.length, fired.toSet().length);
  });

  testWidgets('works in an eager Column too: far blocks wait for the '
      'scroll', (tester) async {
    final fired = <int>[];
    await tester.pumpWidget(
      _host(
        SingleChildScrollView(
          child: Column(
            children: [for (var i = 0; i < 12; i++) _block(i, fired)],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(fired, [0, 1, 2, 3]);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1000),
    );
    await tester.pump();
    await tester.pump();
    expect(fired.contains(8), isTrue);
    expect(fired.contains(11), isFalse);
  });

  testWidgets('a new loadKey fires again while near; the same key does not', (
    tester,
  ) async {
    final fired = <int>[];
    Widget build(Object key) =>
        _host(ListView(children: [_block(0, fired, key: key)]));

    await tester.pumpWidget(build('a'));
    await tester.pump();
    expect(fired, [0]);

    await tester.pumpWidget(build('a'));
    await tester.pump();
    expect(fired, [0]); // same key: no repeat

    await tester.pumpWidget(build('b'));
    await tester.pump();
    expect(fired, [0, 0]); // new key: again
  });

  testWidgets('a new key while far away waits until the block is near', (
    tester,
  ) async {
    final fired = <int>[];
    Widget build(Object key) => _host(
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 3000),
            _block(0, fired, key: key),
          ],
        ),
      ),
    );

    await tester.pumpWidget(build('a'));
    await tester.pump();
    expect(fired, isEmpty);

    await tester.pumpWidget(build('b'));
    await tester.pump();
    expect(fired, isEmpty);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2800),
    );
    await tester.pump();
    await tester.pump();
    expect(fired, [0]);
  });

  testWidgets('content above shrinking brings a block near with no scroll', (
    tester,
  ) async {
    final fired = <int>[];
    late StateSetter setTop;
    var topHeight = 3000.0;
    await tester.pumpWidget(
      _host(
        SingleChildScrollView(
          child: Column(
            children: [
              StatefulBuilder(
                builder: (context, set) {
                  setTop = set;
                  return SizedBox(height: topHeight);
                },
              ),
              _block(0, fired),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(fired, isEmpty);

    setTop(() => topHeight = 100);
    await tester.pump();
    await tester.pump();
    expect(fired, [0]);
  });

  testWidgets('with no scrollable around it fires at once', (tester) async {
    final fired = <int>[];
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: _block(0, fired))),
    );
    await tester.pump();
    expect(fired, [0]);
  });
}
