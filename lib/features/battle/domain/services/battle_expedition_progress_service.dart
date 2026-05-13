import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
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
  }) : _characterProgressionService = characterProgressionService;

  final CharacterProgressionService _characterProgressionService;

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
      final DateTime baseTime = _laterOf(
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
      Duration remainingElapsed = _scaledDuration(
        now.difference(baseTime),
        speedMultiplier,
      );
      DateTime cursorTime = baseTime;

      while (remainingElapsed > Duration.zero) {
        if (nextStatus == BattleExpeditionStatus.searching) {
          final Duration remainingSearch =
              stageDefinition.searchDuration - nextPhaseProgress;
          final Duration consumed = _minDuration(
            remainingElapsed,
            remainingSearch,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _unscaledDuration(consumed, speedMultiplier),
          );
          if (nextPhaseProgress < stageDefinition.searchDuration) {
            break;
          }
          if (runState != null && runState.allies.isNotEmpty) {
            runState = runState.copyWith(
              allies: _applySearchRecovery(runState.allies),
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
          final Duration consumed = _minDuration(
            remainingElapsed,
            battleActionInterval - nextPhaseProgress,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _unscaledDuration(consumed, speedMultiplier),
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
            pendingClaim = _mergePendingClaim(
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
            recentLogs = _mergeRecentLogs(
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
          recentLogs = _mergeRecentLogs(
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
          final Duration consumed = _minDuration(
            remainingElapsed,
            remainingRecovery,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _unscaledDuration(consumed, speedMultiplier),
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

  BattlePendingClaim _mergePendingClaim(
    BattlePendingClaim left,
    BattlePendingClaim right,
  ) {
    final Map<String, int> mergedMaterials = <String, int>{...left.materials};
    right.materials.forEach((String key, int value) {
      mergedMaterials[key] = (mergedMaterials[key] ?? 0) + value;
    });
    return BattlePendingClaim(
      materials: mergedMaterials,
      gold: left.gold + right.gold,
      essence: left.essence + right.essence,
      hasSuccessfulBattle:
          left.hasSuccessfulBattle || right.hasSuccessfulBattle,
    );
  }

  List<BattleRunUnitState> _applySearchRecovery(
    List<BattleRunUnitState> allies,
  ) {
    return allies
        .map((BattleRunUnitState unit) {
          if (!unit.isAlive) {
            return unit;
          }
          final int healing = (unit.maxHp * (0.08 + unit.stats.regen)).ceil();
          final int nextHp = (unit.currentHp + healing).clamp(0, unit.maxHp);
          return unit.copyWith(currentHp: nextHp);
        })
        .toList(growable: false);
  }

  DateTime _laterOf(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Duration _scaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds * multiplier).round());
  }

  Duration _unscaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds / multiplier).round());
  }

  Duration _minDuration(Duration left, Duration right) {
    return left <= right ? left : right;
  }

  List<BattleLogEntry> _mergeRecentLogs(
    List<BattleLogEntry> current,
    BattleLogEntry next,
  ) {
    final List<BattleLogEntry> merged = <BattleLogEntry>[next, ...current];
    if (merged.length <= 10) {
      return merged;
    }
    return merged.sublist(0, 10);
  }
}
