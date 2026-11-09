import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/intro_phone_frame.dart';
import 'package:movies/features/onboarding/presentation/widgets/onboarding_intro_slide.dart';
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
}
