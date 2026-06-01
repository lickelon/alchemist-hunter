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

bool readBool(Map<String, Object?> json, String key, {bool? fallback}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is bool) {
    return value;
  }
  throw FormatException('Invalid bool value for $key: $value');
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

Map<String, Object?> readObject(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Invalid object value for $key: $value');
}

Map<String, Object?>? readOptionalObject(
  Map<String, Object?> json,
  String key,
) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Invalid object value for $key: $value');
}

List<Map<String, Object?>> readObjectList(
  Map<String, Object?> json,
  String key,
) {
  final Object? value = json[key];
  if (value == null) {
    return <Map<String, Object?>>[];
  }
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return entry;
          }
          throw FormatException('Invalid object list entry for $key: $entry');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid object list value for $key: $value');
}

List<String> readStringList(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return <String>[];
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

Map<String, int> readIntMap(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return <String, int>{};
  }
  if (value is Map<String, Object?>) {
    return value.map((String key, Object? entry) {
      if (entry is int) {
        return MapEntry<String, int>(key, entry);
      }
      throw FormatException('Invalid int map entry for $key: $entry');
    });
  }
  throw FormatException('Invalid int map value for $key: $value');
}

Map<String, double> readDoubleMap(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return <String, double>{};
  }
  if (value is Map<String, Object?>) {
    return value.map((String key, Object? entry) {
      if (entry is num) {
        return MapEntry<String, double>(key, entry.toDouble());
      }
      throw FormatException('Invalid number map entry for $key: $entry');
    });
  }
  throw FormatException('Invalid number map value for $key: $value');
}
