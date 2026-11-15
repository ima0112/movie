import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/suggestion/presentation/widgets/choose_type_headline.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _host(Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(body: ChooseTypeHeadline()),
);

void main() {
  testWidgets('one sentence whose last word is amber', (tester) async {
    await tester.pumpWidget(_host(const Locale('en')));

    expect(find.text('What are you in the mood for today?'), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans[1].text, 'today');
    expect(spans[1].style?.color, AppColors.accent);
    expect(spans.last.text, '?');
    expect(spans.last.style, isNull); // the question mark stays white
  });

  testWidgets('the Spanish copy', (tester) async {
    await tester.pumpWidget(_host(const Locale('es')));

    expect(find.text('¿Qué te apetece ver hoy?'), findsOneWidget);
  });
}
