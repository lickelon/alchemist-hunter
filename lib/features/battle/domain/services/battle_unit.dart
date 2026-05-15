part of 'battle_service.dart';

enum _BattleSide { ally, enemy }

class _BattleUnit {
  _BattleUnit({
    required this.id,
    required this.name,
    required this.side,
    required this.faction,
    required this.stats,
    required this.modifiers,
    required this.passives,
    required this.skills,
    required this.currentHp,
    required this.currentMp,
    required this.skillCooldowns,
  });

  final String id;
  final String name;
  final _BattleSide side;
  final CombatFaction faction;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final List<BattleSkillDefinition> skills;
  int currentHp;
  int currentMp;
  Map<String, int> skillCooldowns;

  int get maxHp => stats.maxHp;
  int get maxMp => stats.maxMp;
  bool get isAlive => currentHp > 0;
}

class _BattleLoopResult {
  const _BattleLoopResult({
    required this.success,
    required this.turns,
    required this.actions,
  });

  final bool success;
  final int turns;
  final List<BattleActionLog> actions;
}

class _DamageRoll {
  const _DamageRoll({required this.damage, required this.school});

  final int damage;
  final DamageSchool school;
}
