import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleDropChanceView {
  const BattleDropChanceView({
    required this.materialName,
    required this.quantityLabel,
    required this.chanceLabel,
  });

  final String materialName;
  final String quantityLabel;
  final String chanceLabel;
}

class BattleEnemyDropView {
  const BattleEnemyDropView({
    required this.enemyName,
    required this.identityLabel,
    required this.statLines,
    required this.effectLines,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String enemyName;
  final String identityLabel;
  final List<String> statLines;
  final List<String> effectLines;
  final List<BattleDropChanceView> normalDrops;
  final List<BattleDropChanceView> specialDrops;
}

class BattleStageDropOverviewView {
  const BattleStageDropOverviewView({
    required this.stageName,
    required this.recommendedPower,
    required this.enemyCount,
    required this.enemies,
  });

  final String stageName;
  final int recommendedPower;
  final int enemyCount;
  final List<BattleEnemyDropView> enemies;
}

final battleStageDropOverviewProvider =
    Provider.family<BattleStageDropOverviewView, String>((
      Ref ref,
      String stageId,
    ) {
      final BattleCatalogRepository battleCatalog = ref.watch(
        battleCatalogRepositoryProvider,
      );
      final MaterialCatalogRepository materialCatalog = ref.watch(
        materialCatalogRepositoryProvider,
      );
      final BattleStageDefinition stage = battleCatalog.stageDefinition(
        stageId,
      );
      final List<BattleEnemyDefinition> uniqueEnemies = battleCatalog
          .enemyDefinitionsForStage(stageId);

      return BattleStageDropOverviewView(
        stageName: battleStageDisplayName(stage.id, fallback: stage.name),
        recommendedPower: stage.recommendedPower,
        enemyCount: uniqueEnemies.length,
        enemies: uniqueEnemies
            .map((BattleEnemyDefinition enemy) {
              return BattleEnemyDropView(
                enemyName: enemy.name,
                identityLabel:
                    '${_factionLabel(enemy.faction)} / ${enemy.summary}',
                statLines: _enemyStatLines(enemy.stats),
                effectLines: _enemyEffectLines(enemy),
                normalDrops: enemy.normalDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: _quantityLabel(drop),
                        chanceLabel: _chanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
                specialDrops: enemy.specialDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: _quantityLabel(drop),
                        chanceLabel: _chanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
              );
            })
            .toList(growable: false),
      );
    });

String _factionLabel(CombatFaction faction) {
  return switch (faction) {
    CombatFaction.mercenary => '용병',
    CombatFaction.homunculus => '호문쿨루스',
  };
}

String _quantityLabel(BattleDropEntry drop) {
  if (drop.min == drop.max) {
    return 'x${drop.min}';
  }
  return 'x${drop.min}-${drop.max}';
}

String _chanceLabel(double chance) {
  return '${(chance * 100).round()}%';
}

List<String> _enemyStatLines(BattleCombatStats stats) {
  return <String>[
    'HP ${stats.maxHp} / 물공 ${stats.physicalAttack} / 물방 ${stats.physicalDefense}',
    '마공 ${stats.magicalAttack} / 마방 ${stats.magicalDefense} / 속도 ${stats.speed}',
    '치확 ${_chanceLabel(stats.critChance)} / 치피 ${_chanceLabel(stats.critDamage)}',
    '명중 ${_chanceLabel(stats.accuracy)} / 회피 ${_chanceLabel(stats.evasion)}',
    '상태적중 ${_chanceLabel(stats.statusAccuracy)} / 상태저항 ${_chanceLabel(stats.statusResistance)}',
    '물관 ${_chanceLabel(stats.physicalPenetration)} / 마관 ${_chanceLabel(stats.magicalPenetration)}',
    '흡혈 ${_chanceLabel(stats.lifesteal)} / 회복력 ${_chanceLabel(stats.healingPower)} / 재생 ${_chanceLabel(stats.regen)}',
    '마나 ${stats.maxMp} / 마나재생 ${stats.mpRegen}',
  ];
}

List<String> _enemyEffectLines(BattleEnemyDefinition enemy) {
  final List<String> lines = <String>[
    ...enemy.modifiers.map(_modifierLabel),
    ...enemy.passives.map(_passiveLabel),
    ...enemy.skills.map(
      (BattleSkillDefinition skill) =>
          _skillLabel(skill, manaCost: enemy.stats.maxMp),
    ),
  ];
  if (lines.isEmpty) {
    return const <String>['특수 효과 없음'];
  }
  return lines;
}

String _skillLabel(BattleSkillDefinition skill, {required int manaCost}) {
  final String effectLabel = _skillEffectLabel(skill);
  final String targetLabel = _skillTargetLabel(skill.targetType);
  return '스킬: ${skill.name} / 마나 소모 $manaCost / $targetLabel / $effectLabel / ${skill.summary}';
}

String _modifierLabel(BattleModifier modifier) {
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' / 물리',
    DamageSchool.magical => ' / 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' / 대 ${_factionLabel(modifier.targetFaction!)}';
  final String valueLabel = modifier.mode == BattleModifierMode.percent
      ? _signedChanceLabel(modifier.value)
      : _signedChanceLabel(modifier.value);
  final String baseLabel = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해 $valueLabel',
    BattleModifierType.damageTaken => '받는 피해 $valueLabel',
  };
  return '$baseLabel$schoolLabel$targetLabel';
}

String _passiveLabel(BattlePassiveEffect passive) {
  final String triggerLabel = _passiveTriggerLabel(passive.trigger);
  final String effectLabel = switch (passive.type) {
    BattlePassiveEffectType.alwaysHit => '필중',
    BattlePassiveEffectType.extraAttack => '추가 공격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.firstStrike => '선공',
    BattlePassiveEffectType.counterAttack => '반격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.grantModifier =>
      passive.modifier == null
          ? '버프/디버프 부여'
          : '버프/디버프 부여: ${_modifierLabel(passive.modifier!)}',
    BattlePassiveEffectType.grantStatus =>
      '상태이상 부여: ${_statusLabel(passive.statusType)}'
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

String _skillTargetLabel(BattleSkillTargetType targetType) {
  return switch (targetType) {
    BattleSkillTargetType.randomEnemy => '대상: 무작위 적 1명',
    BattleSkillTargetType.self => '대상: 자신',
    BattleSkillTargetType.randomAlly => '대상: 무작위 아군 1명',
    BattleSkillTargetType.allEnemies => '대상: 모든 적',
    BattleSkillTargetType.allAllies => '대상: 모든 아군',
  };
}

String _skillEffectLabel(BattleSkillDefinition skill) {
  return switch (skill.effectType) {
    BattleSkillEffectType.damage =>
      '효과: ${_damageSchoolLabel(skill.school)} 피해 x${skill.powerMultiplier.toStringAsFixed(2)}',
    BattleSkillEffectType.heal => '효과: 회복 +${skill.flatPower}',
    BattleSkillEffectType.grantModifier =>
      skill.modifier == null
          ? '효과: 버프/디버프 부여'
          : '효과: ${_modifierLabel(skill.modifier!)} / ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantStatus =>
      '효과: ${_statusLabel(skill.statusType)}'
          '${skill.flatPower <= 0 ? '' : ' ${skill.flatPower}'}'
          ' / ${skill.durationLifecycles}행동',
    BattleSkillEffectType.grantShield =>
      '효과: 보호막 +${skill.shieldValue > 0 ? skill.shieldValue : skill.flatPower}',
  };
}

String _damageSchoolLabel(DamageSchool school) {
  return switch (school) {
    DamageSchool.any => '일반',
    DamageSchool.physical => '물리',
    DamageSchool.magical => '마법',
  };
}

String _statusLabel(BattleStatusType? statusType) {
  return switch (statusType) {
    BattleStatusType.poison => '중독',
    BattleStatusType.stun => '기절',
    null => '상태이상',
  };
}

String _passiveTriggerLabel(BattlePassiveTrigger trigger) {
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
