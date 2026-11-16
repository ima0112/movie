import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_cubit.dart';
import 'package:movies/features/my_tastes/presentation/cubit/my_tastes_state.dart';

const _drama = Genre(id: 'drama');
const _horror = Genre(id: 'horror');

({MyTastesCubit tastes, TasteProfileCubit profile}) _build() {
  final profile = TasteProfileCubit(InMemoryTasteProfileRepository());
  final tastes = MyTastesCubit(
    profile,
    VibeCatalog.fromJson(const {'vibes': []}),
  );
  addTearDown(() async {
    await tastes.close();
    await profile.close();
  });
  return (tastes: tastes, profile: profile);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('every edit saves through the global cubit (auto-save)', () async {
    final c = _build();

    c.tastes.toggleLikedGenre(_drama);
    await _settle();

    expect(c.profile.state!.likedGenres, {_drama});
  });

  test('liked and avoided genres exclude each other', () async {
    final c = _build();

    c.tastes.toggleLikedGenre(_horror);
    c.tastes.toggleVetoedGenre(_horror);
    await _settle();

    expect(c.tastes.state.likedGenres, isEmpty);
    expect(c.tastes.state.vetoedGenres, {_horror});
  });

  group('vibes: up to 5', () {
    test('a sixth is ignored; deselecting and re-picking works', () async {
      final c = _build();
      for (final id in ['a', 'b', 'c', 'd', 'e']) {
        c.tastes.toggleVibe(id);
      }

      c.tastes.toggleVibe('f');
      expect(c.tastes.state.likedVibes, {'a', 'b', 'c', 'd', 'e'});

      c.tastes.toggleVibe('a');
      c.tastes.toggleVibe('f');
      expect(c.tastes.state.likedVibes, {'b', 'c', 'd', 'e', 'f'});
    });
  });

  group('eras', () {
    test('a range ending today is kept as "no upper bound"', () async {
      final c = _build();

      c.tastes.setYearRange(1990, 2026, latestYear: 2026);
      await _settle();

      expect(c.profile.state!.yearFrom, 1990);
      expect(c.profile.state!.yearTo, isNull);
    });

    test('an earlier upper bound is stored', () async {
      final c = _build();

      c.tastes.setYearRange(1980, 2010, latestYear: 2026);
      await _settle();

      expect(c.profile.state!.yearTo, 2010);
      expect(c.tastes.state.yearTo, 2010);
    });
  });

  test('preferred type: a type, then back to both', () async {
    final c = _build();

    c.tastes.setPreferredType(MediaType.tvShow);
    await _settle();
    expect(c.profile.state!.preferredType, MediaType.tvShow);

    c.tastes.setPreferredType(null);
    await _settle();
    expect(c.profile.state!.preferredType, isNull);
  });

  test('platforms toggle on and off', () async {
    final c = _build();

    c.tastes.togglePlatform(8);
    c.tastes.togglePlatform(337);
    c.tastes.togglePlatform(8);
    await _settle();

    expect(c.profile.state!.platformIds, {337});
  });

  test('reset clears every selection, the new ones too', () async {
    final c = _build();
    c.tastes.toggleLikedGenre(_drama);
    c.tastes.setPreferredType(MediaType.movie);
    c.tastes.togglePlatform(8);
    c.tastes.setYearRange(1960, 2000, latestYear: 2026);

    c.tastes.reset();
    await _settle();

    final s = c.tastes.state;
    expect(s.likedGenres, isEmpty);
    expect(s.preferredType, isNull);
    expect(s.platformIds, isEmpty);
    expect(s.yearTo, isNull);
    expect(s.yearFrom, MyTastesState.defaultYearFrom);
  });

  test('the echo of our own save keeps the very same sets, so sections '
      'watching them do not rebuild', () async {
    final c = _build();
    c.tastes.toggleLikedGenre(_drama);
    final held = c.tastes.state.likedGenres;

    await _settle();
    await _settle();

    expect(identical(c.tastes.state.likedGenres, held), isTrue);
  });
}
