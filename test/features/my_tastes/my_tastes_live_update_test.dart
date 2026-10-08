import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/you/presentation/widgets/my_tastes_card.dart';
import 'package:movies/l10n/app_localizations.dart';

/// Minimal stand-in for [TasteProfileRepository] — one profile, no disk.
/// Same shape as `edit_profile_sheet_test.dart`'s own
/// `_InMemoryUserProfileRepository`.
class _InMemoryTasteProfileRepository implements TasteProfileRepository {
  TasteProfile? _profile;
  final _controller = StreamController<TasteProfile?>.broadcast();

  @override
  Stream<TasteProfile?> watch() async* {
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> save(TasteProfile profile) async {
    _profile = profile;
    _controller.add(profile);
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    _profile = null;
    _controller.add(null);
    return const Success(null);
  }
}

void main() {
  testWidgets(
    'toggling a genre through MyTastesCubit updates a separately-built '
    "MyTastesCard reading the same global TasteProfileCubit — the exact "
    'claim behind "changing tastes in C5 updates You\'s card without a '
    'reload" (Discover has no equivalent to check yet: it still has no '
    "way to read TasteProfile at all, per discover_hero.dart's own TODO)",
    (tester) async {
      final tasteProfileCubit = TasteProfileCubit(
        _InMemoryTasteProfileRepository(),
      );
      final vibeCatalog = VibeCatalog.fromJson(const {'vibes': []});
      final myTastesCubit = MyTastesCubit(tasteProfileCubit, vibeCatalog);

      await tester.pumpWidget(
        BlocProvider<TasteProfileCubit>.value(
          value: tasteProfileCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: MyTastesCard(onTap: () {})),
          ),
        ),
      );

      // No taste profile yet — MyTastesCard shows its own invitation
      // state, not a genre chip.
      expect(find.text('Build your taste profile'), findsOneWidget);

      const action = Genre(id: 'action');
      myTastesCubit.toggleLikedGenre(action);
      await tester.pumpAndSettle();

      // The card — built entirely separately, never given myTastesCubit
      // or the new profile directly — reflects the edit because both
      // sides read the *same* global TasteProfileCubit instance.
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Build your taste profile'), findsNothing);

      // Closed explicitly (not via addTearDown) so MyTastesCubit's own
      // "Saved" indicator Timer is canceled before this test body
      // returns — addTearDown callbacks run too late to satisfy
      // flutter_test's own "no pending timers" invariant check.
      await myTastesCubit.close();
      await tasteProfileCubit.close();
    },
  );
}
