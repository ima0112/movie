import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_person_detail_dto.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';
import 'package:movies/core/data/tmdb/tmdb_person_mappers.dart';
import 'package:movies/core/domain/entities/media_item.dart';

void main() {
  test('personDetailFromDto maps biography, dates, and movie/tv credits '
      '(cast and crew)', () {
    final json =
        jsonDecode(
              File(
                'test/fixtures/tmdb_person_detail_full.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final dto = TmdbPersonDetailDto.fromJson(json);

    final detail = personDetailFromDto(
      dto,
      imagesConfig: const TmdbImagesConfig.fallback(),
    );

    expect(detail.person.name, 'Brad Pitt');
    expect(detail.biography, startsWith('William Bradley Pitt'));
    expect(detail.birthday, DateTime(1963, 12, 18));
    expect(detail.deathday, isNull);
    expect(detail.placeOfBirth, 'Shawnee, Oklahoma, USA');

    expect(detail.credits, hasLength(2));

    final castCredit = detail.credits.firstWhere((c) => c.character != null);
    expect(castCredit.item, isA<Movie>());
    expect(castCredit.item.title, 'Fight Club');
    expect(castCredit.character, 'Tyler Durden');
    expect(castCredit.job, isNull);

    final crewCredit = detail.credits.firstWhere((c) => c.job != null);
    expect(crewCredit.item.title, 'Killing Them Softly');
    expect(crewCredit.job, 'Producer');
    expect(crewCredit.character, isNull);
  });

  test('a person with no credits at all maps to an empty list, not a '
      'crash', () {
    final dto = TmdbPersonDetailDto.fromJson({
      'id': 1,
      'name': 'Nobody',
      'movie_credits': {'cast': [], 'crew': []},
      'tv_credits': {'cast': [], 'crew': []},
    });

    final detail = personDetailFromDto(
      dto,
      imagesConfig: const TmdbImagesConfig.fallback(),
    );

    expect(detail.credits, isEmpty);
    expect(detail.biography, isEmpty);
    expect(detail.birthday, isNull);
  });
}
