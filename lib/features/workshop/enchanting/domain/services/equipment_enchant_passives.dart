part of 'equipment_enchant_service.dart';

extension EquipmentEnchantPassives on EquipmentEnchantService {
  List<BattlePassiveEffect> buildPassives({
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
