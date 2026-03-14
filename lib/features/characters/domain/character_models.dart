import 'package:flutter/foundation.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

enum CharacterType { mercenary, homunculus }

enum MercenaryTier { rookie, veteran, elite, champion, legend }

enum HomunculusTier { nigredo, albedo, citrinitas, rubedo }

@immutable
class CharacterEquipmentLoadout {
  const CharacterEquipmentLoadout({this.weapon, this.armor, this.accessory});

  final EquipmentInstance? weapon;
  final EquipmentInstance? armor;
  final EquipmentInstance? accessory;

  EquipmentInstance? itemForSlot(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return weapon;
      case EquipmentSlot.armor:
        return armor;
      case EquipmentSlot.accessory:
        return accessory;
    }
  }

  CharacterEquipmentLoadout equip(EquipmentInstance item) {
    switch (item.slot) {
      case EquipmentSlot.weapon:
        return CharacterEquipmentLoadout(
          weapon: item,
          armor: armor,
          accessory: accessory,
        );
      case EquipmentSlot.armor:
        return CharacterEquipmentLoadout(
          weapon: weapon,
          armor: item,
          accessory: accessory,
        );
      case EquipmentSlot.accessory:
        return CharacterEquipmentLoadout(
          weapon: weapon,
          armor: armor,
          accessory: item,
        );
    }
  }

  CharacterEquipmentLoadout clearSlot(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return CharacterEquipmentLoadout(armor: armor, accessory: accessory);
      case EquipmentSlot.armor:
        return CharacterEquipmentLoadout(weapon: weapon, accessory: accessory);
      case EquipmentSlot.accessory:
        return CharacterEquipmentLoadout(weapon: weapon, armor: armor);
    }
  }
}

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
    this.homunculusOrigin,
    this.homunculusRole,
    this.homunculusSupportEffect,
    this.equipment = const CharacterEquipmentLoadout(),
  });

  final String id;
  final String name;
  final CharacterType type;
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

  int get maxRankForCurrentTier {
    if (type == CharacterType.mercenary) {
      return tierIndex * 2;
    }
    return tierIndex * 3;
  }

  bool get canRankUp =>
      level >= maxLevelForRank && rank < maxRankForCurrentTier;

  bool get canTierUp => rank >= maxRankForCurrentTier && tierIndex < maxTier;

  CharacterProgress copyWith({
    String? name,
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
