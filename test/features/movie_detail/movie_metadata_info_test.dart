import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/movie_detail/presentation/widgets/movie_metadata.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/shared/widgets/media_detail/language_chip_label.dart';

MovieDetail _detail({
  String? language,
  List<String> countries = const [],
  int? runtime,
  String? certification,
  DateTime? release,
}) => MovieDetail(
  item: Movie(
    id: 1,
    title: 'T',
    posterUrl: null,
    genres: const [],
    releaseDate: release,
    voteAverage: 8,
  ),
  overview: '',
  cast: const [],
  crew: const [],
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: 'Released',
  watchProviders: WatchProviders.empty,
  originalLanguage: language,
  countryCodes: countries,
  runtimeMinutes: runtime,
  releaseDate: release,
  certification: certification,
);

void main() {
  final l10n = AppLocalizationsEn();

  test('languageChipLabel uppercases the code and drops empty ones', () {
    expect(languageChipLabel('en'), 'EN');
    expect(languageChipLabel(' fr '), 'FR');
    expect(languageChipLabel(''), isNull);
    expect(languageChipLabel(null), isNull);
  });

  test('movieMetaPrefix is "year · main country code"', () {
    expect(
      movieMetaPrefix(
        _detail(countries: ['US', 'GB'], release: DateTime(2010, 7, 16)),
      ),
      '2010 · US',
    );
    expect(movieMetaPrefix(_detail(release: DateTime(2010))), '2010');
    expect(movieMetaPrefix(_detail(countries: ['US'])), 'US');
  });

  test('movieInfoChips: language first, then runtime and certification', () {
    expect(
      movieInfoChips(
        _detail(language: 'en', runtime: 148, certification: 'PG-13'),
        l10n,
      ),
      ['EN', '2 h 28 min', 'PG-13'],
    );
    expect(movieInfoChips(_detail(), l10n), isEmpty);
  });
}
