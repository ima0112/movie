import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/explore/presentation/widgets/explore_pill.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';
import 'package:movies/shared/widgets/genre_multi_select_chips.dart';
import 'package:movies/core/domain/entities/genre.dart';

/// One size for the pills that show genres, collections and vibes: the regular
/// chip is as tall as Explore's pills; only onboarding (and the bar of active
/// filters) use the compact one.
void main() {
  testWidgets('the regular chip is as tall as an Explore pill; the compact '
      'one is the small size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const AppChip(label: 'Comedy'),
              const AppChip(label: 'Comedy', compact: true),
              ExplorePill(label: 'Comedy', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    final chips = tester.widgetList<AppChip>(find.byType(AppChip)).toList();
    final regular = tester.getSize(find.byWidget(chips[0])).height;
    final compact = tester.getSize(find.byWidget(chips[1])).height;
    final pill = tester.getSize(find.byType(ExplorePill)).height;

    expect(regular, AppChip.regularHeight);
    expect(regular, pill);
    expect(compact, lessThan(regular));
  });

  testWidgets('genre chips are regular by default and compact on request '
      '(onboarding)', (tester) async {
    Future<double> heightOf({required bool compact}) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GenreMultiSelectChips(
              genres: const [Genre(id: 'comedy')],
              selected: const {},
              onToggle: (_) {},
              compact: compact,
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(AppChip)).height;
    }

    expect(await heightOf(compact: false), AppChip.regularHeight);
    expect(await heightOf(compact: true), lessThan(AppChip.regularHeight));
  });
}
