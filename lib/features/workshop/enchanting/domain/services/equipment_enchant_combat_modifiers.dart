part of 'equipment_enchant_service.dart';

extension EquipmentEnchantCombatModifiers on EquipmentEnchantService {
  List<BattleModifier> buildModifiers({
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
}
