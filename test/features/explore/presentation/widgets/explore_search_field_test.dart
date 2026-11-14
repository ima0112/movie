import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/explore/presentation/widgets/explore_search_field.dart';
import 'package:movies/l10n/app_localizations.dart';

void main() {
  late FocusNode focus;

  setUp(() => focus = FocusNode());
  tearDown(() => focus.dispose());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ExploreSearchField(
            query: '',
            onChanged: (_) {},
            onClear: () {},
            onFilterTap: () {},
            focusNode: focus,
          ),
        ),
      ),
    ),
  );

  /// The border the field is drawing right now.
  InputBorder? drawnBorder(WidgetTester tester) {
    final decorator = tester.widget<InputDecorator>(
      find.descendant(
        of: find.byType(ExploreSearchField),
        matching: find.byType(InputDecorator),
      ),
    );
    final decoration = decorator.decoration;
    return decorator.isFocused
        ? decoration.focusedBorder
        : (decoration.enabledBorder ?? decoration.border);
  }

  testWidgets('at rest there is no ring; focused, a primary-color ring '
      'shows', (tester) async {
    await pump(tester);
    expect(drawnBorder(tester)!.borderSide.style, BorderStyle.none);

    focus.requestFocus();
    await tester.pump();

    final ring = drawnBorder(tester)!.borderSide;
    expect(ring.color, AppColors.accent);
    expect(ring.width, greaterThan(0));
    expect(ring.style, BorderStyle.solid);

    focus.unfocus();
    await tester.pump();
    expect(drawnBorder(tester)!.borderSide.style, BorderStyle.none);
  });

  testWidgets('focusing the field does not move or resize it', (tester) async {
    await pump(tester);
    final before = tester.getRect(find.byType(TextField));

    focus.requestFocus();
    await tester.pump();

    expect(tester.getRect(find.byType(TextField)), before);
  });
}
