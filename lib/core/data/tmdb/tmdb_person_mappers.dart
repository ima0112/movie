import '../../domain/entities/person.dart';
import 'dtos/tmdb_person_detail_dto.dart';
import 'tmdb_image_urls.dart';
import 'tmdb_mappers.dart';

/// `/person/{id}`'s own DTO → [PersonDetail] (D3).
PersonDetail personDetailFromDto(
  TmdbPersonDetailDto dto, {
  required TmdbImagesConfig imagesConfig,
}) {
  return PersonDetail(
    person: Person(
      id: dto.id,
      name: dto.name,
      profilePath: dto.profilePath,
      knownForDepartment: null,
    ),
    biography: dto.biography,
    birthday: parseTmdbDate(dto.birthday),
    deathday: parseTmdbDate(dto.deathday),
    placeOfBirth: dto.placeOfBirth,
    credits: [
      ...dto.movieCredits.cast.map(
        (m) => MediaCredit(
          item: mediaItemFromMovieDto(m, imagesConfig: imagesConfig),
          character: m.character,
        ),
      ),
      ...dto.movieCredits.crew.map(
        (m) => MediaCredit(
          item: mediaItemFromMovieDto(m, imagesConfig: imagesConfig),
          job: m.job,
        ),
      ),
      ...dto.tvCredits.cast.map(
        (t) => MediaCredit(
          item: mediaItemFromTvDto(t, imagesConfig: imagesConfig),
          character: t.character,
        ),
      ),
      ...dto.tvCredits.crew.map(
        (t) => MediaCredit(
          item: mediaItemFromTvDto(t, imagesConfig: imagesConfig),
          job: t.job,
        ),
      ),
    ],
  );
}
