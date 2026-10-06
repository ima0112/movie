// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_movie_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbMovieDetailDto _$TmdbMovieDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbMovieDetailDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      genres: (json['genres'] as List<dynamic>)
          .map((e) => TmdbGenreRefDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      runtime: (json['runtime'] as num?)?.toInt(),
      tagline: json['tagline'] as String?,
      status: json['status'] as String,
      imdbId: json['imdb_id'] as String?,
      credits: TmdbCreditsDto.fromJson(json['credits'] as Map<String, dynamic>),
      videos: TmdbVideosDto.fromJson(json['videos'] as Map<String, dynamic>),
      similar: TmdbPagedResponseDto<TmdbMovieListItemDto>.fromJson(
        json['similar'] as Map<String, dynamic>,
        (value) => TmdbMovieListItemDto.fromJson(value as Map<String, dynamic>),
      ),
      releaseDates: TmdbReleaseDatesDto.fromJson(
        json['release_dates'] as Map<String, dynamic>,
      ),
      watchProviders: TmdbWatchProvidersDto.fromJson(
        json['watch/providers'] as Map<String, dynamic>,
      ),
    );

TmdbReleaseDatesDto _$TmdbReleaseDatesDtoFromJson(Map<String, dynamic> json) =>
    TmdbReleaseDatesDto(
      results: (json['results'] as List<dynamic>)
          .map(
            (e) =>
                TmdbReleaseDatesRegionDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

TmdbReleaseDatesRegionDto _$TmdbReleaseDatesRegionDtoFromJson(
  Map<String, dynamic> json,
) => TmdbReleaseDatesRegionDto(
  iso31661: json['iso_3166_1'] as String,
  releaseDates: (json['release_dates'] as List<dynamic>)
      .map((e) => TmdbReleaseDateEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

TmdbReleaseDateEntryDto _$TmdbReleaseDateEntryDtoFromJson(
  Map<String, dynamic> json,
) => TmdbReleaseDateEntryDto(
  certification: json['certification'] as String? ?? '',
);
