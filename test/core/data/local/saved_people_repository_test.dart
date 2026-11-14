import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_saved_people_repository.dart';
import 'package:movies/core/data/local/in_memory_saved_people_repository.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/saved_people_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

Person _person(int id, String name, {String? department}) => Person(
  id: id,
  name: name,
  profilePath: '/p$id.jpg',
  knownForDepartment: department,
);

DriftSavedPeopleRepository _drift() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftSavedPeopleRepository(db);
}

/// The same contract, for both implementations.
void _contract(String name, SavedPeopleRepository Function() create) {
  group(name, () {
    test('starts empty', () async {
      final repo = create();
      expect(await repo.watchAll().first, isEmpty);
      expect(await repo.watchIsSaved(1).first, isFalse);
    });

    test('lists the saved people by name A–Z, ignoring case', () async {
      final repo = create();
      await repo.save(_person(1, 'zoe Saldaña'));
      await repo.save(_person(2, 'Adam Driver', department: 'Acting'));
      await repo.save(_person(3, 'bong Joon-ho'));

      final people = await repo.watchAll().first;

      expect(people.map((p) => p.id), [2, 3, 1]);
      expect(people.first.knownForDepartment, 'Acting');
      expect(people.first.profilePath, '/p2.jpg');
    });

    test('saving twice refreshes the snapshot, never duplicates', () async {
      final repo = create();
      await repo.save(_person(1, 'Old name'));
      await repo.save(_person(1, 'New name'));

      final people = await repo.watchAll().first;

      expect(people, hasLength(1));
      expect(people.single.name, 'New name');
    });

    test('remove forgets the person; removing a stranger is fine', () async {
      final repo = create();
      await repo.save(_person(1, 'A'));

      expect(await repo.remove(2), isA<Success<void>>());
      expect(await repo.remove(1), isA<Success<void>>());

      expect(await repo.watchAll().first, isEmpty);
    });

    test('watchIsSaved follows save and remove for that person only', () async {
      final repo = create();
      final states = <bool>[];
      final sub = repo.watchIsSaved(1).listen(states.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      await repo.save(_person(2, 'Someone else'));
      await Future<void>.delayed(Duration.zero);
      await repo.save(_person(1, 'Me'));
      await Future<void>.delayed(Duration.zero);
      await repo.remove(1);
      await Future<void>.delayed(Duration.zero);

      expect(states, [false, true, false]);
    });
  });
}

void main() {
  _contract('InMemorySavedPeopleRepository', InMemorySavedPeopleRepository.new);
  _contract('DriftSavedPeopleRepository', _drift);
}
