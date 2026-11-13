import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/onboarding/presentation/widgets/genre_chips_step.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_pager_dots.dart';
import 'package:movies/features/onboarding/presentation/widgets/vetoed_genres_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/app_chip.dart';
import 'package:movies/shared/widgets/genre_multi_select_chips.dart';

const _action = Genre(id: 'action');
const _crime = Genre(id: 'crime');
const _horror = Genre(id: 'horror');

Widget _wrap(
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  String locale = 'en',
}) => MaterialApp(
  theme: AppTheme.dark,
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(
      size: size,
      padding: const EdgeInsets.only(top: 47, bottom: 34),
      textScaler: TextScaler.linear(textScale),
    ),
    child: child,
  ),
);

VetoedGenresStep _step({
  Set<Genre> selected = const {},
  Set<Genre> liked = const {},
  ValueChanged<Genre>? onToggle,
  VoidCallback? onFinish,
}) => VetoedGenresStep(
  selected: selected,
  liked: liked,
  onToggle: onToggle ?? (_) {},
  onFinish: onFinish ?? () {},
);

AppChip _chip(WidgetTester tester, String label) =>
    tester.widget<AppChip>(find.widgetWithText(AppChip, label));

void main() {
  testWidgets('the copy: HAZLA TUYA-style eyebrow, the headline with "never" '
      'in red, the body, "Skip" and "Get started"', (tester) async {
    await tester.pumpWidget(_wrap(_step()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MAKE IT YOURS'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(
      find.text(
        "Pick the ones you'd rather not see and we'll keep them out of your "
        'recommendations.',
      ),
      findsOneWidget,
    );

    final headline = tester.widget<RichText>(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == 'And which ones never?',
      ),
    );
    final spans = <TextSpan>[];
    headline.text.visitChildren((s) {
      if (s is TextSpan && s.text != null) spans.add(s);
      return true;
    });
    expect(
      spans.singleWhere((s) => s.text == 'never').style?.color,
      AppColors.danger,
    );
  });

  testWidgets('avoided genres are red and struck through, as in My Tastes', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_step(selected: {_horror})));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_chip(tester, 'Horror').state, ChipState.vetoed);
    expect(_chip(tester, 'Comedy').state, ChipState.normal);
    final label = tester.widget<Text>(find.text('Horror'));
    expect(label.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('the genres liked on the previous screen are dimmed and can '
      'not be tapped', (tester) async {
    final toggled = <Genre>[];
    await tester.pumpWidget(
      _wrap(_step(liked: {_crime}, onToggle: toggled.add)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final dimmed = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('Crime'), matching: find.byType(Opacity))
          .first,
    );
    expect(dimmed.opacity, GenreMultiSelectChips.disabledOpacity);

    await tester.tap(find.text('Crime'), warnIfMissed: false);
    expect(toggled, isEmpty);

    await tester.tap(find.text('Horror'));
    expect(toggled, [_horror]);
  });

  testWidgets('Skip and the amber "Get started" both finish the flow', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(_wrap(_step(onFinish: () => finished++)));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Skip'));
    await tester.tap(find.text('Get started'));
    expect(finished, 2);
    expect(find.byType(AccentButton), findsOneWidget);
  });

  testWidgets('the last of the five pagination dots is the active one', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_step()));
    await tester.pump(const Duration(milliseconds: 300));

    final dots = tester.widget<OnboardingPagerDots>(
      find.byType(OnboardingPagerDots),
    );
    expect(dots.count, 5);
    expect(dots.activeIndex, OnboardingPagerDots.vetoedDot);
  });

  testWidgets('the liked screen before it uses the same layout: its button is '
      '"Next" (it is no longer the last), amber chips, the fourth dot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        GenreChipsStep(
          selected: {_action},
          onToggle: (_) {},
          onSkip: () {},
          onNext: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    expect(_chip(tester, 'Action').state, ChipState.selected);
    expect(
      tester
          .widget<OnboardingPagerDots>(find.byType(OnboardingPagerDots))
          .activeIndex,
      OnboardingPagerDots.likedDot,
    );
  });

  for (final (label, size, scale) in [
    ('a small phone', const Size(320, 568), 1.0),
    ('200% text on a small phone', const Size(320, 568), 2.0),
    ('a notched phone', const Size(390, 844), 1.0),
  ]) {
    testWidgets('survives $label in English and Spanish with no overflow', (
      tester,
    ) async {
      for (final locale in ['en', 'es']) {
        await tester.pumpWidget(
          _wrap(
            _step(selected: {_horror}, liked: {_crime}),
            size: size,
            textScale: scale,
            locale: locale,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
