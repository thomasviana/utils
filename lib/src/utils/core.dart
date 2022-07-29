part of utils;

R run<R>(R Function() block) {
  return block();
}

extension ScopeFunctions<T> on T {
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  R let<R>(R Function(T it) block) {
    return block(this);
  }
}
