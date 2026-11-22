import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/theme/app_colors.dart';
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

Widget _host(
  List<MediaItem> items, {
  void Function(MediaItem)? onTap,
  bool reduceMotion = false,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: child!,
  ),
  home: Scaffold(
    body: ListView(
      children: [MediaHeroCarousel(items: items, onItemTap: onTap)],
    ),
  ),
);

/// The opacity the hero put on [title]'s card.
double _opacityOf(WidgetTester tester, Finder card) => tester
    .widget<Opacity>(
      find.ancestor(of: card, matching: find.byType(Opacity)).first,
    )
    .opacity;

/// The card at [index] of the loop: the first banner is 0, the next 1, and the
/// one before it -1 (with three banners that is the last one, which also
/// appears two places ahead).
Finder _at(int index) => find.descendant(
  of: find.byKey(ValueKey(index)),
  matching: find.byType(MediaCard),
);

Finder _card(String title) => switch (title) {
  'Movie 1' => _at(0),
  'Movie 2' => _at(1),
  'Movie 3' => _at(-1),
  _ => throw ArgumentError(title),
};

void _phone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The title of the card painted last (on top) in the hero's stack.
String _frontTitle(WidgetTester tester) {
  final stack = tester.widget<Stack>(
    find
        .descendant(
          of: find.byType(MediaHeroCarousel),
          matching: find.byType(Stack),
        )
        .first,
  );
  final top = stack.children.last;
  final card = find.descendant(
    of: find.byKey(top.key!),
    matching: find.byType(MediaCard),
  );
  return tester.widget<MediaCard>(card).title;
}

