part of 'battle_catalog_tables.dart';

BattleDropTable _dropTableFromEnemies({
  required String stageId,
  required List<BattleEnemyDefinition> enemies,
}) {
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}
