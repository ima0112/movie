import 'dart:async';

import '../../domain/entities/person.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/saved_people_repository.dart';

/// In-memory stand-in for [SavedPeopleRepository] — a fast test double
/// (unannotated: only the drift one is registered). Same rules as the real
/// one: by name A–Z, saving twice refreshes instead of duplicating.
class InMemorySavedPeopleRepository implements SavedPeopleRepository {
  InMemorySavedPeopleRepository([List<Person> initial = const []]) {
    for (final person in initial) {
      _people[person.id] = person;
    }
  }

  final Map<int, Person> _people = {};
  final _changes = StreamController<void>.broadcast();

  List<Person> get _sorted =>
      _people.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  /// The current value on subscribe, then one per change — a plain controller
  /// (not an `async*` generator, whose cancel can wait on a pending yield).
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        changes = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Stream<List<Person>> watchAll() => _watch(() => List.unmodifiable(_sorted));

  @override
  Stream<bool> watchIsSaved(int personId) =>
      _watch(() => _people.containsKey(personId)).distinct();

  @override
  Future<Result<void>> save(Person person) async {
    _people[person.id] = person;
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(int personId) async {
    if (_people.remove(personId) != null) _changes.add(null);
    return const Success(null);
  }
}
