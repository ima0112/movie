import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_phone_frame.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_intro_slide.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_pager_dots.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _wrap({required Size size, required double textScale, Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 47, bottom: 34),
        textScaler: TextScaler.linear(textScale),
      ),
      child: OnboardingIntroSlide(
        headline: 'Encuentra qué ver\nen segundos',
        highlightWord: 'en segundos',
        body:
            'Explora el catálogo de TMDB. No es una app de streaming: te '
            'decimos dónde verlo.',
        visual: const IntroPhoneFrame(child: SizedBox.shrink()),
        activeDot: 1,
        onNext: () {},
        onSkip: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('lays out on a notch phone with no overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(390, 844),
        textScale: 1,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsNothing); // Spanish: "Siguiente"
    expect(find.text('Siguiente'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);
  });

  testWidgets('survives a small device at 200% text scale with no overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(320, 568),
        textScale: 2,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('the phone fades out to transparent over the glow (a mask), '
      'not under a solid fade that would leave a seam above the home '
      'indicator', (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(390, 844),
        textScale: 1,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    expect(mask.blendMode, BlendMode.dstIn);
    // And no solid-color gradient laid over the phone.
    final solidFades = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.gradient)
        .whereType<LinearGradient>()
        .where((g) => g.colors.last == const Color(0xFF0B0B0D));
    expect(solidFades, isEmpty);
  });

  testWidgets("the phone's glow is not cut at the top: only the bottom is "
      'clipped', (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(390, 844),
        textScale: 1,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    final clip = tester.widget<ClipRect>(
      find
          .ancestor(
            of: find.byType(ShaderMask),
            matching: find.byType(ClipRect),
          )
          .first,
    );
    final rect = clip.clipper!.getClip(const Size(390, 500));
    expect(rect.top, lessThan(0));
    expect(rect.left, lessThan(0));
    expect(rect.right, greaterThan(390));
    expect(rect.bottom, 500);
  });

  testWidgets('the button is the amber one, on the page margin, under the '
      'five dots with the right one active', (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(390, 844),
        textScale: 1,
        locale: const Locale('es'),
      ),
    );
    await tester.pump();

    expect(find.byType(AccentButton), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
    expect(tester.getRect(find.byType(AccentButton)).left, 20);
    expect(
      tester.getRect(find.byType(AccentButton)).right,
      tester.getSize(find.byType(Scaffold)).width - 20,
    );
    final dots = tester.widget<OnboardingPagerDots>(
      find.byType(OnboardingPagerDots),
    );
    expect(dots.count, 5);
    expect(dots.activeIndex, 1);
  });
}
