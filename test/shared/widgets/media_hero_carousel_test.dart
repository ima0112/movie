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

Finder _card(String title) =>
    find.byWidgetPredicate((w) => w is MediaCard && w.title == title);

void _phone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the banner in focus is centered and full size, with the '
      'previous and the next peeking in on both sides, smaller', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    final center = tester.getRect(_card('Movie 1'));
    expect(center.center.dx, moreOrLessEquals(390 / 2, epsilon: 1));
    expect(center.width, moreOrLessEquals(390 * 0.78, epsilon: 1));
    expect(center.height, MediaCardSize.hero.height);

    final next = tester.getRect(_card('Movie 2'));
    final previous = tester.getRect(_card('Movie 3')); // it loops
    expect(next.left, lessThan(390)); // part of it is on screen
    expect(previous.right, greaterThan(0));
    expect(next.left, greaterThan(center.right));
    expect(previous.right, lessThan(center.left));
    // Smaller (and so shorter), around the same middle.
    expect(next.width, lessThan(center.width));
    expect(next.height, lessThan(center.height));
    expect(next.width / center.width, moreOrLessEquals(0.88, epsilon: 0.01));
    expect(previous.width, moreOrLessEquals(next.width, epsilon: 1));
    expect(next.center.dy, moreOrLessEquals(center.center.dy, epsilon: 1));
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

  testWidgets('the zoom follows the finger: halfway between two banners both '
      'are in between', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));
    final full = tester.getRect(_card('Movie 1')).width;
    final small = tester.getRect(_card('Movie 2')).width;

    // Half a page to the left (page width = card + gap).
    final gesture = await tester.startGesture(
      tester.getCenter(_card('Movie 1')),
    );
    // The first move only gets past the touch slop; the second drags.
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    await gesture.moveBy(Offset(-(full + 12) / 2 + 30, 0));
    await tester.pump();

    final leaving = tester.getRect(_card('Movie 1')).width;
    final arriving = tester.getRect(_card('Movie 2')).width;
    expect(leaving, lessThan(full));
    expect(leaving, greaterThan(small));
    expect(arriving, greaterThan(small));
    expect(arriving, lessThan(full));

    await gesture.up();
    await tester.pumpAndSettle();
    // It snapped onto one banner, which is back to full size.
    final widths = [
      for (final t in ['Movie 1', 'Movie 2'])
        tester.getRect(_card(t).first).width,
    ];
    expect(
      widths.reduce((a, b) => a > b ? a : b),
      moreOrLessEquals(full, epsilon: 1),
    );
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

  testWidgets('tapping a neighbour opens its detail, like the banner in '
      'focus', (tester) async {
    _phone(tester);
    final tapped = <int>[];
    await tester.pumpWidget(
      _host([_movie(1), _movie(2), _movie(3)], onTap: (i) => tapped.add(i.id)),
    );

    final next = tester.getRect(_card('Movie 2'));
    // The part of it that is on screen.
    await tester.tapAt(Offset((next.left + 390) / 2, next.center.dy));
    await tester.pump();

    expect(tapped, [2]);
  });

  testWidgets('on a small phone the card narrows and the neighbours still '
      'show', (tester) async {
    _phone(tester, width: 320);
    await tester.pumpWidget(_host([_movie(1), _movie(2)]));

    final first = tester.getRect(_card('Movie 1'));
    expect(first.width, lessThan(MediaCardSize.hero.width));
    expect(first.center.dx, moreOrLessEquals(160, epsilon: 1));
    // With two banners the neighbour on each side is the other one.
    expect(
      [for (final e in _card('Movie 2').evaluate()) e]
          .map((e) => tester.getRect(find.byWidget(e.widget)).left)
          .any((left) => left < 320),
      isTrue,
    );
  });

  testWidgets('it loops: after the last banner the first comes back', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1), _movie(2), _movie(3)]));

    // Swipe forward three times (1 -> 2 -> 3 -> 1 again).
    for (var i = 0; i < 3; i++) {
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
    }

    // The card in the middle of the screen is Movie 1 again.
    final built = [
      for (final t in ['Movie 1', 'Movie 2', 'Movie 3'])
        if (_card(t).evaluate().isNotEmpty)
          MapEntry(t, tester.getRect(_card(t).first)),
    ];
    final centered = built.reduce(
      (a, b) =>
          (a.value.center.dx - 195).abs() < (b.value.center.dx - 195).abs()
          ? a
          : b,
    );
    expect(centered.key, 'Movie 1');
  });

  testWidgets('a single banner does not loop and is centered', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_movie(1)]));
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
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

    final title = tester.getCenter(find.text('Movie 1'));
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
