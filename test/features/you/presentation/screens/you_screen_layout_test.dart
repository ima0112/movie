import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/you/presentation/screens/you_screen.dart';
import 'package:movies/features/you/presentation/widgets/my_tastes_card.dart';
import 'package:movies/features/you/presentation/widgets/you_recently_watched.dart';
import 'package:movies/features/you/presentation/widgets/you_stats_card.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_card.dart';

void main() {
  setUpAll(() => configureDependencies(fake.name));

  Future<void> pump(WidgetTester tester) async {
    final library = InMemoryUserLibraryRepository();
    for (var i = 1; i <= 3; i++) {
      await library.upsert(
        UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: i),
          title: 'T$i',
          watchedAt: DateTime(2026, 11, i),
        ),
      );
    }
    getIt.unregister<UserLibraryRepository>();
    getIt.registerSingleton<UserLibraryRepository>(library);
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => UserProfileCubit(InMemoryUserProfileRepository()),
            ),
            BlocProvider(
              create: (_) =>
                  TasteProfileCubit(InMemoryTasteProfileRepository()),
            ),
          ],
          child: const YouScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('My Tastes comes before Recently watched, after the stats', (
    tester,
  ) async {
    await pump(tester);

    final stats = tester.getTopLeft(find.byType(YouStatsCard)).dy;
    final tastes = tester.getTopLeft(find.byType(MyTastesCard)).dy;
    final recent = tester.getTopLeft(find.byType(YouRecentlyWatched)).dy;
    expect(stats, lessThan(tastes));
    expect(tastes, lessThan(recent));
  });

  testWidgets('every block starts on the same page margin: the cards, the '
      '"Recently watched" heading and its first poster', (tester) async {
    await pump(tester);
    const margin = AppSpacing.screenMargin;

    expect(tester.getTopLeft(find.byType(YouStatsCard)).dx, margin);
    expect(tester.getTopLeft(find.byType(MyTastesCard)).dx, margin);
    expect(tester.getTopLeft(find.text('Recently watched')).dx, margin);
    expect(tester.getTopLeft(find.byType(MediaCard).first).dx, margin);
    // The cards run to the right margin too.
    expect(tester.getTopRight(find.byType(MyTastesCard)).dx, 390 - margin);
  });

  testWidgets('no taste profile: the My Tastes row is an invitation — the '
      'same one-row card, no mascot, no separate button', (tester) async {
    await pump(tester);

    expect(find.text('Build your taste profile'), findsOneWidget);
    expect(
      find.text('Get picks that actually match what you like.'),
      findsOneWidget,
    );
    expect(find.byIcon(AppIcons.favorite), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronRight), findsWidgets);
    expect(find.text('My Tastes'), findsNothing); // no button
  });

  testWidgets('the genres card is no longer on this page (Stats has it)', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('YOUR MOST-WATCHED GENRES'), findsNothing);
  });
}
