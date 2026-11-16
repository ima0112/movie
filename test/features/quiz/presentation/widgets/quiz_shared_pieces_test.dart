import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_platform_tile.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_progress_bar.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_top_bar.dart';
import 'package:movies/shared/widgets/accent_headline.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('AccentHeadline: one sentence, only the middle word coloured', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AccentHeadline(
          before: '¿Qué ',
          accent: 'NO',
          after: ' te apetece hoy?',
          accentColor: AppColors.danger,
        ),
      ),
    );

    expect(find.text('¿Qué NO te apetece hoy?'), findsOneWidget);
    final spans =
        ((tester.widget<Text>(find.byType(Text)).textSpan!) as TextSpan)
            .children!
            .cast<TextSpan>();
    expect(spans[1].text, 'NO');
    expect(spans[1].style?.color, AppColors.danger);
    expect(spans[0].style, isNull);
    expect(spans[2].style, isNull);
  });

  testWidgets('AccentHeadline is amber unless told otherwise', (tester) async {
    await tester.pumpWidget(
      _host(const AccentHeadline(before: 'a ', accent: 'b', after: ' c')),
    );

    final spans =
        ((tester.widget<Text>(find.byType(Text)).textSpan!) as TextSpan)
            .children!
            .cast<TextSpan>();
    expect(spans[1].style?.color, AppColors.accent);
  });

  testWidgets('QuizTopBar: back, and the icon of the kind of title', (
    tester,
  ) async {
    var backs = 0;
    await tester.pumpWidget(
      _host(QuizTopBar(mediaType: MediaType.movie, onBack: () => backs++)),
    );
    expect(find.byIcon(AppIcons.movie), findsOneWidget);
    await tester.tap(find.byIcon(AppIcons.back));
    expect(backs, 1);

    await tester.pumpWidget(
      _host(QuizTopBar(mediaType: MediaType.tvShow, onBack: () {})),
    );
    expect(find.byIcon(AppIcons.tvShow), findsOneWidget);
    expect(find.byIcon(AppIcons.movie), findsNothing);
  });

  testWidgets('QuizProgressBar: the steps reached are amber', (tester) async {
    await tester.pumpWidget(
      _host(const SizedBox(width: 300, child: QuizProgressBar(currentStep: 2))),
    );

    final colors = [
      for (final d in tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      ))
        (d.decoration as BoxDecoration).color,
    ];
    expect(colors, [
      AppColors.accent,
      AppColors.accent,
      AppColors.lineStrong,
      AppColors.lineStrong,
    ]);
  });

  group('QuizPlatformTile', () {
    const netflix = StreamingService(id: 8, name: 'Netflix');

    testWidgets('shows the name; a check only when selected; tap toggles', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 110,
            height: 100,
            child: QuizPlatformTile(
              service: netflix,
              selected: false,
              onTap: () => taps++,
            ),
          ),
        ),
      );

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.byIcon(AppIcons.check), findsNothing);
      await tester.tap(find.byType(QuizPlatformTile));
      expect(taps, 1);

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 110,
            height: 100,
            child: QuizPlatformTile(
              service: netflix,
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(AppIcons.check), findsOneWidget);
    });
  });
}
