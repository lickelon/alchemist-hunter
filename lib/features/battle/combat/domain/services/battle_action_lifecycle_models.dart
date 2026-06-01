part of 'battle_service.dart';

class _ActionLifecycleContext {
  const _ActionLifecycleContext({
    required this.actor,
    required this.turn,
    required this.lifecycle,
    required this.potionBoost,
    required this.allowExtraAttack,
    required this.allowCounterAttack,
  });

  final _BattleUnit actor;
  final int turn;
  final int lifecycle;
  final int potionBoost;
  final bool allowExtraAttack;
  final bool allowCounterAttack;
}

class _ActionLifecycleResult {
  const _ActionLifecycleResult({
    required this.actions,
    required this.nextLifecycle,
  });

  final List<BattleActionLog> actions;
  final int nextLifecycle;
}

class _PrimaryActionEffectResult {
  const _PrimaryActionEffectResult({
    required this.actions,
    required this.onDamagedRequests,
    required this.totalDamage,
    required this.recoveryTarget,
  });

  final List<BattleActionLog> actions;
  final List<_DerivedActionRequest> onDamagedRequests;
  final int totalDamage;
  final _BattleUnit recoveryTarget;
}

class _DerivedActionRequest {
  const _DerivedActionRequest({required this.actor, required this.type});

  final _BattleUnit actor;
  final _DerivedActionType type;
}

enum _DerivedActionType { counterAttack, extraAttack }
