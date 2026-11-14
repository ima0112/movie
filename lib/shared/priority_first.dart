/// [items] with the ones that satisfy [isPriority] first, each group in its
/// original order — used to put the user's own tastes (liked genres, their
/// streaming services) at the front of a list of pills without otherwise
/// reordering it.
List<T> priorityFirst<T>(Iterable<T> items, bool Function(T item) isPriority) {
  final first = <T>[];
  final rest = <T>[];
  for (final item in items) {
    (isPriority(item) ? first : rest).add(item);
  }
  return [...first, ...rest];
}
