import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:movies/features/onboarding/presentation/cubit/onboarding_state.dart';

const _action = Genre(id: 'action');
const _comedy = Genre(id: 'comedy');

/// Minimal test double — no fake/real split exists for this repository
/// anywhere yet (nothing else needed one before this Cubit), so it
/// lives here rather than in `lib/`.
class _FakeUserProfileRepository implements UserProfileRepository {
  UserProfile? saved;
  bool shouldFail = false;
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> watch() => _controller.stream;

  @override
  Future<Result<void>> save(UserProfile profile) async {
    if (shouldFail) return const Failure(FailureReason.storage);
    saved = profile;
    _controller.add(profile);
    return const Success(null);
  }
}

class _FakeTasteProfileRepository implements TasteProfileRepository {
  TasteProfile? saved;
  bool shouldFail = false;
  final _controller = StreamController<TasteProfile?>.broadcast();

  @override
  Stream<TasteProfile?> watch() => _controller.stream;

  @override
  Future<Result<void>> save(TasteProfile profile) async {
    if (shouldFail) return const Failure(FailureReason.storage);
    saved = profile;
    _controller.add(profile);
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    saved = null;
    _controller.add(null);
    return const Success(null);
  }
}

void main() {
  late _FakeUserProfileRepository userProfileRepository;
  late _FakeTasteProfileRepository tasteProfileRepository;
  late InMemoryOnboardingRepository onboardingRepository;
  late UserProfileCubit userProfileCubit;
  late TasteProfileCubit tasteProfileCubit;
  late OnboardingCubit cubit;

  setUp(() {
    userProfileRepository = _FakeUserProfileRepository();
    tasteProfileRepository = _FakeTasteProfileRepository();
    onboardingRepository = InMemoryOnboardingRepository(isCompleted: false);
    userProfileCubit = UserProfileCubit(userProfileRepository);
    tasteProfileCubit = TasteProfileCubit(tasteProfileRepository);
    cubit = OnboardingCubit(
      userProfileCubit,
      tasteProfileCubit,
      onboardingRepository,
    );
  });

  tearDown(() {
    cubit.close();
    userProfileCubit.close();
    tasteProfileCubit.close();
  });

  group('OnboardingCubit validation', () {
    test('empty name is invalid', () {
      cubit.setDisplayName('');
      expect(cubit.state.isNameValid, isFalse);
    });

    test('a single character is too short', () {
      cubit.setDisplayName('A');
      expect(cubit.state.isNameValid, isFalse);
    });

    test('exactly 2 characters is valid (the documented lower bound)', () {
      cubit.setDisplayName('Al');
      expect(cubit.state.isNameValid, isTrue);
    });

    test('exactly 20 characters is valid (the upper bound)', () {
      cubit.setDisplayName('A' * 20);
      expect(cubit.state.isNameValid, isTrue);
    });

    test('21 characters is too long', () {
      cubit.setDisplayName('A' * 21);
      expect(cubit.state.isNameValid, isFalse);
    });

    test('surrounding whitespace is trimmed before counting', () {
      cubit.setDisplayName('  Al  ');
      expect(cubit.state.isNameValid, isTrue);

      cubit.setDisplayName('  A  ');
      expect(cubit.state.isNameValid, isFalse);
    });

    test('next() refuses to leave the name step while invalid', () {
      cubit.next(); // welcome -> introDiscover
      cubit.next(); // -> introSurprise
      cubit.next(); // -> name
      expect(cubit.state.step, OnboardingStep.name);

      cubit.setDisplayName('A');
      cubit.next();
      expect(cubit.state.step, OnboardingStep.name);

      cubit.setDisplayName('Al');
      cubit.next();
      expect(cubit.state.step, OnboardingStep.likedGenres);
    });

    test('welcome leads through both intro slides to the name step', () {
      expect(cubit.state.step, OnboardingStep.welcome);
      cubit.next();
      expect(cubit.state.step, OnboardingStep.introDiscover);
      cubit.next();
      expect(cubit.state.step, OnboardingStep.introSurprise);
      cubit.next();
      expect(cubit.state.step, OnboardingStep.name);
    });

    test('skipIntro() jumps from the first slide to the name step', () {
      cubit.next(); // introDiscover
      cubit.skipIntro();
      expect(cubit.state.step, OnboardingStep.name);
    });

    test('skipIntro() jumps from the second slide to the name step', () {
      cubit.next();
      cubit.next(); // introSurprise
      cubit.skipIntro();
      expect(cubit.state.step, OnboardingStep.name);
    });

    test('skipIntro() does nothing outside the intro slides', () {
      cubit.skipIntro(); // welcome
      expect(cubit.state.step, OnboardingStep.welcome);
    });

    test('typing a first character auto-picks a color preset', () {
      expect(cubit.state.initialColor, isNull);

      cubit.setDisplayName('A');

      expect(cubit.state.initialColor, isNotNull);
    });

    test("a color, once picked, isn't overridden by further typing", () {
      cubit.setInitialColor(0xFFFF6B6B);
      cubit.setDisplayName('Alex');

      expect(cubit.state.initialColor, 0xFFFF6B6B);
    });
  });

  group('OnboardingCubit mutual exclusion', () {
    test('liking a genre clears it from vetoed if it was there', () {
      cubit.toggleVetoedGenre(_action);
      expect(cubit.state.vetoedGenres, {_action});

      cubit.toggleLikedGenre(_action);

      expect(cubit.state.likedGenres, {_action});
      expect(cubit.state.vetoedGenres, isEmpty);
    });

    test('vetoing a genre clears it from liked if it was there', () {
      cubit.toggleLikedGenre(_comedy);
      expect(cubit.state.likedGenres, {_comedy});

      cubit.toggleVetoedGenre(_comedy);

      expect(cubit.state.vetoedGenres, {_comedy});
      expect(cubit.state.likedGenres, isEmpty);
    });

    test('toggling the same genre twice deselects it, leaving the '
        'other set untouched', () {
      cubit.toggleLikedGenre(_action);
      cubit.toggleVetoedGenre(_comedy);

      cubit.toggleLikedGenre(_action);

      expect(cubit.state.likedGenres, isEmpty);
      expect(cubit.state.vetoedGenres, {_comedy});
    });

    test('liked and vetoed can hold different genres at once', () {
      cubit.toggleLikedGenre(_action);
      cubit.toggleVetoedGenre(_comedy);

      expect(cubit.state.likedGenres, {_action});
      expect(cubit.state.vetoedGenres, {_comedy});
    });
  });

  group('OnboardingCubit.finish', () {
    test('saves the profile, trimmed, with the auto-picked color', () async {
      cubit.setDisplayName('  Dani  ');

      await cubit.finish();

      expect(userProfileRepository.saved!.displayName, 'Dani');
      expect(userProfileRepository.saved!.initialColor, isNotNull);
    });

    test('skips the taste profile entirely when no genre was picked', () async {
      cubit.setDisplayName('Dani');

      await cubit.finish();

      expect(tasteProfileRepository.saved, isNull);
    });

    test('saves a taste profile once at least one genre was picked, '
        'with no vibes and the default yearFrom', () async {
      cubit.setDisplayName('Dani');
      cubit.toggleLikedGenre(_action);

      await cubit.finish();

      final saved = tasteProfileRepository.saved!;
      expect(saved.likedGenres, {_action});
      expect(saved.vetoedGenres, isEmpty);
      expect(saved.likedVibes, isEmpty);
      expect(saved.yearFrom, 1990);
    });

    test('a vetoed-only pick (nothing liked) still counts as "picked '
        'something"', () async {
      cubit.setDisplayName('Dani');
      cubit.toggleVetoedGenre(_comedy);

      await cubit.finish();

      expect(tasteProfileRepository.saved, isNotNull);
    });

    test('marks onboarding completed once every save succeeds', () async {
      cubit.setDisplayName('Dani');

      await cubit.finish();

      expect(onboardingRepository.isCompleted, isTrue);
    });

    test('a failed profile save short-circuits: no taste save, no '
        'completed flag', () async {
      userProfileRepository.shouldFail = true;
      cubit.setDisplayName('Dani');
      cubit.toggleLikedGenre(_action);

      final result = await cubit.finish();

      expect(result, isA<Failure<void>>());
      expect(tasteProfileRepository.saved, isNull);
      expect(onboardingRepository.isCompleted, isFalse);
    });

    test('a failed taste-profile save short-circuits before marking '
        'completed', () async {
      tasteProfileRepository.shouldFail = true;
      cubit.setDisplayName('Dani');
      cubit.toggleLikedGenre(_action);

      final result = await cubit.finish();

      expect(result, isA<Failure<void>>());
      expect(onboardingRepository.isCompleted, isFalse);
    });
  });
}
