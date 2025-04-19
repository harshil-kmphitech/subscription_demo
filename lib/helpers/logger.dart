import 'dart:developer' as dev;

extension LoggerExtension<T> on T {
  T get log {
    dev.log(toString());
    return this;
  }

  T logWithName(String name) {
    dev.log(toString(), name: name);
    return this;
  }
}
