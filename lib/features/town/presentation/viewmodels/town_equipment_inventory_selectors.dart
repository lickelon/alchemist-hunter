import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_effect_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_slot_labels.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_view_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<EquipmentInstance>> townEquipmentInventoryProvider =
    Provider<List<EquipmentInstance>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.town.equipmentInventory,
        ),
      );
    });

final Provider<int> townEquipmentCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townEquipmentInventoryProvider.select(
      (List<EquipmentInstance> inventory) => inventory.length,
    ),
  );
});

final Provider<List<TownEquipmentInventoryView>>
townEquipmentInventoryViewsProvider =
    Provider<List<TownEquipmentInventoryView>>((Ref ref) {
      final List<EquipmentInstance> inventory = ref.watch(
        townEquipmentInventoryProvider,
      );
      return inventory
          .map((EquipmentInstance entry) {
            return TownEquipmentInventoryView(
              id: entry.id,
              blueprintId: entry.blueprintId,
              name: entry.name,
              slotLabel: equipmentSlotLabel(entry.slot),
              statLabels: equipmentInstanceStatLabels(entry),
              effectLabels: equipmentInstanceEffectLabels(entry),
            );
          })
          .toList(growable: false);
    });
