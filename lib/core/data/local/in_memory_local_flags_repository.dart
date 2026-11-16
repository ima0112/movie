import '../../domain/entities/result.dart';
import '../../domain/repositories/local_flags_repository.dart';

/// In-memory stand-in for [LocalFlagsRepository] — a fast test double
/// (unannotated: only the drift one is registered).
class InMemoryLocalFlagsRepository implements LocalFlagsRepository {
  InMemoryLocalFlagsRepository([Set<LocalFlag> initial = const {}])
    : _set = {...initial};

  final Set<LocalFlag> _set;

  @override
  Future<bool> isSet(LocalFlag flag) async => _set.contains(flag);

  @override
  Future<Result<void>> set(LocalFlag flag) async {
    _set.add(flag);
    return const Success(null);
  }
}
