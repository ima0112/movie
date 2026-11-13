import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/onboarding/presentation/widgets/name_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/profile_color_picker.dart';

Widget _wrap(Widget child, {String locale = 'en', MediaQueryData? media}) {
  return MaterialApp(
    theme: AppTheme.dark,
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: media == null ? child : MediaQuery(data: media, child: child),
  );
}

NameStep _step({
  String name = '',
  int? color,
  bool isValid = false,
  ValueChanged<String>? onName,
  ValueChanged<int>? onColor,
  VoidCallback? onNext,
}) => NameStep(
  name: name,
  initialColor: color ?? AppColors.profileAmber.toARGB32(),
  isValid: isValid,
  onNameChanged: onName ?? (_) {},
  onColorChanged: onColor ?? (_) {},
  onNext: onNext ?? () {},
);

void main() {
  testWidgets('empty: a large amber avatar with a person icon, the eyebrow, '
      'the headline, NAME/COLOR and a disabled Continue', (tester) async {
    await tester.pumpWidget(_wrap(_step()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(AppIcons.user), findsOneWidget);
    expect(find.text('YOUR PROFILE'), findsOneWidget);
    expect(find.textContaining('name', findRichText: true), findsWidgets);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('COLOR'), findsOneWidget);
    expect(find.text('0/20'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    // Six colors, a check on the amber one.
    expect(
      find.descendant(
        of: find.byType(ProfileColorPicker),
        matching: find.byType(GestureDetector),
      ),
      findsNWidgets(6),
    );
    expect(find.byIcon(AppIcons.check), findsOneWidget);
    // No Skip: the step is required.
    expect(find.text('Skip'), findsNothing);
    // Disabled button.
    final button = tester.widget<AccentButton>(find.byType(AccentButton));
    expect(button.isDisabled, isTrue);
    expect(button.onTap, isNull);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('with a name: the avatar shows its initial over the picked '
      'color, the counter counts and Continue is amber and live', (
    tester,
  ) async {
    var next = 0;
    await tester.pumpWidget(
      _wrap(
        _step(
          name: 'Daniel',
          color: AppColors.profileMint.toARGB32(),
          isValid: true,
          onNext: () => next++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(AppIcons.user), findsNothing);
    expect(find.text('D'), findsOneWidget);
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
      AppColors.profileMint,
    );
    expect(find.text('6/20'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    expect(next, 1);
  });

  testWidgets('typing reports the name; tapping a color reports it', (
    tester,
  ) async {
    final names = <String>[];
    final colors = <int>[];
    await tester.pumpWidget(
      _wrap(_step(onName: names.add, onColor: colors.add)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), 'Ana');
    expect(names, ['Ana']);

    await tester.tap(
      find
          .descendant(
            of: find.byType(ProfileColorPicker),
            matching: find.byType(GestureDetector),
          )
          .at(2),
    );
    expect(colors, [AppColors.profileCoral.toARGB32()]);
  });

  testWidgets('in Spanish: "TU PERFIL", "¿Cómo te llamas?" with "llamas" in '
      'amber, "NOMBRE" and "Continuar"', (tester) async {
    await tester.pumpWidget(_wrap(_step(), locale: 'es'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TU PERFIL'), findsOneWidget);
    expect(find.text('NOMBRE'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Tu nombre'), findsOneWidget);

    final headline = tester.widget<RichText>(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '¿Cómo te llamas?',
      ),
    );
    final spans = <TextSpan>[];
    headline.text.visitChildren((s) {
      if (s is TextSpan && s.text != null) spans.add(s);
      return true;
    });
    final amber = spans.singleWhere((s) => s.text == 'llamas');
    expect(amber.style?.color, AppColors.accent);
  });

  for (final (label, size, insets) in [
    (
      'a notch, the home indicator and the open keyboard',
      const Size(390, 844),
      const EdgeInsets.only(top: 47, bottom: 34),
    ),
    ('a small phone', const Size(320, 568), EdgeInsets.zero),
  ]) {
    testWidgets('survives $label with no overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _step(name: 'Dani', isValid: true),
          media: MediaQueryData(
            size: size,
            padding: insets,
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('survives 200% text scale on a small phone', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _step(name: 'Dani', isValid: true),
        media: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(2),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
