import 'package:flutter/foundation.dart';

import 'battle_combat_stats.dart';
import 'combat_enums.dart';

@immutable
class BattleCombatJobRankDefinition {
  const BattleCombatJobRankDefinition({
    required this.rank,
    required this.stats,
    this.skillIds = const <String>[],
    this.passiveIds = const <String>[],
  });

  final int rank;
  final BattleCombatStats stats;
  final List<String> skillIds;
  final List<String> passiveIds;
}

@immutable
class BattleCombatJobTierDefinition {
  const BattleCombatJobTierDefinition({
    required this.tierIndex,
    required this.ranks,
  });

  final int tierIndex;
  final List<BattleCombatJobRankDefinition> ranks;

  BattleCombatJobRankDefinition rankDefinition(int rank) {
    for (final BattleCombatJobRankDefinition definition in ranks) {
      if (definition.rank == rank) {
        return definition;
      }
    }
    throw StateError('Unknown combat rank $rank for tier $tierIndex');
  }
}

@immutable
class BattleCombatJobDefinition {
  const BattleCombatJobDefinition({
    required this.id,
    required this.faction,
    required this.discipline,
    required this.levelHpGrowth,
    required this.tiers,
  });

  final String id;
  final CombatFaction faction;
  final CombatDiscipline discipline;
  final int levelHpGrowth;
  final List<BattleCombatJobTierDefinition> tiers;

  BattleCombatJobTierDefinition tierDefinition(int tierIndex) {
    for (final BattleCombatJobTierDefinition definition in tiers) {
      if (definition.tierIndex == tierIndex) {
        return definition;
      }
    }
    throw StateError('Unknown combat tier $tierIndex for $id');
  }

  BattleCombatJobRankDefinition rankDefinition({
    required int tierIndex,
    required int rank,
  }) {
    return tierDefinition(tierIndex).rankDefinition(rank);
  }
}
