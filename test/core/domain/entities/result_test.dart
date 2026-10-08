import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/result.dart';

void main() {
  group('Result', () {
    test('Success carries its value through pattern matching', () {
      const Result<int> result = Success(42);

      final matched = switch (result) {
        Success(:final value) => value,
        Failure() => null,
      };

      expect(matched, 42);
    });

    test('Failure carries its reason through pattern matching', () {
      const Result<int> result = Failure(FailureReason.network);

      final matched = switch (result) {
        Success() => null,
        Failure(:final reason) => reason,
      };

      expect(matched, FailureReason.network);
    });
  });
}
