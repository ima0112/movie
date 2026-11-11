import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';

/// Every app bar title is centered on the screen — from the theme, so no
/// screen has to repeat it, and the same on Android as on iOS.
void main() {
  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  test('the theme centers titles', () {
    expect(AppTheme.dark.appBarTheme.centerTitle, isTrue);
  });

  testWidgets(
    'a plain AppBar title is centered on Android and iOS, with or without '
    'actions',
    (tester) async {
      for (final actions in [
        const <Widget>[],
        [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ]) {
        await pump(
          tester,
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Top today'),
              actions: actions,
            ),
          ),
        );
        expect(tester.getCenter(find.text('Top today')).dx, closeTo(195, 1));
      }
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('the detail screens\' compact bar centers its title too, with '
      'or without Share', (tester) async {
    for (final share in [null, () {}]) {
      await pump(
        tester,
        Scaffold(
          body: MediaDetailCompactBar(title: 'Dune', onShare: share),
        ),
      );
      expect(tester.getCenter(find.text('Dune')).dx, closeTo(195, 1));
    }
  });
}
