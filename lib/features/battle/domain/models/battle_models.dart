import 'package:flutter/foundation.dart';

import 'combat_models.dart';

enum SessionPhase { early, mid, late }

const Duration battleActionInterval = Duration(seconds: 1);

enum BattleExpeditionStatus { idle, searching, battling, paused }

@immutable
class BattleDropEntry {
  const BattleDropEntry({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  final String materialId;
  final int min;
  final int max;
  final double chance;
}

@immutable
class BattleDropTable {
  const BattleDropTable({
    required this.stageId,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String stageId;
  final List<BattleDropEntry> normalDrops;
  final List<BattleDropEntry> specialDrops;
}

@immutable
class HeroProfile {
  const HeroProfile({
    required this.id,
    required this.name,
    required this.faction,
    required this.discipline,
    required this.jobId,
    required this.stats,
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    required this.power,
  });

  final String id;
  final String name;
  final CombatFaction faction;
  final CombatDiscipline discipline;
  final String jobId;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final int power;
}

@immutable
class AutoBattleConfig {
  const AutoBattleConfig({
    required this.party,
    required this.potionLoadout,
    required this.stageId,
  });

  final List<HeroProfile> party;
  final Map<String, int> potionLoadout;
  final String stageId;
}

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final int automationTier;
  final SessionPhase sessionPhase;

  ProgressState copyWith({
    Set<String>? unlockFlags,
    int? automationTier,
    SessionPhase? sessionPhase,
  }) {
    return ProgressState(
      unlockFlags: unlockFlags ?? this.unlockFlags,
      automationTier: automationTier ?? this.automationTier,
      sessionPhase: sessionPhase ?? this.sessionPhase,
    );
  }
}

enum BattleTeam { ally, enemy }

enum BattleActionType { attack, lifesteal, regen }

@immutable
class BattleActionLog {
  const BattleActionLog({
    required this.lifecycle,
    required this.turn,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.actorTeam,
    this.targetId,
    this.targetName,
    this.targetTeam,
    this.school = DamageSchool.any,
    this.hit = true,
    this.critical = false,
    this.damage = 0,
    this.healing = 0,
    this.actorHpAfter = 0,
    this.targetHpAfter,
  });

  final int lifecycle;
  final int turn;
  final BattleActionType type;
  final String actorId;
  final String actorName;
  final BattleTeam actorTeam;
  final String? targetId;
  final String? targetName;
  final BattleTeam? targetTeam;
  final DamageSchool school;
  final bool hit;
  final bool critical;
  final int damage;
  final int healing;
  final int actorHpAfter;
  final int? targetHpAfter;
}

@immutable
class BattleLogEntry {
  const BattleLogEntry({
    required this.resolvedAt,
    required this.success,
    required this.gold,
    required this.essence,
    required this.materials,
    required this.turns,
    this.actions = const <BattleActionLog>[],
  });

  final DateTime resolvedAt;
  final bool success;
  final int gold;
  final int essence;
  final Map<String, int> materials;
  final int turns;
  final List<BattleActionLog> actions;
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
    this.characterXp = const <String, int>{},
  });

  final Map<String, int> materials;
  final int gold;
  final int essence;
  final Map<String, int> characterXp;

  bool get isEmpty =>
      materials.isEmpty && gold == 0 && essence == 0 && characterXp.isEmpty;

  BattlePendingClaim copyWith({
    Map<String, int>? materials,
    int? gold,
    int? essence,
    Map<String, int>? characterXp,
  }) {
    return BattlePendingClaim(
      materials: materials ?? this.materials,
      gold: gold ?? this.gold,
      essence: essence ?? this.essence,
      characterXp: characterXp ?? this.characterXp,
    );
  }
}

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
