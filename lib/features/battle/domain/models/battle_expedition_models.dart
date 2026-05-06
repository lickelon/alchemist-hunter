import 'package:flutter/foundation.dart';

import 'battle_playback_models.dart';
import 'battle_result_models.dart';

enum BattleExpeditionStatus { idle, searching, battling, paused }

@immutable
class BattlePlaybackState {
  const BattlePlaybackState({
    required this.success,
    required this.turns,
    required this.pendingClaim,
    this.actions = const <BattleActionLog>[],
  });

  final bool success;
  final int turns;
  final BattlePendingClaim pendingClaim;
  final List<BattleActionLog> actions;

  int revealedActionCount({
    required Duration elapsed,
    Duration actionInterval = battleActionInterval,
  }) {
    if (actions.isEmpty) {
      return 0;
    }
    final int revealed =
        elapsed.inMicroseconds ~/ actionInterval.inMicroseconds;
    return revealed.clamp(0, _totalLifecycleCount);
  }

  List<BattleActionLog> revealedActions({
    required Duration elapsed,
    Duration actionInterval = battleActionInterval,
  }) {
    final int revealed = revealedActionCount(
      elapsed: elapsed,
      actionInterval: actionInterval,
    );
    return actions
        .where((BattleActionLog action) => action.lifecycle <= revealed)
        .toList(growable: false);
  }

  Duration totalDuration({Duration actionInterval = battleActionInterval}) {
    final int actionCount = _totalLifecycleCount;
    return Duration(microseconds: actionInterval.inMicroseconds * actionCount);
  }

  int get totalLifecycleCount => _totalLifecycleCount;

  int get _totalLifecycleCount {
    if (actions.isEmpty) {
      return 1;
    }
    return actions
        .map((BattleActionLog action) => action.lifecycle)
        .fold<int>(0, (int max, int value) => value > max ? value : max);
  }

  BattleLogEntry completeAt(DateTime resolvedAt) {
    return BattleLogEntry(
      resolvedAt: resolvedAt,
      success: success,
      gold: pendingClaim.gold,
      essence: pendingClaim.essence,
      materials: pendingClaim.materials,
      turns: turns,
      actions: actions,
    );
  }
}

@immutable
class BattleExpeditionState {
  const BattleExpeditionState({
    required this.status,
    required this.lastProgressedAt,
    required this.phaseProgress,
    this.currentBattle,
    this.pendingClaim = const BattlePendingClaim(),
    this.recentLogs = const <BattleLogEntry>[],
  });

  final BattleExpeditionStatus status;
  final DateTime? lastProgressedAt;
  final Duration phaseProgress;
  final BattlePlaybackState? currentBattle;
  final BattlePendingClaim pendingClaim;
  final List<BattleLogEntry> recentLogs;

  bool get isActive =>
      status == BattleExpeditionStatus.searching ||
      status == BattleExpeditionStatus.battling;

  BattleExpeditionState copyWith({
    BattleExpeditionStatus? status,
    DateTime? lastProgressedAt,
    Duration? phaseProgress,
    BattlePlaybackState? currentBattle,
    bool clearCurrentBattle = false,
    BattlePendingClaim? pendingClaim,
    List<BattleLogEntry>? recentLogs,
  }) {
    return BattleExpeditionState(
      status: status ?? this.status,
      lastProgressedAt: lastProgressedAt ?? this.lastProgressedAt,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      currentBattle: clearCurrentBattle
          ? null
          : currentBattle ?? this.currentBattle,
      pendingClaim: pendingClaim ?? this.pendingClaim,
      recentLogs: recentLogs ?? this.recentLogs,
    );
  }
}
