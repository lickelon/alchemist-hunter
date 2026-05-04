import 'package:flutter/foundation.dart';

import 'battle_models.dart';
import 'combat_models.dart';

@immutable
class BattleEnemyDefinition {
  const BattleEnemyDefinition({
    required this.id,
    required this.name,
    required this.faction,
    required this.summary,
    required this.stats,
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    this.normalDrops = const <BattleDropEntry>[],
    this.specialDrops = const <BattleDropEntry>[],
  });

  final String id;
  final String name;
  final CombatFaction faction;
  final String summary;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final List<BattleDropEntry> normalDrops;
  final List<BattleDropEntry> specialDrops;
}

@immutable
class BattleEnemySetDefinition {
  const BattleEnemySetDefinition({
    required this.id,
    required this.name,
    required this.enemyIds,
    required this.summary,
  });

  final String id;
  final String name;
  final List<String> enemyIds;
  final String summary;
}

@immutable
class BattleStageDefinition {
  const BattleStageDefinition({
    required this.id,
    required this.name,
    required this.recommendedPower,
    required this.searchDuration,
    required this.enemySetId,
    required this.goldSuccess,
    required this.goldFailurePenalty,
    required this.essenceSuccess,
    required this.essenceFailure,
    required this.xpSuccessBase,
    required this.xpFailureBase,
  });

  final String id;
  final String name;
  final int recommendedPower;
  final Duration searchDuration;
  final String enemySetId;
  final int goldSuccess;
  final int goldFailurePenalty;
  final int essenceSuccess;
  final int essenceFailure;
  final int xpSuccessBase;
  final int xpFailureBase;
}
