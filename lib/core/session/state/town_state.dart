import 'package:alchemist_hunter/features/town/domain/models.dart';

class TownState {
  const TownState({
    required this.generalShop,
    required this.catalystShop,
    required this.equipmentInventory,
  });

  final ShopState generalShop;
  final ShopState catalystShop;
  final List<EquipmentInstance> equipmentInventory;

  TownState copyWith({
    ShopState? generalShop,
    ShopState? catalystShop,
    List<EquipmentInstance>? equipmentInventory,
  }) {
    return TownState(
      generalShop: generalShop ?? this.generalShop,
      catalystShop: catalystShop ?? this.catalystShop,
      equipmentInventory: equipmentInventory ?? this.equipmentInventory,
    );
  }
}
