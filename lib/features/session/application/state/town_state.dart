import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class TownState {
  const TownState({required this.generalShop, required this.catalystShop});

  final ShopState generalShop;
  final ShopState catalystShop;

  TownState copyWith({ShopState? generalShop, ShopState? catalystShop}) {
    return TownState(
      generalShop: generalShop ?? this.generalShop,
      catalystShop: catalystShop ?? this.catalystShop,
    );
  }
}
