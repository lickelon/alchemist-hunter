import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class TraitUnit {
  const TraitUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.potency,
    this.components = const <String, double>{},
  });

  final String id;
  final String name;
  final TraitType type;
  final double potency;
  final Map<String, double> components;
}

@immutable
class MaterialEntity {
  const MaterialEntity({
    required this.id,
    required this.name,
    required this.rarity,
    required this.traits,
    required this.analyzable,
    required this.source,
  });

  final String id;
  final String name;
  final MaterialRarity rarity;
  final List<TraitUnit> traits;
  final bool analyzable;
  final String source;
}
