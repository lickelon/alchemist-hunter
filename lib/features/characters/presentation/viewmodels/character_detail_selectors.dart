import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

String characterTypeLabel(CharacterType type) {
  return switch (type) {
    CharacterType.mercenary => '용병',
    CharacterType.homunculus => '호문쿨루스',
  };
}

String characterSummaryLine(CharacterProgress character) {
  if (character.type == CharacterType.homunculus) {
    final String role = character.homunculusRole ?? '지원';
    final String effect = character.homunculusSupportEffect ?? '효과 분석 중';
    return '$role / $effect';
  }
  if (character.canTierUp) {
    return '다음 행동: 티어업 가능';
  }
  if (character.canRankUp) {
    return '다음 행동: 랭크업 가능';
  }
  if (character.level < character.maxLevelForRank) {
    return '다음 목표: Lv ${character.maxLevelForRank}';
  }
  return '다음 목표: Rank ${character.maxRankForCurrentTier}';
}

String characterRankHint(CharacterProgress character) {
  if (character.canRankUp) {
    return '랭크업 가능';
  }
  if (character.rank >= character.maxRankForCurrentTier) {
    return '현재 티어 최대 랭크 도달';
  }
  return '랭크업 조건: Lv ${character.maxLevelForRank} 도달 필요';
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

  return '티어업 조건: Rank ${character.maxRankForCurrentTier} 도달 필요';
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
  return '승급 재료: $materialKey $owned/1';
}

List<String> characterDetailLines(CharacterProgress character) {
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
  return <String>['역할 $role'];
}

String characterCombatPowerLabel(CharacterProgress character) {
  final BattleCombatStatService statService = const BattleCombatStatService();
  final BattleCombatStats stats = statService.buildStats(character);
  final int power = statService.summaryPowerForStats(stats);
  final String disciplineLabel = switch (statService.disciplineFor(
    character.resolvedCombatJobId,
  )) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
  return '전투력 $power / 전투 직군 $disciplineLabel';
}

List<String> characterCombatStatLines(CharacterProgress character) {
  final BattleCombatStats stats = const BattleCombatStatService().buildStats(
    character,
  );
  return <String>[
    'HP ${stats.maxHp} / 물공 ${stats.physicalAttack} / 물방 ${stats.physicalDefense}',
    '마공 ${stats.magicalAttack} / 마방 ${stats.magicalDefense} / 속도 ${stats.speed}',
    '치확 ${_percentLabel(stats.critChance)} / 치피 ${_percentLabel(stats.critDamage)}',
    '명중 ${_percentLabel(stats.accuracy)} / 회피 ${_percentLabel(stats.evasion)}',
    '상태적중 ${_percentLabel(stats.statusAccuracy)} / 상태저항 ${_percentLabel(stats.statusResistance)}',
    '물관 ${_percentLabel(stats.physicalPenetration)} / 마관 ${_percentLabel(stats.magicalPenetration)}',
    '흡혈 ${_percentLabel(stats.lifesteal)} / 회복력 ${_percentLabel(stats.healingPower)} / 재생 ${_percentLabel(stats.regen)}',
  ];
}

String _percentLabel(double value) {
  return '${(value * 100).round()}%';
}
