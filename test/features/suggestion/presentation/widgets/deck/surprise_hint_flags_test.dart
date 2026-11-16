import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_local_flags_repository.dart';
import 'package:movies/core/data/local/in_memory_local_flags_repository.dart';
import 'package:movies/core/domain/repositories/local_flags_repository.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_double_tap_hint.dart';

void _contract(String name, LocalFlagsRepository Function() create) {
  group(name, () {
    test('a flag is off until it is set, and stays set', () async {
      final repo = create();

      expect(await repo.isSet(LocalFlag.surpriseDoubleTapHintSeen), isFalse);
      await repo.set(LocalFlag.surpriseDoubleTapHintSeen);
      expect(await repo.isSet(LocalFlag.surpriseDoubleTapHintSeen), isTrue);
      await repo.set(LocalFlag.surpriseDoubleTapHintSeen); // idempotent
      expect(await repo.isSet(LocalFlag.surpriseDoubleTapHintSeen), isTrue);
    });
  });
}

void main() {
  _contract('DriftLocalFlagsRepository', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return DriftLocalFlagsRepository(db);
  });
  _contract('InMemoryLocalFlagsRepository', InMemoryLocalFlagsRepository.new);

  testWidgets('the hint draws "2×" with rings and, with reduced motion, '
      'settles instead of looping', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: SurpriseDoubleTapHint()),
        ),
      ),
    );

    expect(find.text('2×'), findsOneWidget);
    await tester.pumpAndSettle(); // would time out if it kept animating
  });

  testWidgets('the hint lets touches through', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => taps++,
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
              const Positioned.fill(child: SurpriseDoubleTapHint()),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('2×'));
    expect(taps, 1);
  });
}
