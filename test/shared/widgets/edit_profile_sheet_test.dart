import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/user_profile.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/features/you/presentation/widgets/you_header.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/edit_profile_sheet.dart';
import 'package:movies/shared/widgets/profile_color_picker.dart';

/// Minimal stand-in for [UserProfileRepository] — one profile, no disk.
class _InMemoryUserProfileRepository implements UserProfileRepository {
  UserProfile? _profile;
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> watch() async* {
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> save(UserProfile profile) async {
    _profile = profile;
    _controller.add(profile);
    return const Success(null);
  }
}

/// The providers You's header needs: the global profile cubit (the one under
/// test) and the page's own stats cubit, over an empty library.
Widget _withStats(UserProfileCubit cubit, Widget child) => MultiBlocProvider(
  providers: [
    BlocProvider<UserProfileCubit>.value(value: cubit),
    BlocProvider(create: (_) => YouStatsCubit(InMemoryUserLibraryRepository())),
  ],
  child: child,
);

void main() {
  group('UserProfileCubit is genuinely global, not a per-screen copy', () {
    testWidgets(
      'saving from one YouHeader instance updates a second, unrelated '
      'one built from the same BlocProvider — the same wiring '
      "app/app.dart uses above MaterialApp.router (not each screen's own "
      'copy)',
      (tester) async {
        final cubit = UserProfileCubit(_InMemoryUserProfileRepository());
        addTearDown(cubit.close);

        await tester.pumpWidget(
          _withStats(
            cubit,
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Column(
                  children: [
                    YouHeader(onEditProfile: () {}, onOpenSettings: () {}),
                    YouHeader(onEditProfile: () {}, onOpenSettings: () {}),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Hi'), findsNWidgets(2));

        cubit.save(
          const UserProfile(displayName: 'Daniel', initialColor: 0xFFF2B441),
        );
        await tester.pumpAndSettle();

        // Both instances reflect the change — neither held its own
        // stale copy of the profile.
        expect(find.text('Hi, Daniel'), findsNWidgets(2));
      },
    );

    testWidgets("EditProfileSheet's Save reaches the same global Cubit a "
        "separately-built YouHeader reads — mirrors you_screen.dart's real "
        'flow (tap the header → open H10 → Save → the header behind it '
        'updates), not a value passed to the sheet by whoever opened it', (
      tester,
    ) async {
      final cubit = UserProfileCubit(_InMemoryUserProfileRepository());
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _withStats(
          cubit,
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    const YouHeader(
                      onEditProfile: _noop,
                      onOpenSettings: _noop,
                    ),
                    TextButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        // Matches you_screen.dart's real call — without
                        // this the sheet's default (roughly half-screen)
                        // height overflows its own content.
                        isScrollControlled: true,
                        builder: (_) => const EditProfileSheet(),
                      ),
                      child: const Text('Open H10'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hi'), findsOneWidget);

      await tester.tap(find.text('Open H10'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Daniel');
      await tester.pump();
      // A color swatch — scoped to ProfileColorPicker's own
      // GestureDetectors specifically, since PrimaryButton ("Save") uses
      // one internally too and a bare find.byType(GestureDetector) would
      // otherwise risk matching that instead.
      await tester.tap(
        find
            .descendant(
              of: find.byType(ProfileColorPicker),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Daniel'), findsOneWidget);
    });
  });
}

void _noop() {
  testWidgets('Cancel closes the sheet without saving anything', (
    tester,
  ) async {
    final repo = _InMemoryUserProfileRepository();
    final cubit = UserProfileCubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      _withStats(
        cubit,
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const EditProfileSheet(),
                ),
                child: const Text('Open H10'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open H10'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Daniel');
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing);
    expect(cubit.state, isNull);
  });
}
