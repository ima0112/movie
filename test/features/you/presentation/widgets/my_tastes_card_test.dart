import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/features/you/presentation/widgets/my_tastes_card.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';

TasteProfile _profile({
  Set<String> genres = const {},
  Set<String> vibes = const {},
}) => TasteProfile(
  likedGenres: {for (final g in genres) Genre(id: g)},
  vetoedGenres: {const Genre(id: 'horror')},
  likedVibes: vibes,
  yearFrom: 1990,
  updatedAt: DateTime(2026),
);

void main() {
  final en = AppLocalizationsEn();

  group('summaryOf', () {
    test('two genres and the vibes', () {
      expect(
        MyTastesCard.summaryOf(
          _profile(genres: {'drama', 'sci-fi'}, vibes: {'a', 'b', 'c'}),
          en,
        ),
        'Drama, Science Fiction · 3 vibes',
      );
    });

    test('more than two genres: the first two (by id) and how many more', () {
      expect(
        MyTastesCard.summaryOf(
          _profile(
            genres: {'drama', 'sci-fi', 'crime', 'action'},
            vibes: {'a', 'b', 'c'},
          ),
          en,
        ),
        'Action, Crime +2 · 3 vibes',
      );
    });

    test('genres only, vibes only', () {
      expect(MyTastesCard.summaryOf(_profile(genres: {'drama'}), en), 'Drama');
      expect(MyTastesCard.summaryOf(_profile(vibes: {'a'}), en), '1 vibes');
    });

    test('nothing picked: the plain description', () {
      expect(
        MyTastesCard.summaryOf(_profile(), en),
        'Genres, vibes, platforms and more',
      );
    });

    test('Spanish', () {
      final es = AppLocalizationsEs();
      expect(
        MyTastesCard.summaryOf(
          _profile(genres: {'drama', 'sci-fi', 'crime'}, vibes: {'a', 'b'}),
          es,
        ),
        'Crimen, Drama +1 · 2 vibes',
      );
    });
  });
}
