part of 'battle_service.dart';

mixin _BattlePassiveEffectMixin on _BattleEncounterUnitMapperMixin {
  List<BattleActionLog> _applyGrantModifierPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantModifier ||
          passive.modifier == null ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.activeModifiers = <BattleTimedModifier>[
        ...recipient.activeModifiers,
        BattleTimedModifier(
          modifier: passive.modifier!,
          remainingLifecycles: max(1, passive.durationLifecycles),
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.modifier,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          message: 'modifier:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applyGrantStatusPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantStatus ||
          passive.statusType == null ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.statuses = <BattleStatusEffect>[
        ...recipient.statuses,
        BattleStatusEffect(
          type: passive.statusType!,
          sourceId: passive.sourceId,
          remainingLifecycles: max(1, passive.durationLifecycles),
          power: passive.value ?? 0,
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          statusType: passive.statusType,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          message: 'status:${passive.statusType!.name}:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applyGrantShieldPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantShield ||
          (passive.value ?? 0) <= 0 ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.shield += passive.value ?? 0;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.shield,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          healing: passive.value ?? 0,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          targetShieldAfter: recipient.shield,
          message: 'shield:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

  bool _passiveConditionMatches(
    BattlePassiveEffect passive, {
    required _BattleUnit actor,
    required _BattleUnit target,
    required bool critical,
  }) {
    final BattlePassiveCondition condition = passive.condition;
    return switch (condition.type) {
      BattlePassiveConditionType.always => true,
      BattlePassiveConditionType.actorHpBelow =>
        actor.currentHp / max(actor.maxHp, 1) <= condition.threshold,
      BattlePassiveConditionType.actorHpAbove =>
        actor.currentHp / max(actor.maxHp, 1) >= condition.threshold,
      BattlePassiveConditionType.targetFaction =>
        condition.faction == null || target.faction == condition.faction,
      BattlePassiveConditionType.targetHasStatus =>
        condition.statusType == null ||
            target.statuses.any(
              (BattleStatusEffect status) =>
                  status.type == condition.statusType,
            ),
      BattlePassiveConditionType.criticalHit => critical,
    };
  }
}
