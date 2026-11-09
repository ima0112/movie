import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../app/cubits/user_profile_cubit.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/onboarding_repository.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_state.dart';

/// A2's own form state — `docs/SCREENS.md` A2.
///
/// Screen-local (CLAUDE.md rule 10): this Cubit's own draft (current
/// step, name, color, genre picks) has no meaning once onboarding
/// finishes or is abandoned — unlike [UserProfileCubit]/
/// [TasteProfileCubit], which outlive this screen and are read
/// elsewhere in the app. [finish] is the *only* place this Cubit
/// writes anywhere, and it writes through those two global Cubits
/// (and [OnboardingRepository]) rather than ever touching their
/// repositories directly — the same discipline `MyTastesCubit` already
/// follows for the taste profile specifically, applied here to both
/// profiles plus the onboarding flag.
///
/// Created wherever A2's own screen is (not in `di.config.dart` — only
/// repositories/services go there); that screen reads the two global
/// Cubits via `context.read` and `OnboardingRepository` via `getIt`,
/// the same way `EditProfileSheet` already reads `UserProfileCubit`.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(
    this._userProfileCubit,
    this._tasteProfileCubit,
    this._onboardingRepository,
  ) : super(const OnboardingState());

  final UserProfileCubit _userProfileCubit;
  final TasteProfileCubit _tasteProfileCubit;
  final OnboardingRepository _onboardingRepository;

  /// A brand-new taste profile's "how far back" default — A2 never
  /// asks for one (no year slider in its own 3 steps), so [finish]
  /// needs some value for [TasteProfile.yearFrom], a required field.
  /// Same 1990 `MyTastesState.defaultYearFrom` already uses, kept as
  /// its own constant rather than importing that presentation class
  /// across features just for one int.
  static const int _defaultYearFrom = 1990;

  void next() {
    final nextIndex = state.step.index + 1;
    if (nextIndex >= OnboardingStep.values.length) return;
    // Step 1 (name) is the one required step — `docs/SCREENS.md` A2:
    // "required, no 'Skip'" — so `next()` itself refuses to leave it
    // while invalid, the same guarantee the real screen's own disabled
    // "Next" button would give, just enforced here too so nothing can
    // bypass it.
    if (state.step == OnboardingStep.name && !state.isNameValid) return;
    emit(state.copyWith(step: OnboardingStep.values[nextIndex]));
  }

  /// "Skip" on either intro slide — jumps straight to the (required) name
  /// step. A no-op anywhere else.
  void skipIntro() {
    if (state.step != OnboardingStep.introDiscover &&
        state.step != OnboardingStep.introSurprise) {
      return;
    }
    emit(state.copyWith(step: OnboardingStep.name));
  }

  void back() {
    final previousIndex = state.step.index - 1;
    if (previousIndex < 0) return;
    emit(state.copyWith(step: OnboardingStep.values[previousIndex]));
  }

  /// Step 1's own name field. Validation is [OnboardingState
  /// .isNameValid]'s job (2–20 characters after trimming — this task's
  /// own instructions; `docs/SCREENS.md` A2 only ever specified the
  /// lower bound, "at least 2 characters"); this method just stores
  /// the raw, untrimmed value (trimming happens once, in [finish]) and
  /// auto-picks the first color preset the first time the field stops
  /// being empty — the same behavior `EditProfileSheet`'s own "Save"
  /// already falls back to, moved earlier here so the color preview
  /// A2's own step 1 shows ("typing reveals a circular initial and a
  /// 4-color picker") has something selected from the first keystroke.
  void setDisplayName(String name) {
    final shouldPickDefaultColor =
        name.trim().isNotEmpty && state.initialColor == null;
    emit(
      state.copyWith(
        displayName: name,
        initialColor: shouldPickDefaultColor
            ? AppColors.profileColors.first.toARGB32()
            : state.initialColor,
      ),
    );
  }

  void setInitialColor(int color) => emit(state.copyWith(initialColor: color));

  /// Step 2 — "Genres you like", mutually exclusive with vetoed
  /// (`docs/SCREENS.md` A2 step 3: genres picked here show at 30%
  /// opacity and don't respond to taps while picking "never" genres —
  /// enforced on the *data* here, same as `MyTastesCubit.
  /// toggleLikedGenre`'s own mutual exclusion, not just in the UI).
  void toggleLikedGenre(Genre genre) {
    final liked = _toggled(state.likedGenres, genre);
    final stillLiked = liked.contains(genre);
    final vetoed = stillLiked
        ? (Set<Genre>.of(state.vetoedGenres)..remove(genre))
        : state.vetoedGenres;
    emit(state.copyWith(likedGenres: liked, vetoedGenres: vetoed));
  }

  /// Step 3 — "And which ones never?", the same exclusivity the other
  /// way.
  void toggleVetoedGenre(Genre genre) {
    final vetoed = _toggled(state.vetoedGenres, genre);
    final stillVetoed = vetoed.contains(genre);
    final liked = stillVetoed
        ? (Set<Genre>.of(state.likedGenres)..remove(genre))
        : state.likedGenres;
    emit(state.copyWith(likedGenres: liked, vetoedGenres: vetoed));
  }

  /// A2's own finish line — `docs/SCREENS.md` A2: "Exits: B1, with a
  /// 'Tastes saved · Edit in You' snackbar if any genre was picked."
  /// Saves [UserProfile] (always — step 1 is required, so there's
  /// always a valid name/color by the time this can be called),
  /// [TasteProfile] only if at least one genre was picked either way
  /// (an all-empty [TasteProfile] would just be noise no screen asked
  /// for — C5/B1/the match engine's own "no taste profile yet" empty
  /// states are exactly for a user who skipped these steps, not a
  /// hollow saved one), then marks onboarding complete. Stops at the
  /// first failure, same short-circuit `MyTastesCubit`'s own write
  /// doesn't need (it never fails this visibly) but this one, running
  /// once and gating a flag, should.
  Future<Result<void>> finish() async {
    final profileResult = await _userProfileCubit.save(
      UserProfile(
        displayName: state.displayName.trim(),
        initialColor:
            state.initialColor ?? AppColors.profileColors.first.toARGB32(),
      ),
    );
    if (profileResult is Failure<void>) return profileResult;

    if (state.likedGenres.isNotEmpty || state.vetoedGenres.isNotEmpty) {
      final tasteResult = await _tasteProfileCubit.save(
        TasteProfile(
          likedGenres: state.likedGenres,
          vetoedGenres: state.vetoedGenres,
          likedVibes: const {},
          yearFrom: _defaultYearFrom,
          updatedAt: DateTime.now(),
        ),
      );
      if (tasteResult is Failure<void>) return tasteResult;
    }

    return _onboardingRepository.markCompleted();
  }

  static Set<T> _toggled<T>(Set<T> set, T value) {
    final next = Set<T>.of(set);
    if (!next.remove(value)) next.add(value);
    return next;
  }
}
