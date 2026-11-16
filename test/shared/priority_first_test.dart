import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/priority_first.dart';

void main() {
  test('the priority ones first, each group in its original order', () {
    expect(priorityFirst([1, 2, 3, 4, 5, 6], (n) => n.isEven), [
      2,
      4,
      6,
      1,
      3,
      5,
    ]);
  });

  test('nothing or everything a priority leaves the order alone', () {
    expect(priorityFirst([3, 1, 2], (_) => false), [3, 1, 2]);
    expect(priorityFirst([3, 1, 2], (_) => true), [3, 1, 2]);
    expect(priorityFirst(<int>[], (_) => true), isEmpty);
  });
}
