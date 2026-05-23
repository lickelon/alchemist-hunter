import 'package:alchemist_hunter/features/battle/domain/models.dart';

String battleFactionLabel(CombatFaction faction) {
  return switch (faction) {
    CombatFaction.mercenary => '용병',
    CombatFaction.homunculus => '호문쿨루스',
  };
}

String battleDropQuantityLabel(BattleDropEntry drop) {
  if (drop.min == drop.max) {
    return 'x${drop.min}';
  }
  return 'x${drop.min}-${drop.max}';
}

String battleChanceLabel(double chance) {
  return '${(chance * 100).round()}%';
}

List<String> battleEnemyStatLines(BattleCombatStats stats) {
  return <String>[
    'HP ${stats.maxHp} / 물공 ${stats.physicalAttack} / 물방 ${stats.physicalDefense}',
    '마공 ${stats.magicalAttack} / 마방 ${stats.magicalDefense} / 속도 ${stats.speed}',
    '치확 ${battleChanceLabel(stats.critChance)} / 치피 ${battleChanceLabel(stats.critDamage)}',
    '명중 ${battleChanceLabel(stats.accuracy)} / 회피 ${battleChanceLabel(stats.evasion)}',
    '상태적중 ${battleChanceLabel(stats.statusAccuracy)} / 상태저항 ${battleChanceLabel(stats.statusResistance)}',
    '물관 ${battleChanceLabel(stats.physicalPenetration)} / 마관 ${battleChanceLabel(stats.magicalPenetration)}',
    '흡혈 ${battleChanceLabel(stats.lifesteal)} / 회복력 ${battleChanceLabel(stats.healingPower)} / 재생 ${battleChanceLabel(stats.regen)}',
    '마나 ${stats.maxMp} / 마나재생 ${stats.mpRegen}',
  ];
}

List<String> battleEnemyEffectLines(BattleEnemyDefinition enemy) {
  final List<String> lines = <String>[
    ...enemy.modifiers.map(_battleModifierLabel),
    ...enemy.passives.map(_battlePassiveLabel),
    ...enemy.skills.map(
      (BattleSkillDefinition skill) =>
          _battleSkillLabel(skill, manaCost: enemy.stats.maxMp),
    ),
  ];
  if (lines.isEmpty) {
    return const <String>['특수 효과 없음'];
  }
  return lines;
}

String _battleSkillLabel(BattleSkillDefinition skill, {required int manaCost}) {
  final String effectLabel = _battleSkillEffectLabel(skill);
  final String targetLabel = _battleSkillTargetLabel(skill.targetType);
  return '스킬: ${skill.name} / 마나 소모 $manaCost / $targetLabel / $effectLabel / ${skill.summary}';
}

String _battleModifierLabel(BattleModifier modifier) {
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' / 물리',
    DamageSchool.magical => ' / 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' / 대 ${battleFactionLabel(modifier.targetFaction!)}';
  final String valueLabel = _signedChanceLabel(modifier.value);
  final String baseLabel = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해 $valueLabel',
    BattleModifierType.damageTaken => '받는 피해 $valueLabel',
  };
  return '$baseLabel$schoolLabel$targetLabel';
}

String _battlePassiveLabel(BattlePassiveEffect passive) {
  final String triggerLabel = _battlePassiveTriggerLabel(passive.trigger);
  final String effectLabel = switch (passive.type) {
    BattlePassiveEffectType.alwaysHit => '필중',
    BattlePassiveEffectType.extraAttack => '추가 공격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.firstStrike => '선공',
    BattlePassiveEffectType.counterAttack => '반격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.grantModifier =>
      passive.modifier == null
          ? '버프/디버프 부여'
          : '버프/디버프 부여: ${_battleModifierLabel(passive.modifier!)}',
    BattlePassiveEffectType.grantStatus =>
      '상태이상 부여: ${_battleStatusLabel(passive.statusType)}'
          '${passive.value == null ? '' : ' ${passive.value}'}'
          ' / ${passive.durationLifecycles}행동',
    BattlePassiveEffectType.grantShield =>
      '보호막 +${passive.value ?? 0} / ${passive.durationLifecycles}행동',
  };
  return '패시브: $triggerLabel / $effectLabel';
}

String _signedChanceLabel(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}

String _battleSkillTargetLabel(BattleSkillTargetType targetType) {
  return switch (targetType) {
    BattleSkillTargetType.randomEnemy => '대상: 무작위 적 1명',
    BattleSkillTargetType.self => '대상: 자신',
    BattleSkillTargetType.randomAlly => '대상: 무작위 아군 1명',
    BattleSkillTargetType.allEnemies => '대상: 모든 적',
    BattleSkillTargetType.allAllies => '대상: 모든 아군',
  };
}

String _battleSkillEffectLabel(BattleSkillDefinition skill) {
  return switch (skill.effectType) {
    BattleSkillEffectType.damage =>
      '효과: ${_battleDamageSchoolLabel(skill.school)} 피해 x${skill.powerMultiplier.toStringAsFixed(2)}',
    BattleSkillEffectType.heal => '효과: 회복 +${skill.flatPower}',
    BattleSkillEffectType.grantModifier =>
      skill.modifier == null
          ? '효과: 버프/디버프 부여'
          : '효과: ${_battleModifierLabel(skill.modifier!)} / ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantStatus =>
      '효과: ${_battleStatusLabel(skill.statusType)}'
          '${skill.flatPower <= 0 ? '' : ' ${skill.flatPower}'}'
          ' / ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantShield =>
      '효과: 보호막 +${skill.shieldValue > 0 ? skill.shieldValue : skill.flatPower}',
  };
}

String _battleDamageSchoolLabel(DamageSchool school) {
  return switch (school) {
    DamageSchool.any => '일반',
    DamageSchool.physical => '물리',
    DamageSchool.magical => '마법',
  };
}

String _battleStatusLabel(BattleStatusType? statusType) {
  return switch (statusType) {
    BattleStatusType.poison => '중독',
    BattleStatusType.stun => '기절',
    null => '상태이상',
  };
}

String _battlePassiveTriggerLabel(BattlePassiveTrigger trigger) {
  return switch (trigger) {
    BattlePassiveTrigger.battleStart => '전투 시작',
    BattlePassiveTrigger.beforeAction => '행동 전',
    BattlePassiveTrigger.beforeHitCheck => '명중 판정 전',
    BattlePassiveTrigger.beforeDamage => '피해 계산 전',
    BattlePassiveTrigger.afterHit => '적중 후',
    BattlePassiveTrigger.afterAction => '행동 후',
    BattlePassiveTrigger.turnEnd => '턴 종료',
    BattlePassiveTrigger.onDamaged => '피격 시',
    BattlePassiveTrigger.onDefeat => '사망 시',
  };
}
