import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class BattleEncounterSelection {
  const BattleEncounterSelection({
    required this.definition,
    required this.enemies,
    required this.dropTable,
  });

  final BattleStageEncounterDefinition definition;
  final List<BattleEnemyDefinition> enemies;
  final BattleDropTable dropTable;
}

class BattleEncounterService {
  const BattleEncounterService();

  BattleEncounterSelection selectEncounter({
    required BattleStageDefinition stage,
    required BattleCatalogRepository battleCatalogRepository,
    required Random random,
  }) {
    final BattleStageEncounterDefinition definition = _rollDefinition(
      stage.encounters,
      random,
    );
    return BattleEncounterSelection(
      definition: definition,
      enemies: battleCatalogRepository.enemyDefinitionsForSet(
        definition.enemySetId,
      ),
      dropTable: battleCatalogRepository.dropTableForEnemySet(
        stageId: stage.id,
        enemySetId: definition.enemySetId,
      ),
    );
  }

  BattleStageEncounterDefinition _rollDefinition(
    List<BattleStageEncounterDefinition> encounters,
    Random random,
  ) {
    if (encounters.isEmpty) {
      throw StateError('Battle stage must define at least one encounter');
    }
    final double totalChance = encounters.fold<double>(
      0,
      (double total, BattleStageEncounterDefinition encounter) =>
          total + encounter.chance,
    );
    if (totalChance <= 0) {
      return encounters.first;
    }
    final double roll = random.nextDouble() * totalChance;
    double cursor = 0;
    for (final BattleStageEncounterDefinition encounter in encounters) {
      cursor += encounter.chance;
      if (roll <= cursor) {
        return encounter;
      }
    }
    return encounters.last;
  }
}
