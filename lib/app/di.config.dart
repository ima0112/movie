// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:movies/core/data/local/in_memory_user_library_repository.dart'
    as _i584;
import 'package:movies/core/domain/repositories/media_repository.dart' as _i245;
import 'package:movies/core/domain/repositories/user_library_repository.dart'
    as _i166;
import 'package:movies/core/persistence/app_database.dart' as _i231;
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart'
    as _i661;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i231.AppDatabase>(() => _i231.AppDatabase());
    gh.lazySingleton<_i245.MediaRepository>(() => _i661.FakeMediaRepository());
    gh.lazySingleton<_i166.UserLibraryRepository>(
      () => _i584.InMemoryUserLibraryRepository(),
    );
    return this;
  }
}
