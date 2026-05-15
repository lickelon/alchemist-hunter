import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const StaticBattleCatalogRepository repository =
      StaticBattleCatalogRepository();

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
