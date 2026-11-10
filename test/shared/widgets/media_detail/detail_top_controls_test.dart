import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/detail_top_controls.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';
import 'package:movies/shared/widgets/scrim_back_button.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('nothing is drawn until the title is known', (tester) async {
    final compact = ValueNotifier(false);
    addTearDown(compact.dispose);
    await tester.pumpWidget(
      _host(
        Stack(children: [DetailTopControls(showCompact: compact, title: null)]),
      ),
    );
    expect(find.byType(ScrimBackButton), findsNothing);
    expect(find.byType(MediaDetailCompactBar), findsNothing);
  });

  testWidgets('the circles give way to the compact bar (with Share) and back', (
    tester,
  ) async {
    final compact = ValueNotifier(false);
    addTearDown(compact.dispose);
    await tester.pumpWidget(
      _host(
        Stack(
          children: [
            DetailTopControls(
              showCompact: compact,
              title: 'Inception',
              onShare: () {},
            ),
          ],
        ),
      ),
    );
    expect(find.byType(ScrimBackButton), findsOneWidget);
    expect(find.byType(MediaDetailCompactBar), findsNothing);

    compact.value = true;
    await tester.pump();
    expect(find.byType(ScrimBackButton), findsNothing);
    expect(find.byType(MediaDetailCompactBar), findsOneWidget);
    expect(find.byIcon(AppIcons.share), findsOneWidget);

    compact.value = false;
    await tester.pump();
    expect(find.byType(ScrimBackButton), findsOneWidget);
  });
}
