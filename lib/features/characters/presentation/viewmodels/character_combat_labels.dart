import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_combat_stat_service.dart';

String characterCombatPowerLabel({
  required int power,
  required String combatDisciplineLabel,
}) {
  final String disciplineLabel = combatDisciplineLabel;
  return '전투력 $power, 직군 $disciplineLabel';
}

List<String> characterCombatEffectLines(HeroProfile hero) {
  final List<String> lines = <String>[
    ...hero.modifiers.map(_combatModifierLabel),
    ...hero.passives.map(_combatPassiveLabel),
    ...hero.skills.expand(
      (BattleSkillDefinition skill) =>
          _combatSkillLabels(skill, manaCost: hero.stats.maxMp),
    ),
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
  required BattleCombatStatService statService,
}) {
  return switch (statService.disciplineFor(jobId)) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}

String _percentLabel(double value) {
  return '${(value * 100).round()}%';
}

String _combatModifierLabel(BattleModifier modifier) {
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' 물리',
    DamageSchool.magical => ' 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' 대 ${modifier.targetFaction == CombatFaction.mercenary ? "용병" : "호문쿨루스"}';
  final String valueLabel = _signedPercentLabel(modifier.value);
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
    BattlePassiveEffectType.firstStrike => '패시브: 선공',
    BattlePassiveEffectType.counterAttack => '패시브: 반격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.grantModifier => '패시브: 버프/디버프 부여',
    BattlePassiveEffectType.grantStatus => '패시브: 상태이상 부여',
    BattlePassiveEffectType.grantShield => '패시브: 보호막 부여',
  };
}

List<String> _combatSkillLabels(
  BattleSkillDefinition skill, {
  required int manaCost,
}) {
  final String targetLabel = _skillTargetLabel(skill.targetType);
  final String effectLabel = _skillEffectLabel(skill);
  return <String>[
    '스킬: ${skill.name}',
    '마나 소모 $manaCost',
    targetLabel,
    effectLabel,
  ];
}

String _skillTargetLabel(BattleSkillTargetType targetType) {
  return switch (targetType) {
    BattleSkillTargetType.randomEnemy => '무작위 적 1명',
    BattleSkillTargetType.self => '자신',
    BattleSkillTargetType.randomAlly => '무작위 아군 1명',
    BattleSkillTargetType.allEnemies => '모든 적',
    BattleSkillTargetType.allAllies => '모든 아군',
  };
}

String _skillEffectLabel(BattleSkillDefinition skill) {
  return switch (skill.effectType) {
    BattleSkillEffectType.damage =>
      '${_damageSchoolLabel(skill.school)} 피해 x${skill.powerMultiplier.toStringAsFixed(2)}'
          '${skill.flatPower == 0 ? '' : ' +${skill.flatPower}'}',
    BattleSkillEffectType.heal => '회복 +${skill.flatPower}',
    BattleSkillEffectType.grantModifier =>
      skill.modifier == null
          ? '버프/디버프 부여'
          : '${_combatModifierLabel(skill.modifier!)} ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantStatus =>
      '${_statusLabel(skill.statusType)}'
          '${skill.flatPower <= 0 ? '' : ' ${skill.flatPower}'}'
          ' ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantShield =>
      '보호막 +${skill.shieldValue > 0 ? skill.shieldValue : skill.flatPower}',
  };
}

String _damageSchoolLabel(DamageSchool school) {
  return switch (school) {
    DamageSchool.any => '기본',
    DamageSchool.physical => '물리',
    DamageSchool.magical => '마법',
  };
}

String _statusLabel(BattleStatusType? statusType) {
  return switch (statusType) {
    BattleStatusType.poison => '독',
    BattleStatusType.stun => '기절',
    null => '상태이상',
  };
}

String _signedPercentLabel(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}
