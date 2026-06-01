import 'package:flutter/foundation.dart';

@immutable
class CraftRetryPolicy {
  const CraftRetryPolicy({required this.maxRetries});

  final int maxRetries;
}
