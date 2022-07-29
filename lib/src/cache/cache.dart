part of cache;

///
class CachePolicy {
  final Duration expireAfter;
  late DateTime _validationTime;

  CachePolicy({this.expireAfter = const Duration(minutes: 5)}) {
    invalidate();
  }

  bool get isExpired =>
      DateTime.now().difference(_validationTime) > expireAfter;

  void validate() => _validationTime = DateTime.now();

  void invalidate() => _validationTime = DateTime.fromMillisecondsSinceEpoch(0);
}

///
class Cache<T> {
  Cache(T initialData) {
    emit(initialData);
  }
  final Subject<T> _subject = BehaviorSubject<T>();

  late T _data;

  T get data => _data;

  Stream<T> get stream => _subject.stream;

  void emit(T data) {
    _data = data;
    _subject.add(data);
  }
}

///
mixin CollectionCacheMixin<T> on Cache<Map<String, T>> {
  Stream<List<T>> get values {
    return stream.map((event) => event.values.toList());
  }

  Stream<List<T>> valuesWhere(
    bool Function(T value) test,
  ) {
    return values.map((event) => event.where(test).toList());
  }

  Stream<T?> valueOrNull(String key) {
    return stream.map((event) => event[key]);
  }

  Stream<T> valueOrElse(
    String key, {
    required T Function() orElse,
  }) {
    return valueOrNull(key).map((event) => event ?? orElse());
  }

  Future<bool> contains(String key) {
    return stream.first.then((map) => map.containsKey(key));
  }

  Future<void> add(String key, T value) {
    return stream.first.then((map) => map..[key] = value).then(emit);
  }

  Future<void> addAll(Map<String, T> other) {
    return stream.first.then((map) => map..addAll(other)).then(emit);
  }

  Future<void> replaceAll(Map<String, T> other) {
    return stream.first
        .then(
          (map) => map
            ..clear()
            ..addAll(other),
        )
        .then(emit);
  }

  Future<void> remove(String key) {
    return stream.first.then((map) => map..remove(key)).then(emit);
  }

  Future<void> clear() {
    return stream.first.then((map) => map..clear()).then(emit);
  }
}

///
class CollectionCache<T> extends Cache<Map<String, T>>
    with CollectionCacheMixin<T> {
  CollectionCache() : super({});

  CollectionCache.from(Map<String, T> data) : super(data);

  @override
  void emit(Map<String, T> data) {
    super.emit(data);
  }
}

///
mixin IdentifiableCollectionCacheMixin<T extends Identifiable>
    implements CollectionCacheMixin<T> {
  Future<bool> containsObject(T entity) {
    return contains(entity.id.toString());
  }

  Future<void> addObject(T other) {
    return add(other.id.toString(), other);
  }

  Future<void> addAllObjects(List<T> others) {
    return addAll(others.toMap());
  }

  Future<void> replaceAllObjects(List<T> others) {
    return replaceAll(others.toMap());
  }

  Future<void> removeObject(T other) {
    return remove(other.id.toString());
  }
}

///
class IdentifiableCollectionCache<T extends Identifiable>
    extends CollectionCache<T> with IdentifiableCollectionCacheMixin<T> {
  IdentifiableCollectionCache() : super();

  IdentifiableCollectionCache.from(Iterable<T> identifiables)
      : super.from(identifiables.toMap());
}
