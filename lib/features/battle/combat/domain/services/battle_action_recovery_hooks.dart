part of 'battle_service.dart';

mixin _BattleActionRecoveryHookMixin on _BattleEncounterUnitMapperMixin {
  List<BattleActionLog> _applyPostActionRecovery({
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required int damage,
    required bool usesSkill,
  }) {
    const _BattleRecoveryResolver recoveryResolver = _BattleRecoveryResolver();
    final List<BattleActionLog> actions = <BattleActionLog>[];
    final int lifestealHealing = recoveryResolver.applyLifesteal(
      actor: context.actor,
      damage: damage,
    );
    if (lifestealHealing > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.lifesteal,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          healing: lifestealHealing,
          actorHpAfter: context.actor.currentHp,
          targetHpAfter: target.currentHp,
        ),
      );
    }

    final int regenHealing = recoveryResolver.applyRegen(context.actor);
    if (regenHealing > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.regen,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          healing: regenHealing,
          actorHpAfter: context.actor.currentHp,
        ),
      );
    }
    if (!usesSkill) {
      recoveryResolver.applyMpRegen(context.actor);
    }
    return actions;
  }
}
