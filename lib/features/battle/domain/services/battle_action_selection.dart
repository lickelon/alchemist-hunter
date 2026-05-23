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

  BattleSkillDefinition? _selectBaseAction(_BattleUnit actor) {
    if (!actor.isAlive || actor.maxMp <= 0 || actor.currentMp < actor.maxMp) {
      return null;
    }
    final List<BattleSkillDefinition> available = actor.skills
        .where(
          (BattleSkillDefinition skill) =>
              _isSupportedActiveSkill(skill) &&
              (actor.skillCooldowns[skill.id] ?? 0) <= 0,
        )
        .toList(growable: false);
    if (available.isEmpty) {
      return null;
    }
    return available.reduce(
      (BattleSkillDefinition left, BattleSkillDefinition right) =>
          right.priority > left.priority ? right : left,
    );
  }

  List<_BattleUnit> _selectActionTargets(
    _BattleUnit actor,
    Map<String, _BattleUnit> units,
    BattleSkillDefinition? skill,
  ) {
    final List<_BattleUnit> enemies = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.enemy)
        : _livingUnits(units, _BattleSide.ally);
    final List<_BattleUnit> allies = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.ally)
        : _livingUnits(units, _BattleSide.enemy);
    if (skill == null) {
      if (enemies.isEmpty) {
        return const <_BattleUnit>[];
      }
      return <_BattleUnit>[enemies[_random.nextInt(enemies.length)]];
    }
    return switch (skill.targetType) {
      BattleSkillTargetType.randomEnemy =>
        enemies.isEmpty
            ? const <_BattleUnit>[]
            : <_BattleUnit>[enemies[_random.nextInt(enemies.length)]],
      BattleSkillTargetType.self => <_BattleUnit>[actor],
      BattleSkillTargetType.randomAlly =>
        allies.isEmpty
            ? const <_BattleUnit>[]
            : <_BattleUnit>[allies[_random.nextInt(allies.length)]],
      BattleSkillTargetType.allEnemies => enemies,
      BattleSkillTargetType.allAllies => allies,
    };
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
