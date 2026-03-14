import 'dart:math';

import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class EquipmentEnchantService {
  const EquipmentEnchantService();

  EquipmentEnchant buildEnchant({
    required EquipmentInstance equipment,
    required CraftedPotion potion,
    required PotionBlueprint blueprint,
    double potencyBonusRate = 0,
  }) {
    final String dominantTraitId = _dominantTraitId(potion);
    final int potency = _potency(potion, potencyBonusRate);

    switch (equipment.slot) {
      case EquipmentSlot.weapon:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
          dominantTraitId: dominantTraitId,
          attackBonus: potency + _attackAffinity(dominantTraitId),
          defenseBonus: max(0, potency ~/ 3),
          healthBonus: max(0, potency * 2),
        );
      case EquipmentSlot.armor:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
          dominantTraitId: dominantTraitId,
          attackBonus: max(0, potency ~/ 4),
          defenseBonus: potency + _defenseAffinity(dominantTraitId),
          healthBonus: (potency * 4) + _vitalAffinity(dominantTraitId),
        );
      case EquipmentSlot.accessory:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
          dominantTraitId: dominantTraitId,
          attackBonus: max(0, potency ~/ 2) + _attackAffinity(dominantTraitId),
          defenseBonus:
              max(0, potency ~/ 2) + _defenseAffinity(dominantTraitId),
          healthBonus: (potency * 3) + _vitalAffinity(dominantTraitId),
        );
    }
  }

  String _dominantTraitId(CraftedPotion potion) {
    if (potion.traits.isEmpty) {
      return 't_pure';
    }
    final List<MapEntry<String, double>> sorted = potion.traits.entries.toList()
      ..sort(
        (MapEntry<String, double> left, MapEntry<String, double> right) =>
            right.value.compareTo(left.value),
      );
    return sorted.first.key;
  }

  int _potency(CraftedPotion potion, double bonusRate) {
    final int qualityBonus = switch (potion.qualityGrade) {
      PotionQualityGrade.s => 4,
      PotionQualityGrade.a => 3,
      PotionQualityGrade.b => 2,
      PotionQualityGrade.c => 1,
    };
    final int basePotency = (potion.qualityScore * 8).round() + qualityBonus;
    return max(1, (basePotency * (1 + bonusRate)).round());
  }

  int _attackAffinity(String traitId) {
    if (const <String>{
      't_atk',
      't_crit',
      't_spd',
      't_focus',
    }.contains(traitId)) {
      return 3;
    }
    return 0;
  }

  int _defenseAffinity(String traitId) {
    if (const <String>{'t_def', 't_pure', 't_mana'}.contains(traitId)) {
      return 3;
    }
    return 0;
  }

  int _vitalAffinity(String traitId) {
    if (const <String>{'t_hp', 't_life', 't_regen'}.contains(traitId)) {
      return 6;
    }
    return 0;
  }
}
