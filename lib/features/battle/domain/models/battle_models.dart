import 'package:flutter/foundation.dart';

enum SessionPhase { early, mid, late }

@immutable
class BattleDropEntry {
  const BattleDropEntry({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  final String materialId;
  final int min;
  final int max;
  final double chance;
}

@immutable
class BattleDropTable {
  const BattleDropTable({
    required this.stageId,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String stageId;
  final List<BattleDropEntry> normalDrops;
  final List<BattleDropEntry> specialDrops;
}

@immutable
class HeroProfile {
  const HeroProfile({
    required this.id,
    required this.name,
    required this.power,
  });

  final String id;
  final String name;
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

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final int automationTier;
  final SessionPhase sessionPhase;
}

@immutable
class BattleResult {
  const BattleResult({
    required this.success,
    required this.turns,
    required this.loot,
    required this.failurePenalty,
  });

  final bool success;
  final int turns;
  final Map<String, int> loot;
  final int failurePenalty;
}
