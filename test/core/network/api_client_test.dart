import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/core/persistence/app_database.dart';

/// Records every request's `language`/`region` query parameters, so a
/// test can assert on what `LocaleInterceptor` actually sent without
/// caring about the (irrelevant, for this) response body.
class _RecordingAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> queryParameters = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    queryParameters.add(options.queryParameters);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'after save() with a different region/language, the next request '
    'carries the new values — LocaleInterceptor reads SettingsRepository '
    'fresh on every request, not just once at ApiClient construction',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final settingsRepository = DriftSettingsRepository(db);
      final apiClient = ApiClient(settingsRepository);
      final adapter = _RecordingAdapter();
      apiClient.dio.httpClientAdapter = adapter;

      await apiClient.dio.get('/anything');
      expect(adapter.queryParameters.single['language'], 'en-US');
      expect(adapter.queryParameters.single['region'], 'US');

      await settingsRepository.save(
        const AppSettings(languageCode: 'es', regionCode: 'MX'),
      );
      await apiClient.dio.get('/anything');

      expect(adapter.queryParameters.last['language'], 'es-MX');
      expect(adapter.queryParameters.last['region'], 'MX');
    },
  );
}
