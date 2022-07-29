part of ddd;

abstract class Entity<T extends ValueObject> implements Identifiable<T> {
  const Entity(this.id);

  @override
  final T id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

abstract class EntityId extends SingleValueObject<String>
    implements Comparable<EntityId> {
  const EntityId(String value) : super(value);

  bool get isValid => value.isNotEmpty;

  /// Check this ID is of numeric type, meaning, only
  /// digits compose the ID.
  ///
  /// Only positive integer values are condisered a
  /// valid numeric ID.
  bool get isNumeric => !(int.tryParse(value) ?? -1).isNegative;

  /// Gets the numeric representation of this ID.
  ///
  /// If [value] is not of numeric type, throws a [FormatException].
  int get numericValue => isNumeric
      ? int.parse(value)
      : throw FormatException('ID is not a numeric value: $value');

  @override
  String toString() => value;

  @override
  int compareTo(EntityId other) => value.compareTo(other.value);
}