void main() {
  testWidgets('the banner in focus is big, centered and in front, with the '
      'previous and the next peeking out from behind it, smaller', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    final center = tester.getRect(_card('Movie 1'));
    expect(center.center.dx, moreOrLessEquals(390 / 2, epsilon: 1));
    expect(center.width, moreOrLessEquals(390 * 0.86, epsilon: 1));
    expect(center.height, MediaCardSize.hero.height);

    final next = tester.getRect(_card('Movie 2'));
    final previous = tester.getRect(_card('Movie 3')); // it loops
    // Only a sliver of each shows beyond the focused card, and it is cut by the
    // card in front (they overlap).
    expect(next.right, greaterThan(center.right));
    expect(next.left, lessThan(center.right));
    expect(previous.left, lessThan(center.left));
    expect(previous.right, greaterThan(center.left));
    // Smaller, and lower, behind.
    expect(next.width / center.width, moreOrLessEquals(0.8, epsilon: 0.01));
    expect(previous.width, moreOrLessEquals(next.width, epsilon: 1));
    expect(next.top, greaterThan(center.top));
    expect(_frontTitle(tester), 'Movie 1');
  });

  testWidgets('the neighbours are dimmer than the focused banner', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    expect(_opacityOf(tester, _card('Movie 1')), 1);
    expect(
      _opacityOf(tester, _card('Movie 2')),
      moreOrLessEquals(MediaHeroCarousel.neighborOpacity, epsilon: 0.01),
    );
  });

  testWidgets('swiping rotates them: the one behind grows and comes in front '
      'while the one in front shrinks and goes back, in step with the '
      'finger', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));
    final full = tester.getRect(_card('Movie 1')).width;
    final small = tester.getRect(_card('Movie 2')).width;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MediaHeroCarousel)),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-60, 0)); // a bit under half a place
    await tester.pump();

    var leaving = tester.getRect(_card('Movie 1')).width;
    var arriving = tester.getRect(_card('Movie 2')).width;
    expect(leaving, lessThan(full));
    expect(leaving, greaterThan(small));
    expect(arriving, greaterThan(small));
    expect(arriving, lessThan(full));
    expect(_frontTitle(tester), 'Movie 1');

    await gesture.moveBy(const Offset(-80, 0)); // past the middle
    await tester.pump();
    expect(_frontTitle(tester), 'Movie 2'); // it came in front

    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.getRect(_card('Movie 2')).width,
      moreOrLessEquals(full, epsilon: 1),
    );
    expect(_frontTitle(tester), 'Movie 2');
  });

  testWidgets('and the other way: swiping back brings the previous one to the '
      'front, over the one leaving', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MediaHeroCarousel)),
    );
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(150, 0)); // past the middle, to the right
    await tester.pump();
    expect(_frontTitle(tester), 'Movie 3'); // the previous, in front of Movie 1

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_frontTitle(tester), 'Movie 3');
  });

  testWidgets('with reduce motion on, every card stays at scale 1 (the '
      'dimming stays)', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _host([_movie(1), _movie(2), _movie(3)], reduceMotion: true),
    );

    expect(
      tester.getRect(_card('Movie 2')).width,
      moreOrLessEquals(tester.getRect(_card('Movie 1')).width, epsilon: 0.5),
    );
    expect(
      _opacityOf(tester, _card('Movie 2')),
      moreOrLessEquals(MediaHeroCarousel.neighborOpacity, epsilon: 0.01),
    );
  });

  testWidgets('tapping a neighbour (the part that shows) opens its detail, '
      'like the banner in focus', (tester) async {
    _phone(tester);
    final tapped = <int>[];
    await tester.pumpWidget(
      _host([_movie(1), _movie(2), _movie(3)], onTap: (i) => tapped.add(i.id)),
    );

    final center = tester.getRect(_card('Movie 1'));
    final next = tester.getRect(_card('Movie 2'));
    // The sliver of it beyond the focused card.
    await tester.tapAt(Offset((center.right + next.right) / 2, next.center.dy));
    await tester.pump();
    expect(tapped, [2]);

    tapped.clear();
    await tester.tapAt(center.center);
    await tester.pump();
    expect(tapped, [1]);
  });

  testWidgets('on a small phone the card narrows and the neighbours still '
      'show', (tester) async {
    _phone(tester, width: 320);
    await tester.pumpWidget(_host([_movie(1), _movie(2)]));

    final first = tester.getRect(_card('Movie 1'));
    expect(first.width, moreOrLessEquals(320 * 0.86, epsilon: 1));
    expect(first.center.dx, moreOrLessEquals(160, epsilon: 1));
    final other = tester.getRect(_card('Movie 2'));
    expect(other.right, greaterThan(first.right));
  });

  testWidgets('it loops: after the last banner the first comes back', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    // Swipe forward three times (1 -> 2 -> 3 -> 1 again).
    for (var i = 0; i < 3; i++) {
      await tester.fling(
        find.byType(MediaHeroCarousel),
        const Offset(-250, 0),
        1500,
      );
      await tester.pumpAndSettle();
    }
    expect(_frontTitle(tester), 'Movie 1');
  });

  testWidgets('a single banner does not loop and is centered', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1)]));
    await tester.fling(
      find.byType(MediaHeroCarousel),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(_card('Movie 1'), findsOneWidget);
    expect(
      tester.getRect(_card('Movie 1')).center.dx,
      moreOrLessEquals(195, epsilon: 1),
    );
  });

  testWidgets('the hero card is taller and its title is centered at the '
      'bottom', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2)]));

    final card = tester.getRect(_card('Movie 1'));
    expect(card.height, MediaCardSize.hero.height);
    expect(MediaCardSize.hero.height, greaterThan(290));

    final title = tester.getCenter(
      find.descendant(of: _at(0), matching: find.text('Movie 1')),
    );
    expect(title.dx, moreOrLessEquals(card.center.dx, epsilon: 1));
    // In the lower part of the card.
    expect(title.dy, greaterThan(card.top + card.height * 0.6));
  });

  testWidgets('the bottom fade is eased, practically opaque by 90% and the '
      'page black at the foot (it blends with the background)', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2)]));

    final gradient = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: _card('Movie 1'),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.gradient)
        .whereType<LinearGradient>()
        .first;

    final stops = gradient.stops!;
    final alphas = [for (final c in gradient.colors) c.a];
    // Transparent in the top third, then strictly darker down to the foot.
    expect(alphas.first, 0);
    expect(stops.first, greaterThanOrEqualTo(0.3));
    for (var i = 1; i < alphas.length; i++) {
      expect(alphas[i], greaterThan(alphas[i - 1]));
    }
    // Nearly opaque by 90%, and exactly the page's black at the very bottom.
    final at90 = alphas[stops.indexWhere((s) => s >= 0.9)];
    expect(at90, greaterThanOrEqualTo(0.95));
    expect(alphas.last, 1);
    expect(stops.last, 1);
    expect(gradient.colors.last.withValues(alpha: 1), AppColors.surface);
  });
}
