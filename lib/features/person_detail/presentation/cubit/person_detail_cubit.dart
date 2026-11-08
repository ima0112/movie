import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/person_repository.dart';

/// D3's load state — same shape as `MovieDetailCubit`/`TvDetailCubit`.
sealed class PersonDetailState {
  const PersonDetailState();
}

/// Nothing loaded yet — before the first [PersonDetailCubit.loadDetail]
/// call.
final class PersonDetailInitial extends PersonDetailState {
  const PersonDetailInitial();
}

/// Fetching the detail for the id passed to
/// [PersonDetailCubit.loadDetail].
final class PersonDetailLoading extends PersonDetailState {
  const PersonDetailLoading();
}

/// Detail ready.
final class PersonDetailLoaded extends PersonDetailState {
  const PersonDetailLoaded(this.detail);

  final PersonDetail detail;
}

/// The load failed.
final class PersonDetailError extends PersonDetailState {
  const PersonDetailError(this.reason);

  final FailureReason reason;
}

/// Loads a person's full detail (D3).
///
/// Source of truth: `docs/SCREENS.md` D3 and `docs/STRUCTURE.md` ("One
/// `Cubit` ... per screen in `presentation/`"). Mirrors
/// `MovieDetailCubit`/`TvDetailCubit` exactly, for the same reason they
/// don't share one generic Cubit between themselves either.
class PersonDetailCubit extends Cubit<PersonDetailState> {
  PersonDetailCubit(this._personRepository)
    : super(const PersonDetailInitial());

  final PersonRepository _personRepository;

  Future<void> loadDetail(int personId) async {
    emit(const PersonDetailLoading());

    final result = await _personRepository.detail(personId);
    switch (result) {
      case Success<PersonDetail>(:final value):
        emit(PersonDetailLoaded(value));
      case Failure<PersonDetail>(:final reason):
        emit(PersonDetailError(reason));
    }
  }
}
