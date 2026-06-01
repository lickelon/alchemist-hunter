part of 'battle_service.dart';

mixin _BattleActionTargetSelectionMixin on _BattleEncounterUnitMapperMixin {
  Random get _random;

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
      return _randomUnit(enemies);
    }
    return switch (skill.targetType) {
      BattleSkillTargetType.randomEnemy => _randomUnit(enemies),
      BattleSkillTargetType.self => <_BattleUnit>[actor],
      BattleSkillTargetType.randomAlly => _randomUnit(allies),
      BattleSkillTargetType.allEnemies => enemies,
      BattleSkillTargetType.allAllies => allies,
    };
  }

  List<_BattleUnit> _randomUnit(List<_BattleUnit> units) {
    if (units.isEmpty) {
      return const <_BattleUnit>[];
    }
    return <_BattleUnit>[units[_random.nextInt(units.length)]];
  }
}
