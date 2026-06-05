import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class StaticBattleCatalogRepository implements BattleCatalogRepository {
  const StaticBattleCatalogRepository({required BattleCatalogTables catalog})
    : _catalog = catalog;

  final BattleCatalogTables _catalog;

  @override
  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) => _catalog.encounterDefinitionsForStage(stageId);

  @override
  BattleDropTable dropTable(String stageId) => _catalog.stageDropTable(stageId);

  @override
  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) => _catalog.dropTableForEnemySet(stageId: stageId, enemySetId: enemySetId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) =>
      _catalog.enemyDefinitionsForStage(stageId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) =>
      _catalog.enemyDefinitionsForSet(enemySetId);

  @override
  BattleStageDefinition stageDefinition(String stageId) =>
      _catalog.stageDefinition(stageId);

  @override
  List<String> stageCatalog() => _catalog.stageCatalog;

  @override
  BattleCombatJobDefinition combatJobDefinition(String combatJobId) =>
      _catalog.combatJobDefinition(combatJobId);

  @override
  BattleSkillDefinition combatSkillDefinition(String skillId) =>
      _catalog.combatSkillDefinition(skillId);

  @override
  BattlePassiveEffect combatPassiveEffect(String passiveId) =>
      _catalog.combatPassiveEffect(passiveId);
}
