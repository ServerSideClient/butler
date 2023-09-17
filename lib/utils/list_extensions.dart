import 'dart:math';

extension ListExtension<E> on List<E> {
  E? randomPick() {
    if (isEmpty) return null;
    return this[Random().nextInt(length)];
  }
}