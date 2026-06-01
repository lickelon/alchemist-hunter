part of 'equipment_enchant_service.dart';

extension EquipmentEnchantStatModifiers on EquipmentEnchantService {
  List<BattleStatModifier> buildStatModifiers({
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
}
