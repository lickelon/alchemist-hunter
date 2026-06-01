part of 'battle_service.dart';

mixin _BattleActionFollowupMixin
    on _BattleEncounterUnitMapperMixin, _BattlePassiveEffectMixin {
  List<_DerivedActionRequest> _applyOnDamagedHooks(
    _ActionLifecycleContext context,
    _BattleUnit target, {
    required int damage,
  }) {
    if (!context.allowCounterAttack || damage <= 0 || !target.isAlive) {
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
      _DerivedActionRequest(
        actor: target,
        type: _DerivedActionType.counterAttack,
      ),
    );
  }

  List<_DerivedActionRequest> _applyAfterActionHooks(
    _ActionLifecycleContext context, {
    required bool encounterEnded,
  }) {
    if (!context.allowExtraAttack || encounterEnded || !context.actor.isAlive) {
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
      _DerivedActionRequest(
        actor: context.actor,
        type: _DerivedActionType.extraAttack,
      ),
    );
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
