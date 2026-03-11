import 'package:flutter/foundation.dart';

enum CharacterType { mercenary, homunculus }

enum MercenaryTier { rookie, veteran, elite, champion, legend }

enum HomunculusTier { nigredo, albedo, citrinitas, rubedo }

@immutable
class CharacterProgress {
  const CharacterProgress({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.rank,
    required this.xp,
    this.mercenaryTier,
    this.homunculusTier,
  });

  final String id;
  final String name;
  final CharacterType type;
  final int level;
  final int rank;
  final int xp;
  final MercenaryTier? mercenaryTier;
  final HomunculusTier? homunculusTier;

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

  int get maxRankForCurrentTier {
    if (type == CharacterType.mercenary) {
      return tierIndex * 2;
    }
    return tierIndex * 3;
  }

  bool get canRankUp => level >= maxLevelForRank && rank < maxRankForCurrentTier;

  bool get canTierUp => rank >= maxRankForCurrentTier && tierIndex < maxTier;

  CharacterProgress copyWith({
    int? level,
    int? rank,
    int? xp,
    MercenaryTier? mercenaryTier,
    HomunculusTier? homunculusTier,
  }) {
    return CharacterProgress(
      id: id,
      name: name,
      type: type,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      xp: xp ?? this.xp,
      mercenaryTier: mercenaryTier ?? this.mercenaryTier,
      homunculusTier: homunculusTier ?? this.homunculusTier,
    );
  }
}

@immutable
class CharactersState {
  const CharactersState({
    required this.mercenaries,
    required this.homunculi,
  });

  final List<CharacterProgress> mercenaries;
  final List<CharacterProgress> homunculi;

  CharactersState copyWith({
    List<CharacterProgress>? mercenaries,
    List<CharacterProgress>? homunculi,
  }) {
    return CharactersState(
      mercenaries: mercenaries ?? this.mercenaries,
      homunculi: homunculi ?? this.homunculi,
    );
  }
}
