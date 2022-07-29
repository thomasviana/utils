part of utils;

mixin JsonMapper<T> {
  T fromJson(Map jsonObj);

  Map toJson(T t);

  List<T> fromJsonArray(List jsonArray) =>
      jsonArray.map((e) => fromJson(e)).toList();
}
