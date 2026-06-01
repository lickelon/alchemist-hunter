import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  final repository = testBattleCatalogRepository;

  test('asset battle catalogs load behind repository boundaries', () {
    final BattleStageDefinition stage = repository.stageDefinition('stage_1');
    final List<BattleEnemyDefinition> enemySet = repository
        .enemyDefinitionsForSet(stage.encounters.first.enemySetId);
    final BattleEnemyDefinition enemy = enemySet.first;

    expect(stage.searchDuration, greaterThan(Duration.zero));
    expect(enemySet, isNotEmpty);
    expect(enemy.stats.maxHp, greaterThan(0));
    expect(testBattleCatalogTables.stageCatalog, contains(stage.id));
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
