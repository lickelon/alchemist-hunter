import 'package:alchemist_hunter/features/battle/data/catalogs/battle_enemy_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_stage_dtos.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';

part 'battle_catalog_table_drops.dart';
part 'battle_catalog_table_factory.dart';
part 'battle_catalog_table_validation.dart';

class BattleCatalogTables {
  BattleCatalogTables({
    required this.enemyDefinitions,
    required this.enemySetDefinitions,
    required this.stageDefinitions,
    required this.stageCatalog,
  }) {
    _validate();
  }

  factory BattleCatalogTables.fromDtos({
    required Map<String, BattleEnemyDefinitionDto> enemyDtos,
    required Map<String, BattleEnemySetDefinitionDto> enemySetDtos,
    required Map<String, BattleStageDefinitionDto> stageDtos,
    required List<String> stageCatalog,
  }) {
    return _battleCatalogTablesFromDtos(
      enemyDtos: enemyDtos,
      enemySetDtos: enemySetDtos,
      stageDtos: stageDtos,
      stageCatalog: stageCatalog,
    );
  }

  final Map<String, BattleEnemyDefinition> enemyDefinitions;
  final Map<String, BattleEnemySetDefinition> enemySetDefinitions;
  final Map<String, BattleStageDefinition> stageDefinitions;
  final List<String> stageCatalog;

  BattleStageDefinition stageDefinition(String stageId) {
    final BattleStageDefinition? definition = stageDefinitions[stageId];
    if (definition == null) {
      throw StateError('Unknown stage: $stageId');
    }
    return definition;
  }

  BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
    final BattleEnemySetDefinition? definition =
        enemySetDefinitions[enemySetId];
    if (definition == null) {
      throw StateError('Unknown enemy set: $enemySetId');
    }
    return definition;
  }

  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) {
    return stageDefinition(stageId).encounters;
  }

  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
    final BattleEnemySetDefinition enemySet = enemySetDefinition(enemySetId);
    return enemySet.enemyIds
        .map((String enemyId) {
          final BattleEnemyDefinition? definition = enemyDefinitions[enemyId];
          if (definition == null) {
            throw StateError('Unknown enemy: $enemyId');
          }
          return definition;
        })
        .toList(growable: false);
  }

  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
    final Map<String, BattleEnemyDefinition> uniqueEnemies =
        <String, BattleEnemyDefinition>{};
    for (final BattleStageEncounterDefinition encounter
        in encounterDefinitionsForStage(stageId)) {
      for (final BattleEnemyDefinition enemy in enemyDefinitionsForSet(
        encounter.enemySetId,
      )) {
        uniqueEnemies[enemy.id] = enemy;
      }
    }
    return uniqueEnemies.values.toList(growable: false);
  }

  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) {
    return _dropTableFromEnemies(
      stageId: stageId,
      enemies: enemyDefinitionsForSet(enemySetId),
    );
  }

  BattleDropTable stageDropTable(String stageId) {
    return _dropTableFromEnemies(
      stageId: stageId,
      enemies: enemyDefinitionsForStage(stageId),
    );
  }
}
