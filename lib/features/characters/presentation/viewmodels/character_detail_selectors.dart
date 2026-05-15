import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

String characterTypeLabel(CharacterType type) {
  return switch (type) {
    CharacterType.mercenary => '용병',
    CharacterType.homunculus => '호문쿨루스',
  };
}

String characterRankHint(CharacterProgress character) {
  if (character.canRankUp) {
    return '랭크업 가능';
  }
  if (character.rank >= character.maxRankForCurrentTier) {
    return '현재 티어 최대 랭크 도달';
  }
  return '랭크업 조건: 레벨 ${character.maxLevelForRank} 도달 필요';
}

String characterTierHint(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return '티어 승급 완료';
  }

  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;

  if (character.canTierUp) {
    if (owned > 0) {
      return '티어업 가능';
    }
    return '티어업 조건 충족, 승급 재료 부족';
  }

  return '티어업 조건: 랭크 ${character.maxRankForCurrentTier} 도달 필요';
}

bool characterHasTierUpMaterial(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return false;
  }
  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  return (inventory[materialKey] ?? 0) >= 1;
}

String characterTierMaterialLabel(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return '승급 재료: 없음';
  }
  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;
  final String materialName = _tierMaterialDisplayName(character);
  return '승급 재료: $materialName $owned/1';
}

List<String> characterDetailLines(
  CharacterProgress character, {
  required String combatDisciplineLabel,
}) {
  if (character.type == CharacterType.homunculus) {
    return <String>[
      '출처 ${character.homunculusOrigin ?? "미확인 시드"}',
      '역할 ${character.homunculusRole ?? "지원"}',
      '보조효과 ${character.homunculusSupportEffect ?? "효과 분석 중"}',
    ];
  }

  final String role = switch (character.mercenaryTier ?? MercenaryTier.rookie) {
    MercenaryTier.rookie => '기본 전열',
    MercenaryTier.veteran => '숙련 전열',
    MercenaryTier.elite => '정예 전열',
    MercenaryTier.champion => '챔피언 전열',
    MercenaryTier.legend => '전설 전열',
  };
  return <String>['직군 $combatDisciplineLabel / 전열 $role'];
}

String characterCombatPowerLabel({
  required int power,
  required String combatDisciplineLabel,
}) {
  final String disciplineLabel = combatDisciplineLabel;
  return '전투력 $power / 직군 $disciplineLabel';
}

List<String> characterCombatEffectLines(HeroProfile hero) {
  final List<String> lines = <String>[
    ...hero.modifiers.map(_combatModifierLabel),
    ...hero.passives.map(_combatPassiveLabel),
  ];
  if (lines.isEmpty) {
    return const <String>['전투 효과 없음'];
  }
  return lines;
}

List<(String, String)> characterCombatStatPairs(BattleCombatStats stats) {
  return <(String, String)>[
    ('체력', '${stats.maxHp}'),
    ('물공', '${stats.physicalAttack}'),
    ('물방', '${stats.physicalDefense}'),
    ('마공', '${stats.magicalAttack}'),
    ('마방', '${stats.magicalDefense}'),
    ('속도', '${stats.speed}'),
    ('치확', _percentLabel(stats.critChance)),
    ('치피', _percentLabel(stats.critDamage)),
    ('명중', _percentLabel(stats.accuracy)),
    ('회피', _percentLabel(stats.evasion)),
    ('상태적중', _percentLabel(stats.statusAccuracy)),
    ('상태저항', _percentLabel(stats.statusResistance)),
    ('물관', _percentLabel(stats.physicalPenetration)),
    ('마관', _percentLabel(stats.magicalPenetration)),
    ('흡혈', _percentLabel(stats.lifesteal)),
    ('회복력', _percentLabel(stats.healingPower)),
    ('재생', _percentLabel(stats.regen)),
  ];
}

String characterCombatDisciplineLabel(
  String jobId, {
  BattleCombatStatService statService = const BattleCombatStatService(),
}) {
  return switch (statService.disciplineFor(jobId)) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}

String _tierMaterialDisplayName(CharacterProgress character) {
  final int nextTier = character.tierIndex + 1;
  return switch (character.type) {
    CharacterType.mercenary => '용병 승급 재료 $nextTier',
    CharacterType.homunculus => '호문쿨루스 승급 재료 $nextTier',
  };
}

String _percentLabel(double value) {
  return '${(value * 100).round()}%';
}

String _combatModifierLabel(BattleModifier modifier) {
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' / 물리',
    DamageSchool.magical => ' / 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' / 대 ${modifier.targetFaction == CombatFaction.mercenary ? "용병" : "호문쿨루스"}';
  final String valueLabel = modifier.mode == BattleModifierMode.percent
      ? _signedPercentLabel(modifier.value)
      : _signedPercentLabel(modifier.value);
  final String baseLabel = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해 $valueLabel',
    BattleModifierType.damageTaken => '받는 피해 $valueLabel',
  };
  return '$baseLabel$schoolLabel$targetLabel';
}

String _combatPassiveLabel(BattlePassiveEffect passive) {
  return switch (passive.type) {
    BattlePassiveEffectType.alwaysHit => '패시브: 필중',
    BattlePassiveEffectType.extraAttack => '패시브: 추가 공격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.counterAttack => '패시브: 반격 +${passive.value ?? 1}회',
  };
}

String _signedPercentLabel(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}
