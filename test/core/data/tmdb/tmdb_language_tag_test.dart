import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_language_tag.dart';

void main() {
  group('tmdbLanguageTag', () {
    test('en -> en-US', () {
      expect(tmdbLanguageTag('en', 'US'), 'en-US');
    });

    test('en with a non-US region still -> en-US', () {
      expect(tmdbLanguageTag('en', 'MX'), 'en-US');
    });

    test('es with ES -> es-ES', () {
      expect(tmdbLanguageTag('es', 'ES'), 'es-ES');
    });

    test('es with a Latin American region -> es-MX', () {
      expect(tmdbLanguageTag('es', 'MX'), 'es-MX');
      expect(tmdbLanguageTag('es', 'AR'), 'es-MX');
      expect(tmdbLanguageTag('es', 'CO'), 'es-MX');
    });

    test('es with neither Spain nor a recognized Latin American region '
        'falls back to es-ES', () {
      expect(tmdbLanguageTag('es', 'US'), 'es-ES');
    });

    test('an unrecognized language code falls back to en-US', () {
      expect(tmdbLanguageTag('fr', 'FR'), 'en-US');
    });
  });
}
