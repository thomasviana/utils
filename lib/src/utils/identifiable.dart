part of utils;

abstract class Identifiable<T> {
  T get id;
}

extension IdentifiableIterableExt<E extends Identifiable> on Iterable<E> {
  Map<String, E> toMap() {
    return {for (var element in this) element.id.toString(): element};
  }
}
