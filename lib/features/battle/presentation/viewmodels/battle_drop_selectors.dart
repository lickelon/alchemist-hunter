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

class BattleStageEncounterDropView {
  const BattleStageEncounterDropView({
    required this.name,
    required this.summary,
    required this.chanceLabel,
    required this.enemies,
  });

  final String name;
  final String summary;
  final String chanceLabel;
  final List<BattleEnemyDropView> enemies;
}

class BattleStageDropOverviewView {
  const BattleStageDropOverviewView({
    required this.stageName,
    required this.recommendedPower,
    required this.encounterCount,
    required this.enemyCount,
    required this.encounters,
  });

  final String stageName;
  final int recommendedPower;
  final int encounterCount;
  final int enemyCount;
  final List<BattleStageEncounterDropView> encounters;
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
      final List<BattleStageEncounterDefinition> encounters = battleCatalog
          .encounterDefinitionsForStage(stageId);
      final List<BattleEnemyDefinition> uniqueEnemies = battleCatalog
          .enemyDefinitionsForStage(stageId);

      return BattleStageDropOverviewView(
        stageName: battleStageDisplayName(stage.id, fallback: stage.name),
        recommendedPower: stage.recommendedPower,
        encounterCount: encounters.length,
        enemyCount: uniqueEnemies.length,
        encounters: encounters
            .map((BattleStageEncounterDefinition encounter) {
              final List<BattleEnemyDefinition> enemies = battleCatalog
                  .enemyDefinitionsForSet(encounter.enemySetId);
              return BattleStageEncounterDropView(
                name: encounter.name,
                summary: encounter.summary,
                chanceLabel: _chanceLabel(encounter.chance),
                enemies: enemies
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
                                    materialCatalog.materialName(
                                      drop.materialId,
                                    ) ??
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
                                    materialCatalog.materialName(
                                      drop.materialId,
                                    ) ??
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
    'MP ${stats.maxMp} / MP재생 ${stats.mpRegen}',
  ];
}

List<String> _enemyEffectLines(BattleEnemyDefinition enemy) {
  final List<String> lines = <String>[
    ...enemy.modifiers.map(_modifierLabel),
    ...enemy.passives.map(_passiveLabel),
    ...enemy.skills.map(_skillLabel),
  ];
  if (lines.isEmpty) {
    return const <String>['특수 효과 없음'];
  }
  return lines;
}

String _skillLabel(BattleSkillDefinition skill) {
  return '스킬: ${skill.name} / MP 최대 시 전량 소비';
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

String _signedChanceLabel(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}
