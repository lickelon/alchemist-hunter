import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_detail_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_lookup.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchanting_service_providers.dart';

class EnchantPreviewView {
  const EnchantPreviewView({
    required this.equipmentName,
    required this.currentEnchantLabel,
    required this.nextEnchantLabel,
    required this.currentStatLabel,
    required this.nextStatLabel,
    required this.deltaStatLabel,
    required this.replaceRequired,
  });

  final String equipmentName;
  final String currentEnchantLabel;
  final String nextEnchantLabel;
  final String currentStatLabel;
  final String nextStatLabel;
  final String deltaStatLabel;
  final bool replaceRequired;
}

final enchantPreviewProvider =
    Provider.family<
      EnchantPreviewView?,
      ({String? potionStackKey, String? equipmentId})
    >((Ref ref, ({String? potionStackKey, String? equipmentId}) args) {
      final String? potionStackKey = args.potionStackKey;
      final String? equipmentId = args.equipmentId;
      if (potionStackKey == null || equipmentId == null) {
        return null;
      }

      final SessionState state = ref.watch(sessionControllerProvider);
      final CraftedPotion? potion =
          state.workshop.craftedPotionDetails[potionStackKey];
      if (potion == null) {
        return null;
      }

      final PotionBlueprint? blueprint = ref
          .watch(potionCatalogRepositoryProvider)
          .findPotionById(potion.typePotionId);
      final EquipmentInstance? equipment = findEnchantEquipmentById(
        state,
        equipmentId,
      );
      if (blueprint == null || equipment == null) {
        return null;
      }

      final EquipmentEnchant nextEnchant = ref
          .watch(equipmentEnchantServiceProvider)
          .buildEnchant(
            equipment: equipment,
            potion: potion,
            blueprint: blueprint,
            potencyBonusRate: ref.watch(
              workshopEnchantPotencyBonusRateProvider,
            ),
          );
      final EquipmentInstance previewEquipment = equipment.copyWith(
        enchant: nextEnchant,
      );

      return EnchantPreviewView(
        equipmentName: equipment.name,
        currentEnchantLabel: equipment.enchant == null
            ? '인챈트 없음'
            : equipmentEnchantLabel(equipment.enchant!),
        nextEnchantLabel: equipmentEnchantLabel(nextEnchant),
        currentStatLabel: equipmentInstanceDetailLabel(equipment),
        nextStatLabel: equipmentInstanceDetailLabel(previewEquipment),
        deltaStatLabel:
            '변화 ${formatEquipmentStatLabel(maxHp: previewEquipment.totalMaxHp - equipment.totalMaxHp, physicalAttack: previewEquipment.totalPhysicalAttack - equipment.totalPhysicalAttack, physicalDefense: previewEquipment.totalPhysicalDefense - equipment.totalPhysicalDefense, magicalAttack: previewEquipment.totalMagicalAttack - equipment.totalMagicalAttack, magicalDefense: previewEquipment.totalMagicalDefense - equipment.totalMagicalDefense, speed: previewEquipment.totalSpeed - equipment.totalSpeed, signed: true, includeZero: false, emptyLabel: '없음')}',
        replaceRequired: equipment.enchant != null,
      );
    });
