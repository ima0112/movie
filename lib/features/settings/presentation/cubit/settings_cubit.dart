import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/settings_repository.dart';

/// C6 (Settings)'s own screen-local Cubit — the one and only Cubit on
/// top of [SettingsRepository] (no library-wide preferences Cubit, per
/// CLAUDE.md rule 10: this is a single-screen concern, built where its
/// own `BlocProvider` is placed, not registered in `di.config.dart`).
///
/// [SettingsRepository] stays the single source of truth: this Cubit
/// just mirrors its [SettingsRepository.watch] stream (starting from
/// [SettingsRepository.current], already synchronously available),
/// same "read/write through the one real source" discipline
/// `MyTastesCubit` already applies to `TasteProfileRepository`. H5/H6's
/// picks are also [emit]ted directly once [SettingsRepository.save]
/// succeeds, rather than only waiting on [_subscription]'s own next
/// delivery — drift's reactive query notifies on its own schedule
/// (a microtask after the write, not synchronously with it), and
/// "tapping applies and closes" (`docs/SCREENS.md` H5–H7) reads as
/// instant, not eventually-consistent.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.current) {
    _subscription = _repository.watch().listen(emit);
  }

  final SettingsRepository _repository;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> setLanguage(String languageCode) =>
      _save(state.copyWith(languageCode: languageCode));

  Future<void> setRegion(String regionCode) =>
      _save(state.copyWith(regionCode: regionCode));

  Future<void> _save(AppSettings settings) async {
    final result = await _repository.save(settings);
    if (result is Success<void> && !isClosed) emit(settings);
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
