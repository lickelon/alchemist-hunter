import 'package:flutter/foundation.dart';

import 'combat_models.dart';

@immutable
class HeroProfile {
  const HeroProfile({
    required this.id,
    required this.name,
    required this.faction,
    required this.discipline,
    required this.jobId,
    required this.stats,
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    this.skills = const <BattleSkillDefinition>[],
    required this.power,
  });

  final String id;
  final String name;
  final CombatFaction faction;
  final CombatDiscipline discipline;
  final String jobId;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final List<BattleSkillDefinition> skills;
  final int power;
}

@immutable
class AutoBattleConfig {
  const AutoBattleConfig({
    required this.party,
    required this.potionLoadout,
    required this.stageId,
  });

  final List<HeroProfile> party;
  final Map<String, int> potionLoadout;
  final String stageId;
}
