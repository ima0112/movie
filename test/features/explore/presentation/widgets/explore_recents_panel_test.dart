import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/explore/domain/search_history_repository.dart';
import 'package:movies/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:movies/features/explore/presentation/cubit/explore_state.dart';
import 'package:movies/features/explore/presentation/widgets/explore_recents_panel.dart';
import 'package:movies/features/explore/presentation/widgets/recent_search_row.dart';
import 'package:movies/l10n/app_localizations.dart';

class _History implements SearchHistoryRepository {
  _History(this._items);

  List<String> _items;
  final _controller = StreamController<List<String>>.broadcast();

  @override
  Stream<List<String>> watch() async* {
    yield _items;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> record(String query) async => const Success(null);

  @override
  Future<Result<void>> remove(String query) async {
    _items = _items.where((q) => q != query).toList();
    _controller.add(_items);
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    _items = [];
    _controller.add(_items);
    return const Success(null);
  }
}

class _Settings implements SettingsRepository {
  final _current = const AppSettings(languageCode: 'en', regionCode: 'US');

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async => const Success(null);
}

void main() {
  late FocusNode focus;

  Future<ExploreCubit> pump(
    WidgetTester tester, {
    required List<String> recents,
    double height = 800,
    double bottomInset = 0,
  }) async {
    tester.view.physicalSize = Size(390, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // A fresh tree each time: a reused text field would hand its focus to the
    // new node.
    await tester.pumpWidget(const SizedBox.shrink());
    focus = FocusNode();
    addTearDown(focus.dispose);
    final cubit = ExploreCubit(
      FakeMediaRepository(),
      _History(recents),
      _Settings(),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          // What the root shell's floating tab bar adds to the body's bottom
          // padding.
          data: MediaQueryData(
            size: Size(390, height),
            padding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: SafeArea(
                bottom:
                    false, // as the screen: the tab bar's inset stays in the padding
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(focusNode: focus),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          const Column(
                            children: [
                              Text('SEGMENTED CONTROL'),
                              Expanded(child: SizedBox.expand()),
                            ],
                          ),
                          Positioned.fill(
                            child: ExploreRecentsPanel(searchFocus: focus),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return cubit;
  }

  Future<void> focusField(WidgetTester tester) async {
    focus.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  final many = [for (var i = 1; i <= 10; i++) 'search $i'];

  testWidgets('it only exists with a saved history and a focused field', (
    tester,
  ) async {
    await pump(tester, recents: const []);
    await focusField(tester);
    expect(find.text('RECENT'), findsNothing); // nothing saved: no panel

    await pump(tester, recents: ['dune']);
    expect(find.text('RECENT'), findsNothing); // not focused yet
    await focusField(tester);
    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('dune'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    focus.unfocus();
    await settle(tester);
    expect(find.text('RECENT'), findsNothing);
  });

  testWidgets('it drops from under the field, within the page margins', (
    tester,
  ) async {
    await pump(tester, recents: ['dune']);
    await focusField(tester);

    final field = tester.getRect(find.byType(TextField));
    final header = tester.getRect(find.text('RECENT'));
    expect(header.top, greaterThan(field.bottom));
    expect(header.left, greaterThan(20));
    expect(tester.getRect(find.byType(RecentSearchRow)).right, lessThan(390));
  });

  testWidgets('with many recents the header stays fixed while the rows '
      'scroll', (tester) async {
    await pump(tester, recents: many, height: 600);
    await focusField(tester);

    final headerBefore = tester.getTopLeft(find.text('RECENT'));
    final clearBefore = tester.getTopLeft(find.text('Clear all'));

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await settle(tester);

    expect(tester.getTopLeft(find.text('RECENT')), headerBefore);
    expect(tester.getTopLeft(find.text('Clear all')), clearBefore);
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, greaterThan(0)); // the rows moved
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await settle(tester);
    expect(find.text('search 10'), findsOneWidget); // the last is reachable
  });

  testWidgets('it has a fixed size — five and a half rows — however many '
      'searches there are, leaving page under it to tap', (tester) async {
    double panelBottom() {
      // The panel ends where its scrolling list ends.
      return tester.getRect(find.byType(ListView)).bottom;
    }

    const bar = 100.0;
    await pump(tester, recents: many, height: 900, bottomInset: bar);
    await focusField(tester);
    final tenRows = panelBottom();
    final header = tester.getTopLeft(find.text('RECENT')).dy;
    // Header + 5.5 rows: not the ten.
    expect(
      tenRows - header,
      lessThan(RecentSearchRow.height * (ExploreRecentsPanel.visibleRows + 1)),
    );
    // Plenty of dimmed page left under it, above the bar.
    expect(900 - bar - tenRows, greaterThan(ExploreRecentsPanel.minDimBelow));

    // Fewer searches than fit: only as tall as they are.
    await pump(tester, recents: ['a', 'b'], height: 900, bottomInset: bar);
    await focusField(tester);
    expect(panelBottom(), lessThan(tenRows));
  });

  testWidgets('a tap on the page just under the panel dismisses it', (
    tester,
  ) async {
    await pump(tester, recents: many, height: 900, bottomInset: 100);
    await focusField(tester);
    final under = tester.getRect(find.byType(ListView)).bottom + 40;

    await tester.tapAt(Offset(195, under));
    await settle(tester);

    expect(focus.hasFocus, isFalse);
    expect(find.text('RECENT'), findsNothing);
  });

  testWidgets('on a short screen it shrinks, still leaving the bar and room '
      'to tap', (tester) async {
    await pump(tester, recents: many, height: 480);
    await focusField(tester);
    expect(
      tester.getRect(find.byType(ListView)).bottom,
      lessThanOrEqualTo(480 - 16 - ExploreRecentsPanel.minDimBelow),
    );
  });

  testWidgets('the scrollbar is not inset by the floating bar: its thumb can '
      'reach the end of the list', (tester) async {
    await pump(tester, recents: many, height: 900, bottomInset: 100);
    await focusField(tester);
    await settle(tester);

    final scrollbar = tester.element(find.byType(Scrollbar));
    expect(MediaQuery.paddingOf(scrollbar).bottom, 0);
    expect(MediaQuery.paddingOf(scrollbar).top, 0);
  });

  testWidgets('the list has its own scroll controller, not the primary one the '
      'page behind is attached to (two positions would break the '
      'scrollbar)', (tester) async {
    await pump(tester, recents: many, height: 900);
    await focusField(tester);
    await settle(tester);

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(scrollbar.controller, isNotNull);
    expect(list.controller, same(scrollbar.controller));
    expect(
      scrollbar.controller,
      isNot(PrimaryScrollController.of(tester.element(find.byType(Scrollbar)))),
    );

    // Scrolling it raises nothing.
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the × removes a row; tapping a row runs that search', (
    tester,
  ) async {
    final cubit = await pump(tester, recents: ['dune', 'severance']);
    await focusField(tester);

    await tester.tap(find.byTooltip('Remove dune from recent searches'));
    await settle(tester);
    expect(find.text('dune'), findsNothing);
    expect(find.text('severance'), findsOneWidget);

    await tester.tap(find.text('severance'));
    await tester.pump();
    expect(cubit.state, isA<ExploreSearchLoading>());
    expect((cubit.state as ExploreSearchLoading).query, 'severance');
    await tester.pump(const Duration(seconds: 2)); // let the search settle
  });

  testWidgets('Clear all empties the panel; tapping the dim dismisses it', (
    tester,
  ) async {
    await pump(tester, recents: ['dune']);
    await focusField(tester);
    await tester.tap(find.text('Clear all'));
    await settle(tester);
    expect(find.text('RECENT'), findsNothing);

    await pump(tester, recents: ['dune']);
    await focusField(tester);
    // Below the panel is the dim: a tap there dismisses (and unfocuses).
    await tester.tapAt(const Offset(195, 700));
    await settle(tester);
    expect(focus.hasFocus, isFalse);
    expect(find.text('RECENT'), findsNothing);
  });

  testWidgets('it stops above the floating tab bar, however many recents '
      'there are, and still scrolls to the last one', (tester) async {
    const bar = 100.0; // the shell adds the bar's height to the padding
    await pump(tester, recents: many, height: 700, bottomInset: bar);
    await focusField(tester);

    final bottom = tester.getRect(find.byType(ListView)).bottom;
    expect(bottom, lessThanOrEqualTo(700 - bar - 16));

    // It does not grow past that: it scrolls to reach the rest.
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await settle(tester);
    expect(find.text('search 10'), findsOneWidget);
    expect(
      tester.getRect(find.byType(ListView)).bottom,
      lessThanOrEqualTo(700 - bar - 16),
    );
  });
}
