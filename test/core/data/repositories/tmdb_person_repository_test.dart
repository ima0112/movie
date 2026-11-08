import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/data/repositories/tmdb_person_repository.dart';
import 'package:movies/core/data/tmdb/tmdb_configuration_service.dart';
import 'package:movies/core/data/tmdb/tmdb_media_datasource.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/core/persistence/app_database.dart';

/// Serves a fixture per request, same idea as
/// `tmdb_media_repository_test.dart`'s own adapter — here the choice is
/// by call ORDER, not by inspecting the `language` query param:
/// `TmdbMediaRepository.detail` always awaits the primary call before
/// ever making the English-fallback one, so request #1 is always the
/// primary and #2 (if it happens at all) is always the fallback,
/// regardless of whatever language `LocaleInterceptor` itself defaults
/// to.
class _FixtureRoutedAdapter implements HttpClientAdapter {
  _FixtureRoutedAdapter({required this.primaryFixture});

  final String primaryFixture;
  final List<RequestOptions> requests = [];

  int _personRequestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (!options.path.startsWith('/person')) {
      // /configuration — TmdbConfigurationService swallows a failed
      // fetch and keeps its own fallback, so a plain 500 here is
      // simpler than crafting a valid configuration body this test
      // doesn't otherwise care about.
      return ResponseBody.fromString('', 500);
    }

    _personRequestCount++;
    final fixture = _personRequestCount == 1
        ? primaryFixture
        : 'tmdb_person_detail_full.json';
    return ResponseBody.fromString(
      File('test/fixtures/$fixture').readAsStringSync(),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

TmdbPersonRepository _repositoryWith(_FixtureRoutedAdapter adapter) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final apiClient = ApiClient(DriftSettingsRepository(db));
  apiClient.dio.httpClientAdapter = adapter;
  final datasource = TmdbMediaDatasource(apiClient);
  final configService = TmdbConfigurationService(apiClient);
  return TmdbPersonRepository(datasource, configService);
}

void main() {
  group('TmdbPersonRepository.detail', () {
    test(
      'a single call when the primary biography already has content',
      () async {
        final adapter = _FixtureRoutedAdapter(
          primaryFixture: 'tmdb_person_detail_full.json',
        );
        final repository = _repositoryWith(adapter);

        final result = await repository.detail(287);

        expect(
          adapter.requests.where((r) => r.path.startsWith('/person')),
          hasLength(1),
        );
        final detail = (result as Success<PersonDetail>).value;
        expect(detail.biography, startsWith('William Bradley Pitt'));
        expect(detail.biographyIsEnglishFallback, isFalse);
      },
    );

    test('falls back to an explicit English-language call when the '
        'primary biography is empty', () async {
      final adapter = _FixtureRoutedAdapter(
        primaryFixture: 'tmdb_person_detail_no_biography.json',
      );
      final repository = _repositoryWith(adapter);

      final result = await repository.detail(287);

      final personRequests = adapter.requests.where(
        (r) => r.path.startsWith('/person'),
      );
      expect(personRequests, hasLength(2));
      expect(personRequests.last.queryParameters['language'], 'en-US');
      final detail = (result as Success<PersonDetail>).value;
      expect(detail.biography, startsWith('William Bradley Pitt'));
      expect(detail.biographyIsEnglishFallback, isTrue);
    });
  });
}
