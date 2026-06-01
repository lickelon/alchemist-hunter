part of 'battle_service.dart';

class BattleEncounterStepResult {
  const BattleEncounterStepResult({
    required this.allies,
    required this.encounter,
    required this.ended,
    this.success = false,
    this.wiped = false,
    this.lifecycleActions = const <BattleActionLog>[],
  });

  final List<BattleRunUnitState> allies;
  final BattleEncounterRuntimeState encounter;
  final bool ended;
  final bool success;
  final bool wiped;
  final List<BattleActionLog> lifecycleActions;
}

class BattleEncounterOutcome {
  const BattleEncounterOutcome({
    required this.allies,
    required this.encounter,
    required this.success,
    required this.wiped,
  });

  final List<BattleRunUnitState> allies;
  final BattleEncounterRuntimeState encounter;
  final bool success;
  final bool wiped;
}
