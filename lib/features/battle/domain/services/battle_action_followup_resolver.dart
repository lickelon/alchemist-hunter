part of 'battle_service.dart';

mixin _BattleActionFollowupMixin
    on _BattleEncounterUnitMapperMixin, _BattlePassiveEffectMixin {
  List<_DerivedActionRequest> _applyOnDamagedHooks(
    _ActionLifecycleContext context,
    _BattleUnit target, {
    required int damage,
  }) {
    if (!context.allowDerivedActions || damage <= 0 || !target.isAlive) {
      return const <_DerivedActionRequest>[];
    }
    final int counterAttackCount = _BattleModifierResolver.counterAttackCount(
      target,
    );
    if (counterAttackCount <= 0) {
      return const <_DerivedActionRequest>[];
    }
    return List<_DerivedActionRequest>.filled(
      counterAttackCount,
      _DerivedActionRequest(actor: target),
    );
  }

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
          turn: context.lifecycle,
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
          turn: context.lifecycle,
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

  List<_DerivedActionRequest> _applyAfterActionHooks(
    _ActionLifecycleContext context, {
    required bool encounterEnded,
  }) {
    if (!context.allowDerivedActions ||
        encounterEnded ||
        !context.actor.isAlive) {
      return const <_DerivedActionRequest>[];
    }
    final int extraAttackCount = _BattleModifierResolver.extraAttackCount(
      context.actor,
    );
    if (extraAttackCount <= 0) {
      return const <_DerivedActionRequest>[];
    }
    return List<_DerivedActionRequest>.filled(
      extraAttackCount,
      _DerivedActionRequest(actor: context.actor),
    );
  }

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
          turn: context.lifecycle,
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

  _ActionLifecycleResult _buildActionLifecycleResult({
    required List<BattleActionLog> actions,
    required int nextLifecycle,
  }) {
    return _ActionLifecycleResult(
      actions: actions,
      nextLifecycle: nextLifecycle,
    );
  }

  bool _encounterEnded(Map<String, _BattleUnit> units) {
    return _livingUnits(units, _BattleSide.enemy).isEmpty ||
        _livingUnits(units, _BattleSide.ally).isEmpty;
  }
}
