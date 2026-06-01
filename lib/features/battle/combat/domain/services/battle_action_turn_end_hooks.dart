part of 'battle_service.dart';

mixin _BattleActionTurnEndHookMixin
    on _BattleEncounterUnitMapperMixin, _BattlePassiveEffectMixin {
  List<BattleActionLog> _applyTurnEndHooks(_ActionLifecycleContext context) {
    final List<BattleActionLog> actions = <BattleActionLog>[
      ..._applyStatusTurnEndEffects(context),
    ];
    context.actor.activeModifiers = context.actor.activeModifiers
        .map(
          (BattleTimedModifier modifier) => modifier.copyWith(
            remainingLifecycles: modifier.remainingLifecycles - 1,
          ),
        )
        .where(
          (BattleTimedModifier modifier) => modifier.remainingLifecycles > 0,
        )
        .toList(growable: false);
    context.actor.statuses = context.actor.statuses
        .map(
          (BattleStatusEffect status) => status.copyWith(
            remainingLifecycles: status.remainingLifecycles - 1,
          ),
        )
        .where((BattleStatusEffect status) => status.remainingLifecycles > 0)
        .toList(growable: false);
    actions.addAll(
      _applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    actions.addAll(
      _applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    actions.addAll(
      _applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    return actions;
  }

  bool _isActionBlockedByStatus(_ActionLifecycleContext context) {
    return context.actor.statuses.any(
      (BattleStatusEffect status) => status.type == BattleStatusType.stun,
    );
  }

  List<BattleActionLog> _applyStatusTurnEndEffects(
    _ActionLifecycleContext context,
  ) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattleStatusEffect status in context.actor.statuses) {
      if (status.type != BattleStatusType.poison || status.power <= 0) {
        continue;
      }
      final int damage = min(context.actor.currentHp, status.power);
      context.actor.currentHp = max(0, context.actor.currentHp - damage);
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          statusType: BattleStatusType.poison,
          damage: damage,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          message: 'status:poison',
        ),
      );
    }
    return actions;
  }
}
