import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';

const _drama = Genre(id: 'drama');
const _horror = Genre(id: 'horror');

TasteProfile _profile({
  Set<Genre> likedGenres = const {},
  Set<Genre> vetoedGenres = const {},
  Set<String> likedVibes = const {},
  int yearFrom = 2000,
}) {
  return TasteProfile(
    likedGenres: likedGenres,
    vetoedGenres: vetoedGenres,
    likedVibes: likedVibes,
    yearFrom: yearFrom,
    updatedAt: DateTime(2024),
  );
}

void main() {
  group('TasteProfile.isUsableForSuggestions', () {
    test('a liked genre alone is enough', () {
      expect(_profile(likedGenres: {_drama}).isUsableForSuggestions, isTrue);
    });

    test('a liked vibe alone is enough', () {
      expect(_profile(likedVibes: {'cozy'}).isUsableForSuggestions, isTrue);
    });

    test('vetoed genres alone are not enough — a veto says nothing '
        'about what to suggest', () {
      expect(_profile(vetoedGenres: {_horror}).isUsableForSuggestions, isFalse);
    });

    test('yearFrom alone is never enough — every profile always has '
        'some value there', () {
      expect(_profile(yearFrom: 1950).isUsableForSuggestions, isFalse);
    });

    test('a profile with nothing at all is not usable', () {
      expect(_profile().isUsableForSuggestions, isFalse);
    });

    test('liked genres and vibes together are, unsurprisingly, usable', () {
      expect(
        _profile(
          likedGenres: {_drama},
          likedVibes: {'cozy'},
        ).isUsableForSuggestions,
        isTrue,
      );
    });
  });
}
