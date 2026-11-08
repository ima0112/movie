import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/person_repository.dart';
import '../../network/dio_failure_mapper.dart';
import '../tmdb/tmdb_configuration_service.dart';
import '../tmdb/tmdb_person_mappers.dart';
import '../tmdb/tmdb_media_datasource.dart';

/// D3's real TMDB-backed [PersonRepository].
@real
@LazySingleton(as: PersonRepository)
class TmdbPersonRepository implements PersonRepository {
  TmdbPersonRepository(this._datasource, this._configService);

  final TmdbMediaDatasource _datasource;
  final TmdbConfigurationService _configService;

  /// D3's own "Biography in English" fallback language — see
  /// `personDetailFromDto`'s own doc comment.
  static const _fallbackLanguage = 'en-US';

  @override
  Future<Result<PersonDetail>> detail(int personId) async {
    try {
      final dto = await _datasource.personDetail(personId);

      _configService.load();
      final imagesConfig = _configService.current;

      if (dto.biography.isNotEmpty) {
        return Success(personDetailFromDto(dto, imagesConfig: imagesConfig));
      }

      // No biography in the user's own language — try English before
      // giving up on having one at all.
      final fallbackDto = await _datasource.personDetail(
        personId,
        language: _fallbackLanguage,
      );
      return Success(
        personDetailFromDto(
          dto,
          imagesConfig: imagesConfig,
          fallbackBiography: fallbackDto.biography,
        ),
      );
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }
}
