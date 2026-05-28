part of 'battle_service.dart';

mixin _BattleSkillEffectMixin on _BattleEncounterUnitMapperMixin {
  List<BattleActionLog> _applyHealSkill({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      final int healing = _resolveHealing(context.actor, skill);
      final int previousHp = target.currentHp;
      target.currentHp = min(target.maxHp, target.currentHp + healing);
      final int appliedHealing = target.currentHp - previousHp;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.heal,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          healing: appliedHealing,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applySkillModifier({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    if (skill.modifier == null) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.activeModifiers = <BattleTimedModifier>[
        ...target.activeModifiers,
        BattleTimedModifier(
          modifier: skill.modifier!,
          remainingLifecycles: max(1, skill.durationLifecycles),
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.modifier,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          message: 'modifier:${skill.id}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applySkillStatus({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    if (skill.statusType == null) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.statuses = <BattleStatusEffect>[
        ...target.statuses,
        BattleStatusEffect(
          type: skill.statusType!,
          sourceId: skill.id,
          remainingLifecycles: max(1, skill.durationLifecycles),
          power: skill.flatPower,
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          statusType: skill.statusType,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          message: 'status:${skill.statusType!.name}:${skill.id}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applySkillShield({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    final int shield = max(skill.shieldValue, skill.flatPower);
    if (shield <= 0) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.shield += shield;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.shield,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          healing: shield,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          targetShieldAfter: target.shield,
          message: 'shield:${skill.id}',
        ),
      );
    }
    return actions;
  }

  int _resolveHealing(_BattleUnit actor, BattleSkillDefinition skill) {
    final double baseHealing =
        (actor.stats.magicalAttack * skill.powerMultiplier) + skill.flatPower;
    return max(1, (baseHealing * (1 + actor.stats.healingPower)).round());
  }
}
