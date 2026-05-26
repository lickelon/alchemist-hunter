import 'package:flutter/foundation.dart';

import 'battle_playback_models.dart';

@immutable
class BattleLogEntry {
  const BattleLogEntry({
    required this.resolvedAt,
    this.encounterIndex = 0,
    required this.success,
    this.wipedParty = false,
    required this.gold,
    required this.essence,
    required this.materials,
    required this.turns,
    this.actions = const <BattleActionLog>[],
    this.usedLoadoutFallback = false,
  });

  final DateTime resolvedAt;
  final int encounterIndex;
  final bool success;
  final bool wipedParty;
  final int gold;
  final int essence;
  final Map<String, int> materials;
  final int turns;
  final List<BattleActionLog> actions;
  final bool usedLoadoutFallback;
}

@immutable
class BattleResult {
  const BattleResult({
    required this.success,
    required this.turns,
    required this.loot,
    required this.failurePenalty,
    this.actions = const <BattleActionLog>[],
  });

  final bool success;
  final int turns;
  final Map<String, int> loot;
  final int failurePenalty;
  final List<BattleActionLog> actions;
}

@immutable
class BattlePendingClaim {
  const BattlePendingClaim({
    this.materials = const <String, int>{},
    this.gold = 0,
    this.essence = 0,
    this.xp = 0,
    this.elapsedRealTime = Duration.zero,
    this.victoryCount = 0,
    this.wipeCount = 0,
    this.hasSuccessfulBattle = false,
  });

  final Map<String, int> materials;
  final int gold;
  final int essence;
  final int xp;
  final Duration elapsedRealTime;
  final int victoryCount;
  final int wipeCount;
  final bool hasSuccessfulBattle;

  bool get isEmpty =>
      materials.isEmpty &&
      gold == 0 &&
      essence == 0 &&
      xp == 0 &&
      !hasSuccessfulBattle;

  BattlePendingClaim copyWith({
    Map<String, int>? materials,
    int? gold,
    int? essence,
    int? xp,
    Duration? elapsedRealTime,
    int? victoryCount,
    int? wipeCount,
    bool? hasSuccessfulBattle,
  }) {
    return BattlePendingClaim(
      materials: materials ?? this.materials,
      gold: gold ?? this.gold,
      essence: essence ?? this.essence,
      xp: xp ?? this.xp,
      elapsedRealTime: elapsedRealTime ?? this.elapsedRealTime,
      victoryCount: victoryCount ?? this.victoryCount,
      wipeCount: wipeCount ?? this.wipeCount,
      hasSuccessfulBattle: hasSuccessfulBattle ?? this.hasSuccessfulBattle,
    );
  }
}
