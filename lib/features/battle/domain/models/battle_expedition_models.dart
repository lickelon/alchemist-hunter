import 'package:flutter/foundation.dart';

import 'battle_playback_models.dart';
import 'battle_result_models.dart';

enum BattleExpeditionStatus { idle, searching, battling, recovering, paused }

@immutable
class BattleEncounterRuntimeState {
  const BattleEncounterRuntimeState({
    required this.encounterId,
    required this.encounterName,
    required this.encounterIndex,
    required this.enemySetId,
    required this.enemies,
    this.appliedPotionLoadout = const <String, int>{},
    this.pendingActorIds = const <String>[],
    this.recentActionLogs = const <BattleActionLog>[],
    this.turnInEncounter = 0,
    this.usedLoadoutFallback = false,
  });

  final String encounterId;
  final String encounterName;
  final int encounterIndex;
  final String enemySetId;
  final List<BattleRunUnitState> enemies;
  final Map<String, int> appliedPotionLoadout;
  final List<String> pendingActorIds;
  final List<BattleActionLog> recentActionLogs;
  final int turnInEncounter;
  final bool usedLoadoutFallback;

  BattleEncounterRuntimeState copyWith({
    List<BattleRunUnitState>? enemies,
    Map<String, int>? appliedPotionLoadout,
    List<String>? pendingActorIds,
    List<BattleActionLog>? recentActionLogs,
    int? turnInEncounter,
    bool? usedLoadoutFallback,
  }) {
    return BattleEncounterRuntimeState(
      encounterId: encounterId,
      encounterName: encounterName,
      encounterIndex: encounterIndex,
      enemySetId: enemySetId,
      enemies: enemies ?? this.enemies,
      appliedPotionLoadout: appliedPotionLoadout ?? this.appliedPotionLoadout,
      pendingActorIds: pendingActorIds ?? this.pendingActorIds,
      recentActionLogs: recentActionLogs ?? this.recentActionLogs,
      turnInEncounter: turnInEncounter ?? this.turnInEncounter,
      usedLoadoutFallback: usedLoadoutFallback ?? this.usedLoadoutFallback,
    );
  }
}

@immutable
class BattleRunState {
  const BattleRunState({
    this.encounterCount = 0,
    this.victoryCount = 0,
    this.wipeCount = 0,
    this.allies = const <BattleRunUnitState>[],
    this.currentEncounter,
  });

  final int encounterCount;
  final int victoryCount;
  final int wipeCount;
  final List<BattleRunUnitState> allies;
  final BattleEncounterRuntimeState? currentEncounter;

  BattleRunState copyWith({
    int? encounterCount,
    int? victoryCount,
    int? wipeCount,
    List<BattleRunUnitState>? allies,
    BattleEncounterRuntimeState? currentEncounter,
    bool clearCurrentEncounter = false,
  }) {
    return BattleRunState(
      encounterCount: encounterCount ?? this.encounterCount,
      victoryCount: victoryCount ?? this.victoryCount,
      wipeCount: wipeCount ?? this.wipeCount,
      allies: allies ?? this.allies,
      currentEncounter: clearCurrentEncounter
          ? null
          : currentEncounter ?? this.currentEncounter,
    );
  }
}

@immutable
class BattleExpeditionState {
  const BattleExpeditionState({
    required this.status,
    required this.lastProgressedAt,
    required this.phaseProgress,
    this.runState,
    this.pausedStatus,
    this.pendingClaim = const BattlePendingClaim(),
    this.recentLogs = const <BattleLogEntry>[],
  });

  final BattleExpeditionStatus status;
  final DateTime? lastProgressedAt;
  final Duration phaseProgress;
  final BattleRunState? runState;
  final BattleExpeditionStatus? pausedStatus;
  final BattlePendingClaim pendingClaim;
  final List<BattleLogEntry> recentLogs;

  bool get isActive =>
      status == BattleExpeditionStatus.searching ||
      status == BattleExpeditionStatus.battling ||
      status == BattleExpeditionStatus.recovering;

  BattleExpeditionState copyWith({
    BattleExpeditionStatus? status,
    DateTime? lastProgressedAt,
    Duration? phaseProgress,
    BattleRunState? runState,
    bool clearRunState = false,
    BattleExpeditionStatus? pausedStatus,
    bool clearPausedStatus = false,
    BattlePendingClaim? pendingClaim,
    List<BattleLogEntry>? recentLogs,
  }) {
    return BattleExpeditionState(
      status: status ?? this.status,
      lastProgressedAt: lastProgressedAt ?? this.lastProgressedAt,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      runState: clearRunState ? null : runState ?? this.runState,
      pausedStatus: clearPausedStatus
          ? null
          : pausedStatus ?? this.pausedStatus,
      pendingClaim: pendingClaim ?? this.pendingClaim,
      recentLogs: recentLogs ?? this.recentLogs,
    );
  }
}
