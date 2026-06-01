import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_potion_loadout_use_case.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_assignment_controller.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_auto_controller.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_expedition_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleService> battleServiceProvider = Provider<BattleService>(
  (Ref ref) => BattleService(random: Random(11)),
);

class BattleController {
  BattleController(
    SessionController session, {
    BattleService? battleService,
    Random? encounterRandom,
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
    ConfigureBattleAssignmentUseCase configureBattleAssignmentUseCase =
        const ConfigureBattleAssignmentUseCase(),
    ConfigureBattlePotionLoadoutUseCase configureBattlePotionLoadoutUseCase =
        const ConfigureBattlePotionLoadoutUseCase(),
    BattleCatalogRepository? battleCatalogRepository,
  }) : _autoController = BattleAutoController(
         session,
         battleService: battleService,
         battleExpeditionUseCase: battleExpeditionUseCase,
         encounterRandom: encounterRandom,
         battleCatalogRepository:
             battleCatalogRepository ?? const _MissingBattleCatalogRepository(),
       ),
       _expeditionController = BattleExpeditionController(
         session,
         battleExpeditionUseCase: battleExpeditionUseCase,
         battleCatalogRepository:
             battleCatalogRepository ?? const _MissingBattleCatalogRepository(),
       ),
       _assignmentController = BattleAssignmentController(
         session,
         configureBattleAssignmentUseCase: configureBattleAssignmentUseCase,
         configureBattlePotionLoadoutUseCase:
             configureBattlePotionLoadoutUseCase,
       );

  final BattleAutoController _autoController;
  final BattleExpeditionController _expeditionController;
  final BattleAssignmentController _assignmentController;

  void runAutoBattle(String stageId) => _autoController.runAutoBattle(stageId);

  void startExpedition(String stageId) =>
      _expeditionController.startExpedition(stageId);

  void stopExpedition(String stageId) =>
      _expeditionController.stopExpedition(stageId);

  void claimStageRewards(String stageId) =>
      _expeditionController.claimStageRewards(stageId);

  void toggleStageAssignment(String stageId, String characterId) =>
      _assignmentController.toggleStageAssignment(stageId, characterId);

  void setStagePotionCount(
    String stageId,
    String potionStackKey, {
    required int count,
    required int maxOwned,
  }) => _assignmentController.setPotionCount(
    stageId,
    potionStackKey,
    count: count,
    maxOwned: maxOwned,
  );
}

class _MissingBattleCatalogRepository implements BattleCatalogRepository {
  const _MissingBattleCatalogRepository();

  @override
  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  BattleDropTable dropTable(String stageId) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  List<String> stageCatalog() {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  BattleStageDefinition stageDefinition(String stageId) {
    throw StateError('BattleCatalogRepository is required');
  }
}

final Provider<BattleController> battleControllerProvider =
    Provider<BattleController>((Ref ref) {
      return BattleController(
        ref.read(sessionControllerProvider.notifier),
        battleService: ref.read(battleServiceProvider),
        encounterRandom: Random(17),
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });
