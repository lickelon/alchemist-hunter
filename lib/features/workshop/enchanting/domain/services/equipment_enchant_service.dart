import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_formula_service.dart';

class EquipmentEnchantService {
  const EquipmentEnchantService({
    EquipmentEnchantFormulaService formulaService =
        const EquipmentEnchantFormulaService(),
  }) : _formulaService = formulaService;

  final EquipmentEnchantFormulaService _formulaService;

  EquipmentEnchant buildEnchant({
    required EquipmentInstance equipment,
    required CraftedPotion potion,
    required PotionBlueprint blueprint,
    double potencyBonusRate = 0,
  }) {
    final String dominantTraitId = _formulaService.dominantTraitId(potion);
    final int potency = _formulaService.potency(potion, potencyBonusRate);

    switch (equipment.slot) {
      case EquipmentSlot.weapon:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
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
          statModifiers: _buildStatModifiers(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          modifiers: _buildModifiers(
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          passives: _buildPassives(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
        );
      case EquipmentSlot.armor:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
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
          statModifiers: _buildStatModifiers(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          modifiers: _buildModifiers(
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          passives: _buildPassives(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
        );
      case EquipmentSlot.accessory:
        return EquipmentEnchant(
          potionStackKey: '${potion.typePotionId}|${potion.qualityGrade.name}',
          potionName: blueprint.name,
          qualityLabel: potion.qualityGrade.name.toUpperCase(),
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
          statModifiers: _buildStatModifiers(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          modifiers: _buildModifiers(
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
          passives: _buildPassives(
            slot: equipment.slot,
            dominantTraitId: dominantTraitId,
            potency: potency,
          ),
        );
    }
  }

  List<BattleStatModifier> _buildStatModifiers({
    required EquipmentSlot slot,
    required String dominantTraitId,
    required int potency,
  }) {
    final String sourceId = 'enchant_$dominantTraitId';
    final List<BattleStatModifier> modifiers = <BattleStatModifier>[];

    switch (dominantTraitId) {
      case 't_crit':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.critRate,
            mode: BattleModifierMode.flat,
            value: 0.025 + (potency * 0.0006),
            sourceId: sourceId,
          ),
        );
      case 't_focus':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.accuracy,
            mode: BattleModifierMode.flat,
            value: 0.03 + (potency * 0.0006),
            sourceId: sourceId,
          ),
        );
      case 't_life':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.lifesteal,
            mode: BattleModifierMode.flat,
            value: 0.01 + (potency * 0.0005),
            sourceId: sourceId,
          ),
        );
      case 't_regen':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.regen,
            mode: BattleModifierMode.flat,
            value: 0.005 + (potency * 0.0004),
            sourceId: sourceId,
          ),
        );
      case 't_dark':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.critDamage,
            mode: BattleModifierMode.flat,
            value: 0.04 + (potency * 0.001),
            sourceId: sourceId,
          ),
        );
      case 't_mana':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.healingPower,
            mode: BattleModifierMode.flat,
            value: 0.03 + (potency * 0.0006),
            sourceId: sourceId,
          ),
        );
      case 't_pure':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.evasion,
            mode: BattleModifierMode.flat,
            value: 0.025 + (potency * 0.0006),
            sourceId: sourceId,
          ),
        );
      case 't_spd':
        modifiers.add(
          BattleStatModifier(
            type: BattleStatModifierType.evasion,
            mode: BattleModifierMode.flat,
            value: 0.02 + (potency * 0.0005),
            sourceId: sourceId,
          ),
        );
      default:
        break;
    }

    if (slot == EquipmentSlot.accessory && dominantTraitId == 't_focus') {
      modifiers.add(
        BattleStatModifier(
          type: BattleStatModifierType.critRate,
          mode: BattleModifierMode.flat,
          value: 0.01,
          sourceId: '${sourceId}_focus_crit',
        ),
      );
    }

    return modifiers;
  }

  List<BattleModifier> _buildModifiers({
    required String dominantTraitId,
    required int potency,
  }) {
    final String sourceId = 'enchant_$dominantTraitId';
    final List<BattleModifier> modifiers = <BattleModifier>[];

    switch (dominantTraitId) {
      case 't_atk':
        modifiers.add(
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.03 + (potency * 0.001),
            sourceId: sourceId,
          ),
        );
      case 't_def':
        modifiers.add(
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.03 - (potency * 0.0008),
            sourceId: sourceId,
          ),
        );
      default:
        break;
    }

    return modifiers;
  }

  List<BattlePassiveEffect> _buildPassives({
    required EquipmentSlot slot,
    required String dominantTraitId,
    required int potency,
  }) {
    if (slot == EquipmentSlot.accessory &&
        dominantTraitId == 't_spd' &&
        potency >= 9) {
      return const <BattlePassiveEffect>[
        BattlePassiveEffect(
          trigger: BattlePassiveTrigger.afterAction,
          type: BattlePassiveEffectType.extraAttack,
          sourceId: 'enchant_t_spd_extra_attack',
          value: 1,
        ),
      ];
    }

    if (slot == EquipmentSlot.weapon &&
        dominantTraitId == 't_focus' &&
        potency >= 10) {
      return const <BattlePassiveEffect>[
        BattlePassiveEffect(
          trigger: BattlePassiveTrigger.beforeHitCheck,
          type: BattlePassiveEffectType.alwaysHit,
          sourceId: 'enchant_t_focus_always_hit',
        ),
      ];
    }

    return const <BattlePassiveEffect>[];
  }
}
