T readEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values, {
  T? fallback,
}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is String) {
    for (final T entry in values) {
      if (entry.name == value) {
        return entry;
      }
    }
  }
  throw FormatException('Invalid enum value for $key: $value');
}

T? readOptionalEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  return readEnum(json, key, values);
}

String readString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid string value for $key: $value');
}

int readInt(Map<String, Object?> json, String key, {int? fallback}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  throw FormatException('Invalid int value for $key: $value');
}

int? readOptionalInt(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  throw FormatException('Invalid int value for $key: $value');
}

double readDouble(Map<String, Object?> json, String key, {double? fallback}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Invalid number value for $key: $value');
}

T readMap<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value is Map<String, Object?>) {
    return convert(value);
  }
  throw FormatException('Invalid object value for $key: $value');
}

T? readOptionalMap<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return convert(value);
  }
  throw FormatException('Invalid object value for $key: $value');
}

List<T> readList<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value == null) {
    return <T>[];
  }
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return convert(entry);
          }
          throw FormatException('Invalid list entry for $key: $entry');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid list value for $key: $value');
}

List<String> readStringList(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return const <String>[];
  }
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is String) {
            return entry;
          }
          throw FormatException('Invalid string list entry for $key: $entry');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid string list value for $key: $value');
}
