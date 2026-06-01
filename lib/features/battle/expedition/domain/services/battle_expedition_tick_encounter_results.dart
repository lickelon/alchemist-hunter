part of 'battle_expedition_tick_service.dart';

extension _BattleExpeditionTickEncounterResults on BattleExpeditionTickService {
  void _applySuccessfulEncounter(
    _BattleExpeditionTickFrame frame,
    BattleEncounterStepResult step,
  ) {
    final BattleDropTable dropTable = frame.battleCatalogRepository
        .dropTableForEnemySet(
          stageId: frame.stageId,
          enemySetId: step.encounter.enemySetId,
        );
    final Map<String, int> materials = frame.battleExpeditionResolver
        .resolveRewards(success: true, table: dropTable);
    frame.pendingClaim = _helpers.mergePendingClaim(
      frame.pendingClaim,
      BattlePendingClaim(
        materials: materials,
        gold: frame.stageDefinition.goldSuccess,
        essence: frame.stageDefinition.essenceSuccess,
        xp: frame.stageDefinition.xpSuccessBase,
        victoryCount: 1,
        hasSuccessfulBattle: true,
      ),
    );
    frame.nextCharacters = _characterProgressionService.grantBattleXp(
      state: frame.nextCharacters,
      xpGain: frame.stageDefinition.xpSuccessBase,
      participantIds: frame.assignedCharacterIds,
    );
    frame.nextProgress = _battleProgressionService.applyStageEncounterResult(
      currentProgress: frame.nextProgress,
      stage: frame.stageDefinition,
      success: true,
      battleCatalogRepository: frame.battleCatalogRepository,
    );
    frame.recentLogs = _helpers.mergeRecentLogs(
      frame.recentLogs,
      BattleLogEntry(
        resolvedAt: frame.cursorTime,
        encounterIndex: step.encounter.encounterIndex,
        success: true,
        wipedParty: false,
        gold: frame.stageDefinition.goldSuccess,
        essence: frame.stageDefinition.essenceSuccess,
        materials: materials,
        turns: step.encounter.turnInEncounter,
        actions: step.encounter.recentActionLogs,
        usedLoadoutFallback: step.encounter.usedLoadoutFallback,
      ),
    );
    frame.runState = frame.runState!.copyWith(
      encounterCount: frame.runState!.encounterCount + 1,
      victoryCount: frame.runState!.victoryCount + 1,
      clearCurrentEncounter: true,
    );
    frame.nextStatus = BattleExpeditionStatus.searching;
  }

  void _applyFailedEncounter(
    _BattleExpeditionTickFrame frame,
    BattleEncounterStepResult step,
  ) {
    frame.nextProgress = _battleProgressionService.applyStageEncounterResult(
      currentProgress: frame.nextProgress,
      stage: frame.stageDefinition,
      success: false,
      battleCatalogRepository: frame.battleCatalogRepository,
    );
    frame.recentLogs = _helpers.mergeRecentLogs(
      frame.recentLogs,
      BattleLogEntry(
        resolvedAt: frame.cursorTime,
        encounterIndex: step.encounter.encounterIndex,
        success: false,
        wipedParty: step.wiped,
        gold: 0,
        essence: 0,
        materials: const <String, int>{},
        turns: step.encounter.turnInEncounter,
        actions: step.encounter.recentActionLogs,
        usedLoadoutFallback: step.encounter.usedLoadoutFallback,
      ),
    );
    if (step.wiped) {
      frame.pendingClaim = _helpers.mergePendingClaim(
        frame.pendingClaim,
        const BattlePendingClaim(wipeCount: 1),
      );
      frame.runState = frame.runState!.copyWith(
        wipeCount: frame.runState!.wipeCount + 1,
        clearCurrentEncounter: true,
      );
      frame.nextStatus = BattleExpeditionStatus.recovering;
    } else {
      frame.runState = frame.runState!.copyWith(clearCurrentEncounter: true);
      frame.nextStatus = BattleExpeditionStatus.searching;
    }
  }
}
