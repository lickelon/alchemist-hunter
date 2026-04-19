import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';
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
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
    ConfigureBattleAssignmentUseCase configureBattleAssignmentUseCase =
        const ConfigureBattleAssignmentUseCase(),
    BattleCatalogRepository? battleCatalogRepository,
  }) : _autoController = BattleAutoController(
         session,
         battleService: battleService,
         battleExpeditionUseCase: battleExpeditionUseCase,
         battleCatalogRepository:
             battleCatalogRepository ?? const _MissingBattleCatalogRepository(),
       ),
       _expeditionController = BattleExpeditionController(
         session,
         battleExpeditionUseCase: battleExpeditionUseCase,
       ),
       _assignmentController = BattleAssignmentController(
         session,
         configureBattleAssignmentUseCase: configureBattleAssignmentUseCase,
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
}

class _MissingBattleCatalogRepository implements BattleCatalogRepository {
  const _MissingBattleCatalogRepository();

  @override
  BattleDropTable dropTable(String stageId) {
    throw StateError('BattleCatalogRepository is required');
  }

  @override
  List<String> stageCatalog() {
    throw StateError('BattleCatalogRepository is required');
  }
}

final Provider<BattleController> battleControllerProvider =
    Provider<BattleController>((Ref ref) {
      return BattleController(
        ref.read(sessionControllerProvider.notifier),
        battleService: ref.read(battleServiceProvider),
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });
