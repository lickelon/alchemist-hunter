part of 'battle_service.dart';

mixin _BattleEncounterRunnerMixin
    on _BattleEncounterUnitMapperMixin, _BattleActionLifecycleMixin {
  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    final Map<String, _BattleUnit> units = <String, _BattleUnit>{
      for (final BattleRunUnitState ally in allies) ally.unitId: _toUnit(ally),
      for (final BattleRunUnitState enemy in encounter.enemies)
        enemy.unitId: _toUnit(enemy),
    };
    List<String> pendingActorIds = encounter.pendingActorIds
        .where((String unitId) => units[unitId]?.isAlive ?? false)
        .toList(growable: true);
    if (pendingActorIds.isEmpty) {
      pendingActorIds = List<String>.of(
        _buildTurnOrder(units, firstTurn: encounter.turnInEncounter == 0),
        growable: true,
      );
    }
    if (pendingActorIds.isEmpty) {
      return BattleEncounterStepResult(
        allies: allies,
        encounter: encounter,
        ended: true,
        success: encounter.enemies.every(
          (BattleRunUnitState unit) => !unit.isAlive,
        ),
        wiped: allies.every((BattleRunUnitState unit) => !unit.isAlive),
      );
    }

    final String actorId = pendingActorIds.removeAt(0);
    final _BattleUnit? actor = units[actorId];
    if (actor == null || !actor.isAlive) {
      return BattleEncounterStepResult(
        allies: _extractUnits(units, BattleTeam.ally),
        encounter: encounter.copyWith(
          enemies: _extractUnits(units, BattleTeam.enemy),
          pendingActorIds: pendingActorIds,
        ),
        ended: false,
      );
    }

    final List<_BattleUnit> targets = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.enemy)
        : _livingUnits(units, _BattleSide.ally);
    if (targets.isEmpty) {
      return BattleEncounterStepResult(
        allies: _extractUnits(units, BattleTeam.ally),
        encounter: encounter.copyWith(
          enemies: _extractUnits(units, BattleTeam.enemy),
          pendingActorIds: pendingActorIds,
        ),
        ended: true,
        success: actor.side == _BattleSide.ally,
        wiped: actor.side == _BattleSide.enemy,
      );
    }

    final _ActionLifecycleResult lifecycleResult = _runActionLifecycle(
      units: units,
      actor: actor,
      startLifecycle: encounter.turnInEncounter + 1,
      potionBoost: potionBoost,
      allowDerivedActions: true,
    );
    final List<BattleActionLog> actions = lifecycleResult.actions;
    final bool success = _livingUnits(units, _BattleSide.enemy).isEmpty;
    final bool wiped = _livingUnits(units, _BattleSide.ally).isEmpty;

    return BattleEncounterStepResult(
      allies: _extractUnits(units, BattleTeam.ally),
      encounter: encounter.copyWith(
        enemies: _extractUnits(units, BattleTeam.enemy),
        pendingActorIds: pendingActorIds,
        recentActionLogs: <BattleActionLog>[
          ...encounter.recentActionLogs,
          ...actions,
        ],
        turnInEncounter: max(
          encounter.turnInEncounter,
          lifecycleResult.nextLifecycle - 1,
        ),
      ),
      ended: success || wiped,
      success: success,
      wiped: wiped,
      lifecycleActions: actions,
    );
  }
}

class _ActionLifecycleContext {
  const _ActionLifecycleContext({
    required this.actor,
    required this.lifecycle,
    required this.potionBoost,
    required this.allowDerivedActions,
  });

  final _BattleUnit actor;
  final int lifecycle;
  final int potionBoost;
  final bool allowDerivedActions;
}

class _ActionLifecycleResult {
  const _ActionLifecycleResult({
    required this.actions,
    required this.nextLifecycle,
  });

  final List<BattleActionLog> actions;
  final int nextLifecycle;
}

class _DerivedActionRequest {
  const _DerivedActionRequest({required this.actor});

  final _BattleUnit actor;
}
