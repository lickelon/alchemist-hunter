part of 'battle_expedition_tick_service.dart';

extension _BattleExpeditionTickSteps on BattleExpeditionTickService {
  bool _tickSearching(_BattleExpeditionTickFrame frame) {
    frame.advancePhase(
      targetDuration: frame.stageDefinition.searchDuration,
      helpers: _helpers,
    );
    if (frame.nextPhaseProgress < frame.stageDefinition.searchDuration) {
      return false;
    }
    if (frame.runState != null && frame.runState!.allies.isNotEmpty) {
      frame.runState = frame.runState!.copyWith(
        allies: _helpers.applySearchRecovery(frame.runState!.allies),
      );
    }
    final BattleEncounterResolution resolution = frame.battleExpeditionResolver
        .resolveEncounter(
          state: frame.state.copyWith(characters: frame.nextCharacters),
          stageId: frame.stageId,
          currentRunState: frame.runState,
          battleCatalogRepository: frame.battleCatalogRepository,
        );
    frame.recordConsumedPotionLoadout(resolution.consumedPotionLoadout);
    if (resolution.runState == null) {
      frame.nextStatus = BattleExpeditionStatus.idle;
      frame.nextPhaseProgress = Duration.zero;
      frame.runState = null;
      return false;
    }
    frame.runState = resolution.runState;
    frame.nextStatus = BattleExpeditionStatus.battling;
    frame.nextPhaseProgress = Duration.zero;
    return true;
  }

  bool _tickBattling(_BattleExpeditionTickFrame frame) {
    final BattleRunState? runState = frame.runState;
    final BattleEncounterRuntimeState? encounter = runState?.currentEncounter;
    if (runState == null || encounter == null) {
      frame.nextStatus = BattleExpeditionStatus.searching;
      frame.nextPhaseProgress = Duration.zero;
      return true;
    }

    frame.advancePhase(
      targetDuration: frame.battleActionInterval,
      helpers: _helpers,
    );
    if (frame.nextPhaseProgress < frame.battleActionInterval) {
      return false;
    }
    frame.nextPhaseProgress = Duration.zero;

    final int potionBoost = encounter.appliedPotionLoadout.values.fold<int>(
      0,
      (int total, int value) => total + value,
    );
    final step = frame.battleExpeditionResolver.runEncounterStep(
      allies: runState.allies,
      encounter: encounter,
      potionBoost: potionBoost,
    );
    frame.runState = runState.copyWith(
      allies: step.allies,
      currentEncounter: step.encounter,
    );
    if (!step.ended) {
      return true;
    }
    if (step.success) {
      _applySuccessfulEncounter(frame, step);
      return true;
    }
    _applyFailedEncounter(frame, step);
    return true;
  }

  bool _tickRecovering(_BattleExpeditionTickFrame frame) {
    frame.advancePhase(
      targetDuration: frame.stageDefinition.recoveryDuration,
      helpers: _helpers,
    );
    if (frame.nextPhaseProgress < frame.stageDefinition.recoveryDuration) {
      return false;
    }
    final BattleEncounterResolution resolution = frame.battleExpeditionResolver
        .resolveEncounter(
          state: frame.state.copyWith(characters: frame.nextCharacters),
          stageId: frame.stageId,
          currentRunState: const BattleRunState(),
          battleCatalogRepository: frame.battleCatalogRepository,
        );
    if (resolution.runState == null) {
      frame.nextStatus = BattleExpeditionStatus.idle;
      frame.nextPhaseProgress = Duration.zero;
      frame.runState = null;
      return false;
    }
    frame.runState = BattleRunState(
      encounterCount: 0,
      victoryCount: 0,
      wipeCount: frame.runState?.wipeCount ?? 0,
      allies: resolution.runState!.allies,
    );
    frame.nextStatus = BattleExpeditionStatus.searching;
    frame.nextPhaseProgress = Duration.zero;
    return true;
  }
}
