import '../../../../core/domain/entities/genre.dart';

/// A2's own 4 screens — `docs/SCREENS.md` A2: "1 flow, 4 screens:
/// welcome + 3 steps."
enum OnboardingStep { welcome, name, likedGenres, vetoedGenres }

/// A2's own in-progress form — never saved anywhere until
/// `OnboardingCubit.finish()` is called; every field here is a draft.
///
/// Split from `onboarding_cubit.dart`, same as `MyTastesState`'s own
/// split from `my_tastes_cubit.dart` (CLAUDE.md rule 11).
class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.displayName = '',
    this.initialColor,
    this.likedGenres = const {},
    this.vetoedGenres = const {},
  });

  final OnboardingStep step;
  final String displayName;

  /// One of `AppColors.profileColors`' 4 presets, as a 32-bit ARGB int
  /// — same representation `UserProfile.initialColor` itself uses.
  /// `null` until [OnboardingCubit.setDisplayName] auto-picks the first
  /// preset, the same "no color ever picked → default to the first
  /// swatch" behavior `EditProfileSheet`'s own "Save" already has.
  final int? initialColor;

  final Set<Genre> likedGenres;
  final Set<Genre> vetoedGenres;

  /// Step 1's own "'Next' disabled until there are at least 2
  /// characters" (`docs/SCREENS.md` A2), with an upper bound this
  /// task's own instructions add beyond what that doc says — see
  /// `OnboardingCubit.setDisplayName`'s own doc comment.
  bool get isNameValid {
    final trimmed = displayName.trim();
    return trimmed.length >= 2 && trimmed.length <= 20;
  }

  // Never needs to *clear* initialColor back to null once set (there's
  // no "deselect a color" action anywhere in A2), so a plain `int?`
  // param — "provided and non-null" wins, otherwise keep the current
  // value — is enough; no need for the usual "sentinel function to
  // tell apart omitted from explicitly null" trick.
  OnboardingState copyWith({
    OnboardingStep? step,
    String? displayName,
    int? initialColor,
    Set<Genre>? likedGenres,
    Set<Genre>? vetoedGenres,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      displayName: displayName ?? this.displayName,
      initialColor: initialColor ?? this.initialColor,
      likedGenres: likedGenres ?? this.likedGenres,
      vetoedGenres: vetoedGenres ?? this.vetoedGenres,
    );
  }
}
