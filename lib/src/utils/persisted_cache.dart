part of utils;

///
abstract class BasePersistedCache<T> extends Cache<T> {
  BasePersistedCache(
    this.name,
    T dfltData,
  ) : super(dfltData);

  final String name;
  bool _prefsDataLoaded = false;

  @protected
  T fromRawJson(String rawJson);

  @protected
  String toRawJson(T prefsData);

  Future<T> _loadPrefsData(T dflt) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(name)?.let(fromRawJson) ?? dflt;
  }

  Future<void> _savePrefsData(T prefsData) async {
    final prefs = await SharedPreferences.getInstance();
    return toRawJson(prefsData).let((it) => prefs.setString(name, it));
  }

  @override
  void emit(T data) {
    if (!_prefsDataLoaded) {
      _loadPrefsData(data)
          .then((data) => super.emit(data))
          .then((_) => _prefsDataLoaded = true);
    } else {
      _savePrefsData(data).then((_) => super.emit(data));
    }
  }
}

///
class PersistedCache<T> extends BasePersistedCache<T> {
  PersistedCache(
    String name,
    this.jsonMapper,
    T dfltData,
  ) : super(name, dfltData);

  final JsonMapper<T> jsonMapper;

  @override
  T fromRawJson(String rawJson) {
    final jsonObj = jsonDecode(rawJson);
    return jsonMapper.fromJson(jsonObj);
  }

  @override
  String toRawJson(T prefsData) {
    final jsonObj = jsonMapper.toJson(prefsData);
    return jsonEncode(jsonObj);
  }
}

//
class PersistedCollectionCache<T> extends BasePersistedCache<Map<String, T>>
    with CollectionCacheMixin<T> {
  PersistedCollectionCache(
    String name,
    this.jsonMapper,
  ) : super(name, {});

  PersistedCollectionCache.from(
    String name,
    this.jsonMapper,
    Map<String, T> data,
  ) : super(name, data);

  final JsonMapper<T> jsonMapper;

  @override
  Map<String, T> fromRawJson(String rawJson) {
    final Map<String, dynamic> jsonObj = jsonDecode(rawJson);
    return jsonObj
        .map((key, value) => MapEntry(key, jsonMapper.fromJson(value)));
  }

  @override
  String toRawJson(Map<String, T> prefsData) {
    final Map<String, dynamic> jsonObj =
        prefsData.map((key, value) => MapEntry(key, jsonMapper.toJson(value)));
    return jsonEncode(jsonObj);
  }
}

///
class PersistedIdentifiableCollectionCache<T extends Identifiable>
    extends PersistedCollectionCache<T>
    with IdentifiableCollectionCacheMixin<T> {
  PersistedIdentifiableCollectionCache(
    String name,
    JsonMapper<T> jsonMapper,
  ) : super(name, jsonMapper);

  PersistedIdentifiableCollectionCache.from(
    String name,
    JsonMapper<T> jsonMapper,
    Iterable<T> data,
  ) : super.from(name, jsonMapper, data.toMap());
}
