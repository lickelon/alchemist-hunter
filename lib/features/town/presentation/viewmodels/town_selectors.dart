import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentInventoryView {
  const TownEquipmentInventoryView({
    required this.id,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
  });

  final String id;
  final String name;
  final String slotLabel;
  final String statLabel;
}

final Provider<int> townGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<ShopState> generalShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.generalShop,
    ),
  );
});

final Provider<ShopState> catalystShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.catalystShop,
    ),
  );
});

final Provider<List<EquipmentBlueprint>> townEquipmentBlueprintsProvider =
    Provider<List<EquipmentBlueprint>>((Ref ref) => townEquipmentBlueprints);

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

final Provider<List<TownEquipmentInventoryView>> townEquipmentInventoryViewsProvider =
    Provider<List<TownEquipmentInventoryView>>((Ref ref) {
      final List<EquipmentInstance> inventory = ref.watch(
        townEquipmentInventoryProvider,
      );
      return inventory.map((EquipmentInstance entry) {
        return TownEquipmentInventoryView(
          id: entry.id,
          name: entry.name,
          slotLabel: entry.slot.name,
          statLabel: 'ATK ${entry.attack} / DEF ${entry.defense} / HP ${entry.health}',
        );
      }).toList();
    });
