import 'package:flutter/foundation.dart';

import '../combat_jobs.dart';
import 'character_equipment_loadout.dart';
import 'character_identity_models.dart';

@immutable
class CharacterProgress {
  const CharacterProgress({
    required this.id,
    required this.name,
    required this.type,
    this.combatJobId,
    required this.level,
    required this.rank,
    required this.xp,
    this.mercenaryTier,
    this.homunculusTier,
    this.homunculusOrigin,
    this.homunculusRole,
    this.homunculusSupportEffect,
    this.equipment = const CharacterEquipmentLoadout(),
  });

  final String id;
  final String name;
  final CharacterType type;
  final String? combatJobId;
  final int level;
  final int rank;
  final int xp;
  final MercenaryTier? mercenaryTier;
  final HomunculusTier? homunculusTier;
  final String? homunculusOrigin;
  final String? homunculusRole;
  final String? homunculusSupportEffect;
  final CharacterEquipmentLoadout equipment;

  int get maxLevelForRank => rank * 5;

  int get xpToNextLevel => level >= maxLevelForRank ? 0 : level * 20;

  int get tierIndex {
    if (type == CharacterType.mercenary) {
      return (mercenaryTier ?? MercenaryTier.rookie).index + 1;
    }
    return (homunculusTier ?? HomunculusTier.nigredo).index + 1;
  }

  int get maxTier {
    return type == CharacterType.mercenary ? 5 : 4;
  }

  int get rankStepPerTier {
    return type == CharacterType.mercenary ? 2 : 3;
  }

  int get rankBaseForCurrentTier {
    return (tierIndex - 1) * rankStepPerTier;
  }

  int get rankInCurrentTier {
    final int localRank = rank - rankBaseForCurrentTier;
    if (localRank < 1) {
      return 1;
    }
    if (localRank > rankStepPerTier) {
      return rankStepPerTier;
    }
    return localRank;
  }

  int get maxRankForCurrentTier {
    if (type == CharacterType.mercenary) {
      return tierIndex * 2;
    }
    return tierIndex * 3;
  }

  bool get canRankUp =>
      level >= maxLevelForRank && rank < maxRankForCurrentTier;

  bool get canTierUp =>
      rank >= maxRankForCurrentTier &&
      level >= maxLevelForRank &&
      tierIndex < maxTier;

  String get resolvedCombatJobId {
    if (combatJobId != null) {
      return combatJobId!;
    }
    return switch (type) {
      CharacterType.mercenary => CombatJobIds.mercenaryWarrior,
      CharacterType.homunculus => CombatJobIds.homunculusWarrior,
    };
  }

  CharacterProgress copyWith({
    String? name,
    String? combatJobId,
    int? level,
    int? rank,
    int? xp,
    MercenaryTier? mercenaryTier,
    HomunculusTier? homunculusTier,
    String? homunculusOrigin,
    String? homunculusRole,
    String? homunculusSupportEffect,
    CharacterEquipmentLoadout? equipment,
  }) {
    return CharacterProgress(
      id: id,
      name: name ?? this.name,
      type: type,
      combatJobId: combatJobId ?? this.combatJobId,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      xp: xp ?? this.xp,
      mercenaryTier: mercenaryTier ?? this.mercenaryTier,
      homunculusTier: homunculusTier ?? this.homunculusTier,
      homunculusOrigin: homunculusOrigin ?? this.homunculusOrigin,
      homunculusRole: homunculusRole ?? this.homunculusRole,
      homunculusSupportEffect:
          homunculusSupportEffect ?? this.homunculusSupportEffect,
      equipment: equipment ?? this.equipment,
    );
  }
}
