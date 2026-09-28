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
import 'package:movies/core/data/local/drift_taste_profile_repository.dart'
    as _i985;
import 'package:movies/core/data/local/drift_user_library_repository.dart'
    as _i497;
import 'package:movies/core/data/local/drift_user_profile_repository.dart'
    as _i311;
import 'package:movies/core/domain/repositories/media_repository.dart' as _i245;
import 'package:movies/core/domain/repositories/taste_profile_repository.dart'
    as _i762;
import 'package:movies/core/domain/repositories/user_library_repository.dart'
    as _i166;
import 'package:movies/core/domain/repositories/user_profile_repository.dart'
    as _i824;
import 'package:movies/core/persistence/app_database.dart' as _i231;
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart'
    as _i661;
import 'package:movies/features/explore/data/drift_search_history_repository.dart'
    as _i598;
import 'package:movies/features/explore/domain/search_history_repository.dart'
    as _i942;
import 'package:movies/features/match_engine/domain/match_engine.dart' as _i365;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i231.AppDatabase>(() => _i231.AppDatabase());
    gh.lazySingleton<_i942.SearchHistoryRepository>(
      () => _i598.DriftSearchHistoryRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i762.TasteProfileRepository>(
      () => _i985.DriftTasteProfileRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i824.UserProfileRepository>(
      () => _i311.DriftUserProfileRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i245.MediaRepository>(() => _i661.FakeMediaRepository());
    gh.lazySingleton<_i166.UserLibraryRepository>(
      () => _i497.DriftUserLibraryRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i365.MatchEngine>(
      () => _i365.MatchEngineImpl(gh<_i245.MediaRepository>()),
    );
    return this;
  }
}
