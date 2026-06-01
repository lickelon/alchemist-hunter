import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';

@immutable
class BattleDropEntryDto {
  const BattleDropEntryDto({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  factory BattleDropEntryDto.fromJson(Map<String, Object?> json) {
    return BattleDropEntryDto(
      materialId: readString(json, 'materialId'),
      min: readInt(json, 'min'),
      max: readInt(json, 'max'),
      chance: readDouble(json, 'chance'),
    );
  }

  final String materialId;
  final int min;
  final int max;
  final double chance;

  BattleDropEntry toDomain() {
    return BattleDropEntry(
      materialId: materialId,
      min: min,
      max: max,
      chance: chance,
    );
  }
}
