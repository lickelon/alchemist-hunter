part of 'equipment_enchant_service.dart';

extension EquipmentEnchantBuilder on EquipmentEnchantService {
  EquipmentEnchant buildEquipmentEnchant({
    required EquipmentInstance equipment,
    required CraftedPotion potion,
    required PotionBlueprint blueprint,
    double potencyBonusRate = 0,
  }) {
    final String dominantTraitId = _formulaService.dominantTraitId(potion);
    final int potency = _formulaService.potency(potion, potencyBonusRate);
    final String potionStackKey =
        '${potion.typePotionId}|${potion.qualityGrade.name}';
    final String qualityLabel = potion.qualityGrade.name.toUpperCase();
    final List<BattleStatModifier> statModifiers = buildStatModifiers(
      slot: equipment.slot,
      dominantTraitId: dominantTraitId,
      potency: potency,
    );
    final List<BattleModifier> modifiers = buildModifiers(
      dominantTraitId: dominantTraitId,
      potency: potency,
    );
    final List<BattlePassiveEffect> passives = buildPassives(
      slot: equipment.slot,
      dominantTraitId: dominantTraitId,
      potency: potency,
    );

    switch (equipment.slot) {
      case EquipmentSlot.weapon:
        return EquipmentEnchant(
          potionStackKey: potionStackKey,
          potionName: blueprint.name,
          qualityLabel: qualityLabel,
          dominantTraitId: dominantTraitId,
          maxHpBonus: potency + _formulaService.maxHpAffinity(dominantTraitId),
          physicalAttackBonus:
              max(1, potency ~/ 2) +
              _formulaService.physicalAttackAffinity(dominantTraitId),
          physicalDefenseBonus: max(0, potency ~/ 4),
          magicalAttackBonus: _formulaService.magicalAttackAffinity(
            dominantTraitId,
          ),
          magicalDefenseBonus:
              max(0, potency ~/ 5) +
              _formulaService.magicalDefenseAffinity(dominantTraitId),
          speedBonus: _formulaService.speedAffinity(dominantTraitId),
          statModifiers: statModifiers,
          modifiers: modifiers,
          passives: passives,
        );
      case EquipmentSlot.armor:
        return EquipmentEnchant(
          potionStackKey: potionStackKey,
          potionName: blueprint.name,
          qualityLabel: qualityLabel,
          dominantTraitId: dominantTraitId,
          maxHpBonus:
              (potency * 2) + _formulaService.maxHpAffinity(dominantTraitId),
          physicalAttackBonus: max(0, potency ~/ 6),
          physicalDefenseBonus:
              max(1, (potency * 3) ~/ 4) +
              _formulaService.physicalDefenseAffinity(dominantTraitId),
          magicalAttackBonus: max(0, potency ~/ 8),
          magicalDefenseBonus:
              max(0, potency ~/ 3) +
              _formulaService.magicalDefenseAffinity(dominantTraitId),
          speedBonus: _formulaService.speedAffinity(dominantTraitId),
          statModifiers: statModifiers,
          modifiers: modifiers,
          passives: passives,
        );
      case EquipmentSlot.accessory:
        return EquipmentEnchant(
          potionStackKey: potionStackKey,
          potionName: blueprint.name,
          qualityLabel: qualityLabel,
          dominantTraitId: dominantTraitId,
          maxHpBonus:
              (potency * 2) + _formulaService.maxHpAffinity(dominantTraitId),
          physicalAttackBonus:
              max(0, potency ~/ 3) +
              _formulaService.physicalAttackAffinity(dominantTraitId),
          physicalDefenseBonus:
              max(0, potency ~/ 3) +
              _formulaService.physicalDefenseAffinity(dominantTraitId),
          magicalAttackBonus:
              max(0, potency ~/ 3) +
              _formulaService.magicalAttackAffinity(dominantTraitId),
          magicalDefenseBonus:
              max(0, potency ~/ 3) +
              _formulaService.magicalDefenseAffinity(dominantTraitId),
          speedBonus:
              max(0, potency ~/ 6) +
              _formulaService.speedAffinity(dominantTraitId),
          statModifiers: statModifiers,
          modifiers: modifiers,
          passives: passives,
        );
    }
  }
}
