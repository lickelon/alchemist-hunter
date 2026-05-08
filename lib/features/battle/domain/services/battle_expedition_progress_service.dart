import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';

class BattleExpeditionSyncResult {
  const BattleExpeditionSyncResult({
    required this.battle,
    this.consumedPotionStacks = const <String, int>{},
  });

  final BattleState battle;
  final Map<String, int> consumedPotionStacks;
}

class BattleExpeditionProgressService {
  const BattleExpeditionProgressService();

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
      return BattleExpeditionSyncResult(battle: state.battle);
    }

    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    final Map<String, int> consumedPotionStacks = <String, int>{};

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
          clearCurrentBattle: true,
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
      BattlePlaybackState? currentBattle = expedition.currentBattle;
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
          final BattleEncounterResolution resolution = battleExpeditionResolver
              .resolveEncounter(
                state: state,
                stageId: stageId,
                battleCatalogRepository: battleCatalogRepository,
              );
          resolution.consumedPotionLoadout.forEach((
            String stackKey,
            int quantity,
          ) {
            consumedPotionStacks[stackKey] =
                (consumedPotionStacks[stackKey] ?? 0) + quantity;
          });
          if (resolution.playback == null) {
            nextStatus = BattleExpeditionStatus.idle;
            nextPhaseProgress = Duration.zero;
            currentBattle = null;
            break;
          }
          nextStatus = BattleExpeditionStatus.battling;
          nextPhaseProgress = Duration.zero;
          currentBattle = resolution.playback;
          continue;
        }

        if (nextStatus == BattleExpeditionStatus.battling) {
          final BattlePlaybackState? playback = currentBattle;
          if (playback == null) {
            nextStatus = BattleExpeditionStatus.searching;
            nextPhaseProgress = Duration.zero;
            continue;
          }
          final Duration totalBattleDuration = playback.totalDuration(
            actionInterval: battleActionInterval,
          );
          final Duration remainingBattle =
              totalBattleDuration - nextPhaseProgress;
          final Duration consumed = _minDuration(
            remainingElapsed,
            remainingBattle,
          );
          nextPhaseProgress += consumed;
          remainingElapsed -= consumed;
          cursorTime = cursorTime.add(
            _unscaledDuration(consumed, speedMultiplier),
          );
          if (nextPhaseProgress < totalBattleDuration) {
            break;
          }
          pendingClaim = _mergePendingClaim(
            pendingClaim,
            playback.pendingClaim,
          );
          recentLogs = _mergeRecentLogs(
            recentLogs,
            playback.completeAt(cursorTime),
          );
          nextStatus = BattleExpeditionStatus.searching;
          nextPhaseProgress = Duration.zero;
          currentBattle = null;
          continue;
        }

        break;
      }

      nextExpeditions[stageId] = expedition.copyWith(
        status: nextStatus,
        lastProgressedAt: now,
        phaseProgress: nextPhaseProgress,
        currentBattle: currentBattle,
        clearCurrentBattle: currentBattle == null,
        pendingClaim: pendingClaim,
        recentLogs: recentLogs,
      );
    });

    return BattleExpeditionSyncResult(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
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
    final Map<String, int> mergedXp = <String, int>{...left.characterXp};
    right.characterXp.forEach((String key, int value) {
      mergedXp[key] = (mergedXp[key] ?? 0) + value;
    });
    return BattlePendingClaim(
      materials: mergedMaterials,
      gold: left.gold + right.gold,
      essence: left.essence + right.essence,
      characterXp: mergedXp,
      hasSuccessfulBattle:
          left.hasSuccessfulBattle || right.hasSuccessfulBattle,
    );
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
    BattleLogEntry? next,
  ) {
    if (next == null) {
      return current;
    }
    final List<BattleLogEntry> merged = <BattleLogEntry>[next, ...current];
    if (merged.length <= 10) {
      return merged;
    }
    return merged.sublist(0, 10);
  }
}
