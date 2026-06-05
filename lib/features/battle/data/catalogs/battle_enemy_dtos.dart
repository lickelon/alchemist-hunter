import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';
import 'battle_combat_stats_dto.dart';
import 'battle_drop_dtos.dart';
import 'combat_effect_dtos.dart';

@immutable
class BattleEnemyDefinitionDto {
  const BattleEnemyDefinitionDto({
    required this.id,
    required this.name,
    required this.faction,
    required this.summary,
    required this.stats,
    this.modifiers = const <BattleModifierDto>[],
    this.passives = const <BattlePassiveEffectDto>[],
    this.skills = const <BattleSkillDefinitionDto>[],
    this.skillIds = const <String>[],
    this.normalDrops = const <BattleDropEntryDto>[],
    this.specialDrops = const <BattleDropEntryDto>[],
  });

  final String id;
  final String name;
  final CombatFaction faction;
  final String summary;
  final BattleCombatStatsDto stats;
  final List<BattleModifierDto> modifiers;
  final List<BattlePassiveEffectDto> passives;
  final List<BattleSkillDefinitionDto> skills;
  final List<String> skillIds;
  final List<BattleDropEntryDto> normalDrops;
  final List<BattleDropEntryDto> specialDrops;

  factory BattleEnemyDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleEnemyDefinitionDto(
      id: readString(json, 'id'),
      name: readString(json, 'name'),
      faction: readEnum(json, 'faction', CombatFaction.values),
      summary: readString(json, 'summary'),
      stats: readMap(json, 'stats', BattleCombatStatsDto.fromJson),
      modifiers: readList(json, 'modifiers', BattleModifierDto.fromJson),
      passives: readList(json, 'passives', BattlePassiveEffectDto.fromJson),
      skills: readList(json, 'skills', BattleSkillDefinitionDto.fromJson),
      skillIds: readStringList(json, 'skillIds'),
      normalDrops: readList(json, 'normalDrops', BattleDropEntryDto.fromJson),
      specialDrops: readList(json, 'specialDrops', BattleDropEntryDto.fromJson),
    );
  }

  BattleEnemyDefinition toDomain({
    List<BattleSkillDefinition> referencedSkills =
        const <BattleSkillDefinition>[],
  }) {
    return BattleEnemyDefinition(
      id: id,
      name: name,
      faction: faction,
      summary: summary,
      stats: stats.toDomain(),
      modifiers: modifiers
          .map((BattleModifierDto modifier) => modifier.toDomain())
          .toList(growable: false),
      passives: passives
          .map((BattlePassiveEffectDto passive) => passive.toDomain())
          .toList(growable: false),
      skills: <BattleSkillDefinition>[
        ...skills.map((BattleSkillDefinitionDto skill) => skill.toDomain()),
        ...referencedSkills,
      ],
      normalDrops: normalDrops
          .map((BattleDropEntryDto drop) => drop.toDomain())
          .toList(growable: false),
      specialDrops: specialDrops
          .map((BattleDropEntryDto drop) => drop.toDomain())
          .toList(growable: false),
    );
  }
}

@immutable
class BattleEnemySetDefinitionDto {
  const BattleEnemySetDefinitionDto({required this.id, required this.enemyIds});

  final String id;
  final List<String> enemyIds;

  factory BattleEnemySetDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleEnemySetDefinitionDto(
      id: readString(json, 'id'),
      enemyIds: readStringList(json, 'enemyIds'),
    );
  }

  BattleEnemySetDefinition toDomain() {
    return BattleEnemySetDefinition(id: id, enemyIds: enemyIds);
  }
}
