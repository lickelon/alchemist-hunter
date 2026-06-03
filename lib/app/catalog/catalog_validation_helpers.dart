Set<String> catalogIds<T>(Iterable<T> values, String Function(T value) idOf) {
  final List<String> ids = values.map(idOf).toList(growable: false);
  requireUnique('catalog id', ids);
  return ids.toSet();
}

void requireUnique(String label, Iterable<String> values) {
  final Set<String> seen = <String>{};
  for (final String value in values) {
    requireNonEmpty(label, value);
    if (!seen.add(value)) {
      throw StateError('Duplicate $label: $value');
    }
  }
}

void requireKnown(String label, String value, Set<String> knownValues) {
  if (!knownValues.contains(value)) {
    throw StateError('Unknown $label: $value');
  }
}

void requireKnownKeys(
  String label,
  Iterable<String> values,
  Set<String> knownValues,
) {
  for (final String value in values) {
    requireKnown(label, value, knownValues);
  }
}

void requireNonEmpty(String label, Object value) {
  if (value is String && value.isEmpty) {
    throw StateError('$label must not be empty');
  }
  if (value is Iterable<Object?> && value.isEmpty) {
    throw StateError('$label must not be empty');
  }
}

void requireLength(String label, List<Object?> values, int length) {
  if (values.length != length) {
    throw StateError('$label must have $length entries');
  }
}

void requirePositiveInt(String label, int value) {
  if (value <= 0) {
    throw StateError('$label must be positive: $value');
  }
}

void requireNonNegative(String label, int value) {
  if (value < 0) {
    throw StateError('$label must be non-negative: $value');
  }
}

void requirePositive(String label, double value) {
  if (value <= 0) {
    throw StateError('$label must be positive: $value');
  }
}

void requirePositiveDuration(String label, Duration value) {
  if (value <= Duration.zero) {
    throw StateError('$label must be positive: $value');
  }
}

void requirePositiveIntMap(String label, Map<String, int> values) {
  for (final MapEntry<String, int> entry in values.entries) {
    requirePositiveInt('$label ${entry.key}', entry.value);
  }
}

void requirePositiveDoubleMap(String label, Map<String, double> values) {
  for (final MapEntry<String, double> entry in values.entries) {
    requirePositive('$label ${entry.key}', entry.value);
  }
}

void requireNonNegativeDoubleMap(String label, Map<String, double> values) {
  for (final MapEntry<String, double> entry in values.entries) {
    if (entry.value < 0) {
      throw StateError('$label ${entry.key} must be non-negative');
    }
  }
}
