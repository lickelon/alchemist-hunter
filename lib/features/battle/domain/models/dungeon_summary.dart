import 'package:flutter/foundation.dart';

@immutable
class DungeonSummary {
  const DungeonSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.unlocked,
  });

  final String id;
  final String name;
  final String description;
  final bool unlocked;
}
