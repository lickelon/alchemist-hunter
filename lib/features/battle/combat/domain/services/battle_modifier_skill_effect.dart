part of 'battle_service.dart';

extension _BattleModifierSkillEffect on _BattleSkillEffectMixin {
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
}
