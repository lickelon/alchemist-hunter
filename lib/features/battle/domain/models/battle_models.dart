import 'package:flutter/foundation.dart';

import 'combat_models.dart';

enum SessionPhase { early, mid, late }

enum BattleExpeditionStatus { idle, running, paused }

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

enum BattleActionType { attack, regen }

@immutable
class BattleActionLog {
  const BattleActionLog({
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
class BattleExpeditionState {
  const BattleExpeditionState({
    required this.status,
    required this.lastResolvedAt,
    required this.cycleProgress,
    this.pendingClaim = const BattlePendingClaim(),
    this.recentLogs = const <BattleLogEntry>[],
  });

  final BattleExpeditionStatus status;
  final DateTime? lastResolvedAt;
  final Duration cycleProgress;
  final BattlePendingClaim pendingClaim;
  final List<BattleLogEntry> recentLogs;

  BattleExpeditionState copyWith({
    BattleExpeditionStatus? status,
    DateTime? lastResolvedAt,
    Duration? cycleProgress,
    BattlePendingClaim? pendingClaim,
    List<BattleLogEntry>? recentLogs,
  }) {
    return BattleExpeditionState(
      status: status ?? this.status,
      lastResolvedAt: lastResolvedAt ?? this.lastResolvedAt,
      cycleProgress: cycleProgress ?? this.cycleProgress,
      pendingClaim: pendingClaim ?? this.pendingClaim,
      recentLogs: recentLogs ?? this.recentLogs,
    );
  }
}
