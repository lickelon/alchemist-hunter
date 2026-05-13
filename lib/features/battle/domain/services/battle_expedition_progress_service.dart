import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_progress_helpers.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class BattleExpeditionSyncResult {
  const BattleExpeditionSyncResult({
    required this.battle,
    required this.characters,
    this.consumedPotionStacks = const <String, int>{},
  });

  final BattleState battle;
  final CharactersState characters;
  final Map<String, int> consumedPotionStacks;
}

class BattleExpeditionProgressService {
  const BattleExpeditionProgressService({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattleExpeditionProgressHelpers helpers =
        const BattleExpeditionProgressHelpers(),
  }) : _characterProgressionService = characterProgressionService,
       _helpers = helpers;

  final CharacterProgressionService _characterProgressionService;
  final BattleExpeditionProgressHelpers _helpers;

  BattleExpeditionSyncResult syncExpeditions({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
    required Duration battleActionInterval,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (state.battle.stageExpeditions.isEmpty) {
      return BattleExpeditionSyncResult(
        battle: state.battle,
        characters: state.characters,
      );
    }

    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    final Map<String, int> consumedPotionStacks = <String, int>{};
    CharactersState nextCharacters = state.characters;

    state.battle.stageExpeditions.forEach((
      String stageId,
      BattleExpeditionState expedition,
    ) {
      final List<String> assignedCharacterIds =
          state.battle.stageAssignments[stageId] ?? const <String>[];
      if (assignedCharacterIds.isEmpty) {
        nextExpeditions[stageId] = expedition.copyWith(
          status: BattleExpeditionStatus.idle,
          lastProgressedAt: now,
          phaseProgress: Duration.zero,
          clearRunState: true,
          clearPausedStatus: true,
        );
        return;
      }
      if (!expedition.isActive) {
        return;
      }

      final BattleStageDefinition stageDefinition = battleCatalogRepository
          .stageDefinition(stageId);
      final DateTime baseTime = _helpers.laterOf(
        syncFrom,
        expedition.lastProgressedAt ?? syncFrom,
      );
      if (!now.isAfter(baseTime)) {
        nextExpeditions[stageId] = expedition.copyWith(lastProgressedAt: now);
        return;
      }

      BattleExpeditionStatus nextStatus = expedition.status;
      Duration nextPhaseProgress = expedition.phaseProgress;
      BattleRunState? runState = expedition.runState;
      BattlePendingClaim pendingClaim = expedition.pendingClaim;
      List<BattleLogEntry> recentLogs = expedition.recentLogs;
      Duration remainingElapsed = _helpers.scaledDuration(
        now.difference(baseTime),
        speedMultiplier,
      );
      DateTime cursorTime = baseTime;

      while (remainingElapsed > Duration.zero) {
        if (nextStatus == BattleExpeditionStatus.searching) {
          final Duration remainingSearch =
              stageDefinition.searchDuration - nextPhaseProgress;
          final Duration consumed = _helpers.minDuration(
            remainingElapsed,
            remainingSearch,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _helpers.unscaledDuration(consumed, speedMultiplier),
          );
          if (nextPhaseProgress < stageDefinition.searchDuration) {
            break;
          }
          if (runState != null && runState.allies.isNotEmpty) {
            runState = runState.copyWith(
              allies: _helpers.applySearchRecovery(runState.allies),
            );
          }
          final BattleEncounterResolution resolution = battleExpeditionResolver
              .resolveEncounter(
                state: state.copyWith(characters: nextCharacters),
                stageId: stageId,
                currentRunState: runState,
                battleCatalogRepository: battleCatalogRepository,
              );
          resolution.consumedPotionLoadout.forEach((
            String stackKey,
            int quantity,
          ) {
            consumedPotionStacks[stackKey] =
                (consumedPotionStacks[stackKey] ?? 0) + quantity;
          });
          if (resolution.runState == null) {
            nextStatus = BattleExpeditionStatus.idle;
            nextPhaseProgress = Duration.zero;
            runState = null;
            break;
          }
          runState = resolution.runState;
          nextStatus = BattleExpeditionStatus.battling;
          nextPhaseProgress = Duration.zero;
          continue;
        }

        if (nextStatus == BattleExpeditionStatus.battling) {
          final BattleEncounterRuntimeState? encounter =
              runState?.currentEncounter;
          if (runState == null || encounter == null) {
            nextStatus = BattleExpeditionStatus.searching;
            nextPhaseProgress = Duration.zero;
            continue;
          }
          final Duration consumed = _helpers.minDuration(
            remainingElapsed,
            battleActionInterval - nextPhaseProgress,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _helpers.unscaledDuration(consumed, speedMultiplier),
          );
          if (nextPhaseProgress < battleActionInterval) {
            break;
          }
          nextPhaseProgress = Duration.zero;
          final int potionBoost = encounter.appliedPotionLoadout.values
              .fold<int>(0, (int total, int value) => total + value);
          final step = battleExpeditionResolver.runEncounterStep(
            allies: runState.allies,
            encounter: encounter,
            potionBoost: potionBoost,
          );
          runState = runState.copyWith(
            allies: step.allies,
            currentEncounter: step.encounter,
          );
          if (!step.ended) {
            continue;
          }
          if (step.success) {
            final BattleDropTable dropTable = battleCatalogRepository
                .dropTableForEnemySet(
                  stageId: stageId,
                  enemySetId: step.encounter.enemySetId,
                );
            final Map<String, int> materials = battleExpeditionResolver
                .resolveRewards(success: true, table: dropTable);
            pendingClaim = _helpers.mergePendingClaim(
              pendingClaim,
              BattlePendingClaim(
                materials: materials,
                gold: stageDefinition.goldSuccess,
                essence: stageDefinition.essenceSuccess,
                hasSuccessfulBattle: true,
              ),
            );
            nextCharacters = _characterProgressionService.grantBattleXp(
              state: nextCharacters,
              xpGain: stageDefinition.xpSuccessBase,
              participantIds: assignedCharacterIds,
            );
            recentLogs = _helpers.mergeRecentLogs(
              recentLogs,
              BattleLogEntry(
                resolvedAt: cursorTime,
                encounterName: step.encounter.encounterName,
                encounterIndex: step.encounter.encounterIndex,
                success: true,
                wipedParty: false,
                gold: stageDefinition.goldSuccess,
                essence: stageDefinition.essenceSuccess,
                materials: materials,
                turns: step.encounter.turnInEncounter,
                actions: step.encounter.recentActionLogs,
                usedLoadoutFallback: step.encounter.usedLoadoutFallback,
              ),
            );
            runState = runState.copyWith(
              encounterCount: runState.encounterCount + 1,
              victoryCount: runState.victoryCount + 1,
              clearCurrentEncounter: true,
            );
            nextStatus = BattleExpeditionStatus.searching;
            continue;
          }
          recentLogs = _helpers.mergeRecentLogs(
            recentLogs,
            BattleLogEntry(
              resolvedAt: cursorTime,
              encounterName: step.encounter.encounterName,
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
            runState = runState.copyWith(
              wipeCount: runState.wipeCount + 1,
              clearCurrentEncounter: true,
            );
            nextStatus = BattleExpeditionStatus.recovering;
          } else {
            runState = runState.copyWith(clearCurrentEncounter: true);
            nextStatus = BattleExpeditionStatus.searching;
          }
          continue;
        }

        if (nextStatus == BattleExpeditionStatus.recovering) {
          final Duration remainingRecovery =
              stageDefinition.recoveryDuration - nextPhaseProgress;
          final Duration consumed = _helpers.minDuration(
            remainingElapsed,
            remainingRecovery,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _helpers.unscaledDuration(consumed, speedMultiplier),
          );
          if (nextPhaseProgress < stageDefinition.recoveryDuration) {
            break;
          }
          final BattleEncounterResolution resolution = battleExpeditionResolver
              .resolveEncounter(
                state: state.copyWith(characters: nextCharacters),
                stageId: stageId,
                currentRunState: const BattleRunState(),
                battleCatalogRepository: battleCatalogRepository,
              );
          if (resolution.runState == null) {
            nextStatus = BattleExpeditionStatus.idle;
            nextPhaseProgress = Duration.zero;
            runState = null;
            break;
          }
          runState = BattleRunState(
            encounterCount: 0,
            victoryCount: 0,
            wipeCount: (runState?.wipeCount ?? 0),
            allies: resolution.runState!.allies,
          );
          nextStatus = BattleExpeditionStatus.searching;
          nextPhaseProgress = Duration.zero;
          continue;
        }

        break;
      }

      nextExpeditions[stageId] = expedition.copyWith(
        status: nextStatus,
        lastProgressedAt: now,
        phaseProgress: nextPhaseProgress,
        runState: runState,
        pendingClaim: pendingClaim,
        recentLogs: recentLogs,
      );
    });

    return BattleExpeditionSyncResult(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
      characters: nextCharacters,
      consumedPotionStacks: consumedPotionStacks,
    );
  }
}
