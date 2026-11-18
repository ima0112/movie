import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/text/search_text.dart';

void main() {
  group('foldForSearch', () {
    test('drops accents and diacritics, lower-cases', () {
      expect(foldForSearch('José'), 'jose');
      expect(foldForSearch('ESPAÑA'), 'espana');
      expect(foldForSearch('Zoë Saldaña'), 'zoe saldana');
      expect(foldForSearch('Amélie'), 'amelie');
      expect(foldForSearch('Côte d’Ivoire'), 'cote d’ivoire');
      expect(foldForSearch('Åland Islands'), 'aland islands');
      expect(foldForSearch('Curaçao'), 'curacao');
      expect(foldForSearch('Łódź'), 'lodz');
      expect(foldForSearch('Müller-Lüdenscheid'), 'muller-ludenscheid');
    });

    test('special letters become their usual spelling', () {
      expect(foldForSearch('Straße'), 'strasse');
      expect(foldForSearch('Cœur'), 'coeur');
      expect(foldForSearch('Æon Flux'), 'aeon flux');
    });

    test('a combining accent typed on its own is dropped too', () {
      // "e" + U+0301 (combining acute), as some keyboards and pastes give it.
      expect(foldForSearch('José'), 'jose');
    });

    test('white space is collapsed and trimmed; other characters stay', () {
      expect(foldForSearch('  The   Lord  '), 'the lord');
      expect(foldForSearch('Spider-Man: 2'), 'spider-man: 2');
      expect(foldForSearch('東京'), '東京');
    });
  });

  group('matchesSearch / equalsSearch', () {
    test('an accentless query finds an accented name and the reverse', () {
      expect(matchesSearch('José Mota', 'jose'), isTrue);
      expect(matchesSearch('Jose Mota', 'josé'), isTrue);
      expect(matchesSearch('España', 'espana'), isTrue);
      expect(matchesSearch('Pelicula', 'película'), isTrue);
    });

    test('still a real match: a different word does not match', () {
      expect(matchesSearch('José Mota', 'maria'), isFalse);
      expect(matchesSearch('España', 'francia'), isFalse);
    });

    test('a blank query matches everything', () {
      expect(matchesSearch('anything', ''), isTrue);
      expect(matchesSearch('anything', '   '), isTrue);
    });

    test('equalsSearch ignores accents, case and extra space', () {
      expect(equalsSearch('Zoë Saldaña', '  zoe   saldana '), isTrue);
      expect(equalsSearch('Zoë Saldaña', 'zoe'), isFalse);
    });
  });
}
