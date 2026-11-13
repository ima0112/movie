import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/shared/widgets/profile_avatar.dart';
import 'package:movies/shared/widgets/profile_color_picker.dart';
import 'package:movies/shared/widgets/profile_name_field.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: child),
  ),
);

void main() {
  group('the profile colors', () {
    test('are six, amber first (the default): amber, mint, coral, blue, '
        'lilac, white', () {
      expect(AppColors.profileColors, [
        AppColors.profileAmber,
        AppColors.profileMint,
        AppColors.profileCoral,
        AppColors.profileBlue,
        AppColors.profileLilac,
        AppColors.profileWhite,
      ]);
    });
  });

  group('ProfileColorPicker', () {
    testWidgets('six circles on one row, a check only on the selected one', (
      tester,
    ) async {
      int? picked;
      await tester.pumpWidget(
        _host(
          ProfileColorPicker(
            selected: AppColors.profileMint.toARGB32(),
            onChanged: (c) => picked = c,
          ),
        ),
      );

      final circles = find.descendant(
        of: find.byType(ProfileColorPicker),
        matching: find.byType(GestureDetector),
      );
      expect(circles, findsNWidgets(6));
      expect(find.byIcon(AppIcons.check), findsOneWidget);
      final tops = {
        for (final e in circles.evaluate())
          tester.getTopLeft(find.byWidget(e.widget)).dy,
      };
      expect(tops, hasLength(1)); // one row

      await tester.tap(circles.at(2));
      expect(picked, AppColors.profileCoral.toARGB32());
    });

    for (final width in [320.0, 360.0, 430.0]) {
      testWidgets('at $width px the six fit the row without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _host(ProfileColorPicker(selected: null, onChanged: (_) {})),
        );

        expect(tester.takeException(), isNull);
        final circles = find.descendant(
          of: find.byType(ProfileColorPicker),
          matching: find.byType(GestureDetector),
        );
        final size = tester.getSize(circles.first);
        expect(size.width, inInclusiveRange(32, 48));
        expect(
          tester.getRect(circles.last).right,
          lessThanOrEqualTo(width - 20 + 0.5),
        );
      });
    }
  });

  group('ProfileAvatar', () {
    testWidgets('empty name: a person icon over the picked color (the mascot '
        'is gone)', (tester) async {
      await tester.pumpWidget(
        _host(
          ProfileAvatar(
            displayName: '',
            initialColor: AppColors.profileAmber.toARGB32(),
            size: 112,
          ),
        ),
      );

      expect(find.byIcon(AppIcons.user), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        AppColors.profileAmber,
      );
    });

    testWidgets('with a name: its initial, in capitals, over the color', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ProfileAvatar(
            displayName: 'daniel',
            initialColor: AppColors.profileMint.toARGB32(),
            size: 112,
          ),
        ),
      );

      expect(find.text('D'), findsOneWidget);
      expect(find.byIcon(AppIcons.user), findsNothing);
    });

    testWidgets('no color and no name: a quiet raised circle', (tester) async {
      await tester.pumpWidget(
        _host(const ProfileAvatar(displayName: null, initialColor: null)),
      );

      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        AppColors.surfaceRaised,
      );
    });
  });

  group('ProfileNameField', () {
    testWidgets('shows the hint and a 0/20 counter; it counts as you type '
        'and stops at 20', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          ProfileNameField(
            controller: controller,
            hint: 'Your name',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Your name'), findsOneWidget);
      expect(find.text('0/20'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Daniel');
      await tester.pump();
      expect(find.text('6/20'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'x' * 30);
      await tester.pump();
      expect(controller.text.length, 20);
      expect(find.text('20/20'), findsOneWidget);
    });

    testWidgets('an amber hairline at rest and the full amber when focused', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _host(
          ProfileNameField(
            controller: TextEditingController(),
            hint: 'Your name',
            onChanged: (_) {},
            focusNode: focus,
          ),
        ),
      );

      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide.color,
        AppColors.accentLine,
      );
      expect(
        (decoration.focusedBorder! as OutlineInputBorder).borderSide.color,
        AppColors.accent,
      );
    });
  });
}
