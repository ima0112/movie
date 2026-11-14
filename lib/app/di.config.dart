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
import 'package:movies/core/data/local/drift_onboarding_repository.dart'
    as _i116;
import 'package:movies/core/data/local/drift_recently_viewed_repository.dart'
    as _i433;
import 'package:movies/core/data/local/drift_saved_people_repository.dart'
    as _i1048;
import 'package:movies/core/data/local/drift_settings_repository.dart' as _i448;
import 'package:movies/core/data/local/drift_taste_profile_repository.dart'
    as _i985;
import 'package:movies/core/data/local/drift_user_library_repository.dart'
    as _i497;
import 'package:movies/core/data/local/drift_user_profile_repository.dart'
    as _i311;
import 'package:movies/core/data/repositories/tmdb_media_repository.dart'
    as _i28;
import 'package:movies/core/data/repositories/tmdb_person_repository.dart'
    as _i496;
import 'package:movies/core/data/tmdb/tmdb_configuration_service.dart' as _i294;
import 'package:movies/core/data/tmdb/tmdb_media_datasource.dart' as _i118;
import 'package:movies/core/domain/repositories/media_repository.dart' as _i245;
import 'package:movies/core/domain/repositories/onboarding_repository.dart'
    as _i725;
import 'package:movies/core/domain/repositories/person_repository.dart'
    as _i263;
import 'package:movies/core/domain/repositories/recently_viewed_repository.dart'
    as _i608;
import 'package:movies/core/domain/repositories/saved_people_repository.dart'
    as _i451;
import 'package:movies/core/domain/repositories/settings_repository.dart'
    as _i780;
import 'package:movies/core/domain/repositories/taste_profile_repository.dart'
    as _i762;
import 'package:movies/core/domain/repositories/user_library_repository.dart'
    as _i166;
import 'package:movies/core/domain/repositories/user_profile_repository.dart'
    as _i824;
import 'package:movies/core/network/api_client.dart' as _i152;
import 'package:movies/core/network/network_status.dart' as _i320;
import 'package:movies/core/persistence/app_database.dart' as _i231;
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart'
    as _i661;
import 'package:movies/features/explore/data/drift_search_history_repository.dart'
    as _i598;
import 'package:movies/features/explore/domain/search_history_repository.dart'
    as _i942;
import 'package:movies/features/match_engine/domain/match_engine.dart' as _i365;
import 'package:movies/features/person_detail/data/repositories/fake_person_repository.dart'
    as _i849;

const String _real = 'real';
const String _fake = 'fake';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i320.NetworkStatus>(() => _i320.NetworkStatus());
    gh.lazySingleton<_i231.AppDatabase>(() => _i231.AppDatabase());
    gh.lazySingleton<_i942.SearchHistoryRepository>(
      () => _i598.DriftSearchHistoryRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i725.OnboardingRepository>(
      () => _i116.DriftOnboardingRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i451.SavedPeopleRepository>(
      () => _i1048.DriftSavedPeopleRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i762.TasteProfileRepository>(
      () => _i985.DriftTasteProfileRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i824.UserProfileRepository>(
      () => _i311.DriftUserProfileRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i608.RecentlyViewedRepository>(
      () => _i433.DriftRecentlyViewedRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i780.SettingsRepository>(
      () => _i448.DriftSettingsRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i166.UserLibraryRepository>(
      () => _i497.DriftUserLibraryRepository(gh<_i231.AppDatabase>()),
    );
    gh.lazySingleton<_i152.ApiClient>(
      () => _i152.ApiClient(
        gh<_i780.SettingsRepository>(),
        gh<_i320.NetworkStatus>(),
      ),
      registerFor: {_real},
    );
    gh.lazySingleton<_i263.PersonRepository>(
      () => _i849.FakePersonRepository(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i245.MediaRepository>(
      () => _i661.FakeMediaRepository(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i294.TmdbConfigurationService>(
      () => _i294.TmdbConfigurationService(gh<_i152.ApiClient>()),
      registerFor: {_real},
    );
    gh.lazySingleton<_i118.TmdbMediaDatasource>(
      () => _i118.TmdbMediaDatasource(gh<_i152.ApiClient>()),
      registerFor: {_real},
    );
    gh.lazySingleton<_i245.MediaRepository>(
      () => _i28.TmdbMediaRepository(
        gh<_i118.TmdbMediaDatasource>(),
        gh<_i294.TmdbConfigurationService>(),
        gh<_i780.SettingsRepository>(),
      ),
      registerFor: {_real},
    );
    gh.lazySingleton<_i263.PersonRepository>(
      () => _i496.TmdbPersonRepository(
        gh<_i118.TmdbMediaDatasource>(),
        gh<_i294.TmdbConfigurationService>(),
      ),
      registerFor: {_real},
    );
    gh.lazySingleton<_i365.MatchEngine>(
      () => _i365.MatchEngineImpl(gh<_i245.MediaRepository>()),
    );
    return this;
  }
}
