import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_catalog_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_stage_definitions.dart'
    as stage_catalog;
import 'package:alchemist_hunter/features/battle/data/catalogs/encounters/battle_enemy_set_definitions.dart'
    as encounter_catalog;
import 'package:alchemist_hunter/features/battle/data/catalogs/enemies/battle_enemy_definitions.dart'
    as enemy_catalog;
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const StaticBattleCatalogRepository repository =
      StaticBattleCatalogRepository();

  test('raw battle catalogs stay behind DTO boundaries', () {
    final BattleStageDefinitionDto stageDto =
        stage_catalog.battleStageDefinitionDtos['stage_1']!;
    final BattleEnemySetDefinitionDto enemySetDto = encounter_catalog
        .battleEnemySetDefinitionDtos[stageDto.encounters.first.enemySetId]!;
    final BattleEnemyDefinitionDto enemyDto =
        enemy_catalog.battleEnemyDefinitionDtos[enemySetDto.enemyIds.first]!;

    expect(stageDto.searchDurationSeconds, greaterThan(0));
    expect(enemySetDto.enemyIds, isNotEmpty);
    expect(enemyDto.stats.maxHp, greaterThan(0));

    final BattleStageDefinition stage = repository.stageDefinition(stageDto.id);
    expect(
      stage.searchDuration,
      Duration(seconds: stageDto.searchDurationSeconds),
    );
    expect(stage.encounters.first.id, stageDto.encounters.first.id);
  });

  test('stage enemy catalog exposes executable active skills', () {
    for (final String stageId in <String>[
      'stage_1',
      'stage_2',
      'stage_3',
      'stage_4',
      'stage_5',
    ]) {
      final List<BattleEnemyDefinition> enemies = repository
          .enemyDefinitionsForStage(stageId);
      final List<BattleEnemyDefinition> skilledEnemies = enemies
          .where((BattleEnemyDefinition enemy) => enemy.skills.isNotEmpty)
          .toList(growable: false);

      expect(skilledEnemies, isNotEmpty, reason: stageId);
      for (final BattleEnemyDefinition enemy in skilledEnemies) {
        expect(enemy.stats.maxMp, greaterThan(0), reason: enemy.id);
        expect(enemy.stats.mpRegen, greaterThan(0), reason: enemy.id);
      }
    }
  });

  test('stage enemy catalog keeps diversified encounter pools', () {
    for (final String stageId in <String>[
      'stage_1',
      'stage_2',
      'stage_3',
      'stage_4',
      'stage_5',
    ]) {
      final BattleStageDefinition stage = repository.stageDefinition(stageId);
      final Set<String> enemyIds = repository
          .enemyDefinitionsForStage(stageId)
          .map((BattleEnemyDefinition enemy) => enemy.id)
          .toSet();
      final double totalChance = stage.encounters.fold<double>(
        0,
        (double total, BattleStageEncounterDefinition encounter) =>
            total + encounter.chance,
      );

      expect(
        stage.encounters.length,
        greaterThanOrEqualTo(10),
        reason: stageId,
      );
      expect(enemyIds.length, greaterThanOrEqualTo(5), reason: stageId);
      expect(totalChance, closeTo(1, 0.001), reason: stageId);
      for (final BattleStageEncounterDefinition encounter in stage.encounters) {
        expect(
          repository.enemyDefinitionsForSet(encounter.enemySetId),
          isNotEmpty,
          reason: encounter.id,
        );
      }
    }
  });

  test('enemy active skills cover damage support status and shield roles', () {
    final List<BattleEnemyDefinition> enemies = <String>[
      'stage_1',
      'stage_2',
      'stage_3',
      'stage_4',
      'stage_5',
    ].expand(repository.enemyDefinitionsForStage).toSet().toList();
    final Set<BattleSkillEffectType> effectTypes = enemies
        .expand((BattleEnemyDefinition enemy) => enemy.skills)
        .map((BattleSkillDefinition skill) => skill.effectType)
        .toSet();
    final Set<BattleSkillTargetType> targetTypes = enemies
        .expand((BattleEnemyDefinition enemy) => enemy.skills)
        .map((BattleSkillDefinition skill) => skill.targetType)
        .toSet();

    expect(effectTypes, contains(BattleSkillEffectType.damage));
    expect(effectTypes, contains(BattleSkillEffectType.heal));
    expect(effectTypes, contains(BattleSkillEffectType.grantModifier));
    expect(effectTypes, contains(BattleSkillEffectType.grantStatus));
    expect(effectTypes, contains(BattleSkillEffectType.grantShield));
    expect(targetTypes, contains(BattleSkillTargetType.randomEnemy));
    expect(targetTypes, contains(BattleSkillTargetType.allEnemies));
    expect(targetTypes, contains(BattleSkillTargetType.allAllies));
    expect(targetTypes, contains(BattleSkillTargetType.self));
  });
}
