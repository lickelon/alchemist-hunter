import 'package:flutter/foundation.dart';

import 'combat/battle_combat_stats.dart';
import 'combat/battle_effect_models.dart';
import 'combat/battle_skill_models.dart';
import 'combat/combat_enums.dart';

const Duration battleActionInterval = Duration(seconds: 1);

enum BattleTeam { ally, enemy }

enum BattleActionType {
  attack,
  skillUse,
  skill,
  heal,
  lifesteal,
  regen,
  mpRegen,
  modifier,
  status,
  shield,
  passive,
}

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
    this.skillId,
    this.skillName,
    this.statusType,
    this.school = DamageSchool.any,
    this.hit = true,
    this.critical = false,
    this.damage = 0,
    this.healing = 0,
    this.mpSpent = 0,
    this.actorHpAfter = 0,
    this.actorMpAfter = 0,
    this.targetHpAfter,
    this.targetShieldAfter,
    this.message,
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
  final String? skillId;
  final String? skillName;
  final BattleStatusType? statusType;
  final DamageSchool school;
  final bool hit;
  final bool critical;
  final int damage;
  final int healing;
  final int mpSpent;
  final int actorHpAfter;
  final int actorMpAfter;
  final int? targetHpAfter;
  final int? targetShieldAfter;
  final String? message;
}

@immutable
class BattleRunUnitState {
  const BattleRunUnitState({
    required this.unitId,
    required this.name,
    required this.team,
    required this.faction,
    required this.stats,
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    this.skills = const <BattleSkillDefinition>[],
    this.activeModifiers = const <BattleTimedModifier>[],
    this.statuses = const <BattleStatusEffect>[],
    this.shield = 0,
    required this.currentHp,
    this.currentMp = 0,
    this.skillCooldowns = const <String, int>{},
  });

  final String unitId;
  final String name;
  final BattleTeam team;
  final CombatFaction faction;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final List<BattleSkillDefinition> skills;
  final List<BattleTimedModifier> activeModifiers;
  final List<BattleStatusEffect> statuses;
  final int shield;
  final int currentHp;
  final int currentMp;
  final Map<String, int> skillCooldowns;

  int get maxHp => stats.maxHp;
  int get maxMp => stats.maxMp;
  bool get isAlive => currentHp > 0;
  bool get hasUsableSkill {
    return isAlive &&
        maxMp > 0 &&
        currentMp >= maxMp &&
        skills.any(
          (BattleSkillDefinition skill) => (skillCooldowns[skill.id] ?? 0) <= 0,
        );
  }

  BattleRunUnitState copyWith({
    int? currentHp,
    int? currentMp,
    Map<String, int>? skillCooldowns,
    List<BattleTimedModifier>? activeModifiers,
    List<BattleStatusEffect>? statuses,
    int? shield,
  }) {
    return BattleRunUnitState(
      unitId: unitId,
      name: name,
      team: team,
      faction: faction,
      stats: stats,
      modifiers: modifiers,
      passives: passives,
      skills: skills,
      activeModifiers: activeModifiers ?? this.activeModifiers,
      statuses: statuses ?? this.statuses,
      shield: shield ?? this.shield,
      currentHp: currentHp ?? this.currentHp,
      currentMp: currentMp ?? this.currentMp,
      skillCooldowns: skillCooldowns ?? this.skillCooldowns,
    );
  }
}
