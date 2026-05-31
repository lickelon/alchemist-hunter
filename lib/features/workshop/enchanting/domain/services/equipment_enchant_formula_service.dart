import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class EquipmentEnchantFormulaService {
  const EquipmentEnchantFormulaService();

  String dominantTraitId(CraftedPotion potion) {
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

  int potency(CraftedPotion potion, double bonusRate) {
    final int qualityBonus = switch (potion.qualityGrade) {
      PotionQualityGrade.s => 4,
      PotionQualityGrade.a => 3,
      PotionQualityGrade.b => 2,
      PotionQualityGrade.c => 1,
      PotionQualityGrade.f => 0,
    };
    final int basePotency = (potion.qualityScore * 5).round() + qualityBonus;
    return max(1, (basePotency * (1 + bonusRate)).round());
  }

  int physicalAttackAffinity(String traitId) {
    if (const <String>{'t_atk', 't_crit'}.contains(traitId)) {
      return 3;
    }
    if (traitId == 't_focus') {
      return 2;
    }
    return 0;
  }

  int physicalDefenseAffinity(String traitId) {
    if (const <String>{'t_def', 't_pure'}.contains(traitId)) {
      return 3;
    }
    return 0;
  }

  int magicalAttackAffinity(String traitId) {
    if (const <String>{'t_mana', 't_dark'}.contains(traitId)) {
      return 3;
    }
    if (traitId == 't_focus') {
      return 2;
    }
    return 0;
  }

  int magicalDefenseAffinity(String traitId) {
    if (const <String>{'t_pure', 't_mana', 't_dark'}.contains(traitId)) {
      return 3;
    }
    return 0;
  }

  int maxHpAffinity(String traitId) {
    if (const <String>{'t_hp', 't_life', 't_regen'}.contains(traitId)) {
      return 6;
    }
    return 0;
  }

  int speedAffinity(String traitId) {
    if (traitId == 't_spd') {
      return 2;
    }
    if (traitId == 't_focus') {
      return 1;
    }
    return 0;
  }
}
