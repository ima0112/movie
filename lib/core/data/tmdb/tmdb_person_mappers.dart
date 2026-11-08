import '../../domain/entities/person.dart';
import 'dtos/tmdb_person_detail_dto.dart';
import 'tmdb_image_urls.dart';
import 'tmdb_mappers.dart';

/// `/person/{id}`'s own DTO → [PersonDetail] (D3).
///
/// [fallbackBiography] is a second, English-language fetch of the same
/// person — passed in only when [dto]'s own `biography` (fetched in the
/// user's language) came back empty, i.e. TMDB has no translation for
/// it. When that happens, [PersonDetail.biography] uses the fallback
/// instead and [PersonDetail.biographyIsEnglishFallback] is `true`, so
/// D3 can show its own "Biography in English" note.
PersonDetail personDetailFromDto(
  TmdbPersonDetailDto dto, {
  required TmdbImagesConfig imagesConfig,
  String? fallbackBiography,
}) {
  final usesFallback =
      dto.biography.isEmpty && (fallbackBiography ?? '').isNotEmpty;
  return PersonDetail(
    person: Person(
      id: dto.id,
      name: dto.name,
      profilePath: dto.profilePath,
      knownForDepartment: dto.knownForDepartment,
    ),
    biography: usesFallback ? fallbackBiography! : dto.biography,
    biographyIsEnglishFallback: usesFallback,
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
