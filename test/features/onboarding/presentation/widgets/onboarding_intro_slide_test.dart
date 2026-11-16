import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_badge.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_phone_frame.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_slide_specs.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_visual.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_intro_slide.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_pager_dots.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_buttons.dart';

const _sizes = <(String, Size)>[
  ('iPhone SE (320×568)', Size(320, 568)),
  ('small Android (360×640)', Size(360, 640)),
  ('iPhone 8 (375×667)', Size(375, 667)),
  ('iPhone 14 (390×844)', Size(390, 844)),
  ('large phone (430×932)', Size(430, 932)),
  ('tablet (768×1024)', Size(768, 1024)),
];

/// The real slide, in the real layout: [kind] of the two, in [locale].
Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required OnboardingIntroKind kind,
  String locale = 'en',
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final specs = introSlideSpecs(context);
          return OnboardingIntroSlide(
            spec: specs[kind.index],
            siblings: specs,
            onNext: () {},
            onSkip: () {},
          );
        },
      ),
    ),
  );
  await tester.pump();
}

Rect _frame(WidgetTester tester) =>
    tester.getRect(find.byType(IntroPhoneFrame));

void main() {
  group('the phone is at the same place on both slides', () {
    for (final (name, size) in _sizes) {
      for (final locale in ['en', 'es']) {
        for (final scale in [1.0, 1.3, 2.0]) {
          testWidgets('$name, $locale, text ×$scale', (tester) async {
            await _pump(
              tester,
              size: size,
              kind: OnboardingIntroKind.discover,
              locale: locale,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            final first = _frame(tester);
            final firstDots = tester
                .widget<OnboardingPagerDots>(find.byType(OnboardingPagerDots))
                .activeIndex;

            await _pump(
              tester,
              size: size,
              kind: OnboardingIntroKind.surprise,
              locale: locale,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            final second = _frame(tester);

            // Same top, same left, same size — a one-line headline must not
            // lift the phone above a two-line one.
            expect(second.top, moreOrLessEquals(first.top, epsilon: 0.01));
            expect(second.left, moreOrLessEquals(first.left, epsilon: 0.01));
            expect(second.width, moreOrLessEquals(first.width, epsilon: 0.01));
            // And the dots moved on.
            expect(
              tester
                  .widget<OnboardingPagerDots>(find.byType(OnboardingPagerDots))
                  .activeIndex,
              isNot(firstDots),
            );
          });
        }
      }
    }
  });

  group('on every screen size', () {
    for (final (name, size) in _sizes) {
      for (final kind in OnboardingIntroKind.values) {
        testWidgets('$name, ${kind.name}: the callouts stay on the screen, '
            'the phone ends above the button and is centered', (tester) async {
          await _pump(tester, size: size, kind: kind);

          final badges = find.byType(IntroBadge);
          expect(badges, findsWidgets);
          for (final e in badges.evaluate()) {
            final rect = tester.getRect(find.byWidget(e.widget));
            expect(rect.left, greaterThanOrEqualTo(-0.5), reason: 'left edge');
            expect(
              rect.right,
              lessThanOrEqualTo(size.width + 0.5),
              reason: 'right edge',
            );
          }

          // Centered.
          expect(
            _frame(tester).center.dx,
            moreOrLessEquals(size.width / 2, epsilon: 0.5),
          );
          // The picture's room ends where the button starts: nothing of the
          // phone shows behind or below the button.
          final room = tester.getRect(find.byType(IntroVisual));
          final button = tester.getRect(find.byType(AccentButton));
          expect(room.bottom, lessThanOrEqualTo(button.top + 0.5));
          // The button is on the page margin.
          expect(button.left, 20);
        });
      }
    }

    testWidgets('a narrow phone scales the picture down so the "Use my tastes" '
        'pill does not leave the screen (it stuck out 23 px at 320)', (
      tester,
    ) async {
      await _pump(
        tester,
        size: const Size(320, 568),
        kind: OnboardingIntroKind.surprise,
      );

      expect(_frame(tester).width, lessThan(IntroPhoneFrame.width));
      final pill = tester.getRect(find.byType(IntroBadge).first);
      expect(pill.left, greaterThanOrEqualTo(0));
    });

    testWidgets(
      'a large screen shows a larger phone, up to ${IntroVisual.maxScale}×',
      (tester) async {
        await _pump(
          tester,
          size: const Size(768, 1024),
          kind: OnboardingIntroKind.discover,
        );

        final width = _frame(tester).width;
        expect(width, greaterThan(IntroPhoneFrame.width));
        expect(
          width,
          lessThanOrEqualTo(IntroPhoneFrame.width * IntroVisual.maxScale + 0.5),
        );
      },
    );
  });

  group('IntroVisual.scaleFor', () {
    test('fits the width, including the callouts that stick out', () {
      expect(
        IntroVisual.scaleFor(320, 2000),
        moreOrLessEquals(320 / IntroVisual.naturalWidth),
      );
    });

    test('shrinks on a short room, never below the minimum, never above the '
        'maximum', () {
      expect(IntroVisual.scaleFor(400, 215), 0.6 > 215 / 430 ? 0.6 : 215 / 430);
      expect(IntroVisual.scaleFor(400, 50), IntroVisual.minScale);
      expect(IntroVisual.scaleFor(2000, 2000), IntroVisual.maxScale);
    });
  });

  group('the text block', () {
    testWidgets('reserves the room of the longest text of both slides, so '
        'the short headline does not pull the phone up', (tester) async {
      await _pump(
        tester,
        size: const Size(390, 844),
        kind: OnboardingIntroKind.surprise,
      );
      final context = tester.element(find.byType(OnboardingIntroSlide));
      final specs = introSlideSpecs(context);

      final both = OnboardingIntroSlide.reservedTextHeight(context, specs, 342);
      final onlyShort = OnboardingIntroSlide.reservedTextHeight(context, [
        specs[1],
      ], 342);
      final onlyLong = OnboardingIntroSlide.reservedTextHeight(context, [
        specs[0],
      ], 342);
      // It is the larger of the two, whichever that is (the test environment's
      // blocky font wraps both headlines alike, so they may even tie).
      expect(both, onlyLong > onlyShort ? onlyLong : onlyShort);
      expect(both, greaterThanOrEqualTo(onlyShort));
      expect(both, greaterThanOrEqualTo(onlyLong));
    });
  });

  group('the phone frame', () {
    testWidgets('keeps its amber stroke at the corners even over a full-bleed '
        'mock (the mock used to paint over it)', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: const IntroPhoneFrame(
                child: ColoredBox(color: Color(0xFFFF0000)),
              ),
            ),
          ),
        ),
      );

      final image = await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        return boundary.toImage();
      });
      final bytes = (await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      Color pixel(int x, int y) {
        final i = (y * image!.width + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      // The middle of the stroke at the top-left corner (45° on the arc).
      final p = pixel(12, 12);
      expect(p.r, greaterThan(p.g)); // not red-over-amber: amber has g > 0.5
      expect((p.g * 255).round(), greaterThan(100));
      expect(p.b * 255, lessThan(120));
      expect(AppColors.accent.g * 255, greaterThan(100));
    });
  });
}
