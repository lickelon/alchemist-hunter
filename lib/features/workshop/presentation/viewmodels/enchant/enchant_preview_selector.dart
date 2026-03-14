import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/enchant/enchant_equipment_lookup.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

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
            potencyBonusRate: ref
                .watch(workshopSkillTreeServiceProvider)
                .enchantPotencyBonusRate(
                  state,
                  ref.watch(workshopSkillNodesProvider),
                ),
          );
      final EquipmentInstance previewEquipment = equipment.copyWith(
        enchant: nextEnchant,
      );

      return EnchantPreviewView(
        equipmentName: equipment.name,
        currentEnchantLabel: equipment.enchant?.label ?? '인챈트 없음',
        nextEnchantLabel: nextEnchant.label,
        currentStatLabel:
            'ATK ${equipment.totalAttack} / DEF ${equipment.totalDefense} / HP ${equipment.totalHealth}',
        nextStatLabel:
            'ATK ${previewEquipment.totalAttack} / DEF ${previewEquipment.totalDefense} / HP ${previewEquipment.totalHealth}',
        deltaStatLabel:
            '변화 ${signedDelta(previewEquipment.totalAttack - equipment.totalAttack, "ATK")} / '
            '${signedDelta(previewEquipment.totalDefense - equipment.totalDefense, "DEF")} / '
            '${signedDelta(previewEquipment.totalHealth - equipment.totalHealth, "HP")}',
        replaceRequired: equipment.enchant != null,
      );
    });
