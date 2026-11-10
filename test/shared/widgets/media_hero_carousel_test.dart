import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_card.dart';
import 'package:movies/shared/widgets/media_hero_carousel.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2020),
  voteAverage: 7,
);

Widget _host(List<MediaItem> items, {void Function(MediaItem)? onTap}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [MediaHeroCarousel(items: items, onItemTap: onTap)],
        ),
      ),
    );

Finder _card(String title) =>
    find.byWidgetPredicate((w) => w is MediaCard && w.title == title);

void _phone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the first card starts on the screen margin, a peek of the '
      'next one shows on the right', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    final first = tester.getRect(_card('Movie 1'));
    expect(first.left, 20);
    final second = tester.getRect(_card('Movie 2'));
    expect(second.left, greaterThan(first.right));
    expect(second.left, lessThan(390)); // part of it is on screen
  });

  testWidgets('on a small phone the card narrows and the peek stays', (
    tester,
  ) async {
    _phone(tester, width: 320);
    await tester.pumpWidget(_host([_movie(1), _movie(2)]));

    final first = tester.getRect(_card('Movie 1'));
    expect(first.width, lessThan(MediaCardSize.hero.width));
    expect(first.right, lessThan(320));
    expect(tester.getRect(_card('Movie 2')).left, lessThan(320));
  });

  testWidgets('it loops: after the last banner the first comes back', (
    tester,
  ) async {
    _phone(tester);
    final tapped = <int>[];
    await tester.pumpWidget(
      _host([_movie(1), _movie(2), _movie(3)], onTap: (i) => tapped.add(i.id)),
    );

    // Swipe forward three times (1 -> 2 -> 3 -> 1 again).
    for (var i = 0; i < 3; i++) {
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
    }

    // The card now in the first slot (the one nearest the left edge, among
    // those built) is Movie 1 again.
    final built = [
      for (final t in ['Movie 1', 'Movie 2', 'Movie 3'])
        if (_card(t).evaluate().isNotEmpty)
          MapEntry(t, tester.getRect(_card(t).first)),
    ];
    final leftmost = built.reduce(
      (a, b) => a.value.left.abs() < b.value.left.abs() ? a : b,
    );
    expect(leftmost.key, 'Movie 1');
  });

  testWidgets('a single banner does not loop', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1)]));
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(_card('Movie 1'), findsOneWidget);
    expect(tester.getRect(_card('Movie 1')).left, 20);
  });
}
