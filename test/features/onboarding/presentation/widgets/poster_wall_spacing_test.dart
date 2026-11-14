import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall_column.dart';

void main() {
  testWidgets('the horizontal gap between two adjacent columns equals the '
      'vertical gap between two cards in the same column — both come '
      'from the one AppSpacing.sm constant, so the spacing reads as '
      'uniform in every direction', (tester) async {
    final urls = List.generate(40, (i) => 'https://example.com/$i.jpg');
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 800,
          width: 400,
          child: PosterWall(posterUrls: urls),
        ),
      ),
    );
    await tester.pump();

    final column0 = find.byType(PosterWallColumn).at(0);
    final column1 = find.byType(PosterWallColumn).at(1);
    final horizontalGap =
        tester.getTopLeft(column1).dx - tester.getTopRight(column0).dx;

    final tilesInColumn0 = find.descendant(
      of: column0,
      matching: find.byType(ClipRRect),
    );
    final firstTileBottom = tester.getBottomLeft(tilesInColumn0.at(0)).dy;
    final secondTileTop = tester.getTopLeft(tilesInColumn0.at(1)).dy;
    final verticalGap = secondTileTop - firstTileBottom;

    expect(horizontalGap, closeTo(AppSpacing.sm, 0.5));
    expect(verticalGap, closeTo(AppSpacing.sm, 0.5));
    expect(horizontalGap, closeTo(verticalGap, 0.5));
  });
}
