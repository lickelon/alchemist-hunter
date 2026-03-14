import 'equipment_models.dart';
import 'mercenary_models.dart';
import 'shop_models.dart';
import 'town_skill_tree_models.dart';

class TownState {
  const TownState({
    required this.generalShop,
    required this.catalystShop,
    required this.equipmentInventory,
    required this.mercenaryCandidates,
    required this.mercenaryRefreshCount,
    required this.skillTree,
  });

  final ShopState generalShop;
  final ShopState catalystShop;
  final List<EquipmentInstance> equipmentInventory;
  final List<MercenaryCandidate> mercenaryCandidates;
  final int mercenaryRefreshCount;
  final TownSkillTreeState skillTree;

  TownState copyWith({
    ShopState? generalShop,
    ShopState? catalystShop,
    List<EquipmentInstance>? equipmentInventory,
    List<MercenaryCandidate>? mercenaryCandidates,
    int? mercenaryRefreshCount,
    TownSkillTreeState? skillTree,
  }) {
    return TownState(
      generalShop: generalShop ?? this.generalShop,
      catalystShop: catalystShop ?? this.catalystShop,
      equipmentInventory: equipmentInventory ?? this.equipmentInventory,
      mercenaryCandidates: mercenaryCandidates ?? this.mercenaryCandidates,
      mercenaryRefreshCount: mercenaryRefreshCount ?? this.mercenaryRefreshCount,
      skillTree: skillTree ?? this.skillTree,
    );
  }
}
