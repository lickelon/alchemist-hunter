import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';
import 'battle_combat_stats_dto.dart';

@immutable
class BattleCombatJobRankDefinitionDto {
  const BattleCombatJobRankDefinitionDto({
    required this.rank,
    required this.stats,
    this.skillIds = const <String>[],
    this.passiveIds = const <String>[],
  });

  final int rank;
  final BattleCombatStatsDto stats;
  final List<String> skillIds;
  final List<String> passiveIds;

  factory BattleCombatJobRankDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleCombatJobRankDefinitionDto(
      rank: readInt(json, 'rank'),
      stats: readMap(json, 'stats', BattleCombatStatsDto.fromJson),
      skillIds: readStringList(json, 'skillIds'),
      passiveIds: readStringList(json, 'passiveIds'),
    );
  }

  BattleCombatJobRankDefinition toDomain() {
    return BattleCombatJobRankDefinition(
      rank: rank,
      stats: stats.toDomain(),
      skillIds: List<String>.unmodifiable(skillIds),
      passiveIds: List<String>.unmodifiable(passiveIds),
    );
  }
}

@immutable
class BattleCombatJobTierDefinitionDto {
  const BattleCombatJobTierDefinitionDto({
    required this.tierIndex,
    required this.ranks,
  });

  final int tierIndex;
  final List<BattleCombatJobRankDefinitionDto> ranks;

  factory BattleCombatJobTierDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleCombatJobTierDefinitionDto(
      tierIndex: readInt(json, 'tierIndex'),
      ranks: readList(json, 'ranks', BattleCombatJobRankDefinitionDto.fromJson),
    );
  }

  BattleCombatJobTierDefinition toDomain() {
    return BattleCombatJobTierDefinition(
      tierIndex: tierIndex,
      ranks: ranks
          .map((BattleCombatJobRankDefinitionDto rank) => rank.toDomain())
          .toList(growable: false),
    );
  }
}

@immutable
class BattleCombatJobDefinitionDto {
  const BattleCombatJobDefinitionDto({
    required this.id,
    required this.faction,
    required this.discipline,
    required this.levelHpGrowth,
    required this.tiers,
  });

  final String id;
  final CombatFaction faction;
  final CombatDiscipline discipline;
  final int levelHpGrowth;
  final List<BattleCombatJobTierDefinitionDto> tiers;

  factory BattleCombatJobDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleCombatJobDefinitionDto(
      id: readString(json, 'id'),
      faction: readEnum(json, 'faction', CombatFaction.values),
      discipline: readEnum(json, 'discipline', CombatDiscipline.values),
      levelHpGrowth: readInt(json, 'levelHpGrowth'),
      tiers: readList(json, 'tiers', BattleCombatJobTierDefinitionDto.fromJson),
    );
  }

  BattleCombatJobDefinition toDomain() {
    return BattleCombatJobDefinition(
      id: id,
      faction: faction,
      discipline: discipline,
      levelHpGrowth: levelHpGrowth,
      tiers: tiers
          .map((BattleCombatJobTierDefinitionDto tier) => tier.toDomain())
          .toList(growable: false),
    );
  }
}
