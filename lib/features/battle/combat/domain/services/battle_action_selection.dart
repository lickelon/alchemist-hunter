part of 'battle_service.dart';

mixin _BattleActionSelectionMixin
    on _BattleEncounterUnitMapperMixin, _BattlePassiveEffectMixin {
  Random get _random;

  List<BattleActionLog> _applyBeforeActionHooks(
    _ActionLifecycleContext context,
  ) {
    return <BattleActionLog>[
      ..._applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
      ..._applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
      ..._applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    ];
  }

  void _applyBeforeHitCheckHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {}

  bool _resolveHitCheck(_ActionLifecycleContext context, _BattleUnit target) {
    return _BattleAttackResolver(random: _random).rollHit(
      attacker: context.actor,
      defender: target,
      potionBoost: context.potionBoost,
    );
  }

  List<BattleActionLog> _applyBeforeDamageHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {
    return _applyGrantModifierPassives(
      trigger: BattlePassiveTrigger.beforeDamage,
      context: context,
      target: target,
      recipient: context.actor,
      critical: false,
    );
  }

  _DamageRoll _resolveActionEffect({
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required bool critical,
    BattleSkillDefinition? skill,
  }) {
    return _BattleAttackResolver(random: _random).rollDamage(
      attacker: context.actor,
      defender: target,
      critical: critical,
      potionBoost: context.potionBoost,
      skill: skill,
    );
  }

  int _applyActionEffect({
    required _BattleUnit target,
    required _DamageRoll damageRoll,
  }) {
    final int blocked = min(target.shield, damageRoll.damage);
    target.shield -= blocked;
    final int hpDamage = damageRoll.damage - blocked;
    target.currentHp = max(0, target.currentHp - hpDamage);
    return hpDamage;
  }

  List<BattleActionLog> _applyAfterHitHooks(
    _ActionLifecycleContext context,
    _BattleUnit target, {
    required bool critical,
  }) {
    return <BattleActionLog>[
      ..._applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: target,
        critical: critical,
      ),
      ..._applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: target,
        critical: critical,
      ),
      ..._applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: context.actor,
        critical: critical,
      ),
    ];
  }
}
