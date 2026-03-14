import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';

class TownUseCase {
  const TownUseCase();

  SessionState buyMaterial({
    required SessionState state,
    required ShopType shopType,
    required String materialId,
    required int quantity,
    required EconomyService economy,
  }) {
    final bool isGeneral = shopType == ShopType.general;
    final ShopState target = isGeneral
        ? state.town.generalShop
        : state.town.catalystShop;

    try {
      final ({int remainingGold, List<ShopItem> purchased}) result = economy
          .buyMaterial(
            currentGold: state.player.gold,
            items: target.items,
            itemId: materialId,
            quantity: quantity,
          );

      final Map<String, int> inventory = <String, int>{
        ...state.player.materialInventory,
      };
      inventory[materialId] = (inventory[materialId] ?? 0) + quantity;

      return state.copyWith(
        player: state.player.copyWith(
          gold: result.remainingGold,
          materialInventory: inventory,
        ),
        town: state.town.copyWith(
          generalShop: isGeneral
              ? target.copyWith(items: result.purchased)
              : state.town.generalShop,
          catalystShop: isGeneral
              ? state.town.catalystShop
              : target.copyWith(items: result.purchased),
        ),
      );
    } catch (_) {
      return state;
    }
  }

  SessionState forceRefresh({
    required SessionState state,
    required ShopType shopType,
    required DateTime now,
    required EconomyService economy,
    required ShopCatalogRepository shopCatalogRepository,
  }) {
    final bool isGeneral = shopType == ShopType.general;
    final ShopState target = isGeneral
        ? state.town.generalShop
        : state.town.catalystShop;
    final List<ShopItem> nextItems = isGeneral
        ? shopCatalogRepository.generalSeedItems()
        : shopCatalogRepository.catalystSeedItems();

    final ({ShopState shop, int costPaid}) refreshed = economy.forceRefresh(
      shop: target,
      now: now,
      nextItems: nextItems,
    );

    if (state.player.gold < refreshed.costPaid) {
      return state;
    }

    return state.copyWith(
      player: state.player.copyWith(
        gold: state.player.gold - refreshed.costPaid,
      ),
      town: state.town.copyWith(
        generalShop: isGeneral ? refreshed.shop : state.town.generalShop,
        catalystShop: isGeneral ? state.town.catalystShop : refreshed.shop,
      ),
    );
  }

  SessionState syncShops({
    required SessionState state,
    required DateTime now,
    required EconomyService economy,
    required ShopCatalogRepository shopCatalogRepository,
  }) {
    final ({ShopState shop, bool refreshed}) generalResult = economy
        .applyAutoRefresh(
          shop: state.town.generalShop,
          now: now,
          nextItems: shopCatalogRepository.generalSeedItems(),
          refreshInterval: const Duration(minutes: 15),
        );
    final ({ShopState shop, bool refreshed}) catalystResult = economy
        .applyAutoRefresh(
          shop: state.town.catalystShop,
          now: now,
          nextItems: shopCatalogRepository.catalystSeedItems(),
          refreshInterval: const Duration(minutes: 30),
        );

    if (!generalResult.refreshed && !catalystResult.refreshed) {
      return state;
    }

    return state.copyWith(
      town: state.town.copyWith(
        generalShop: generalResult.shop,
        catalystShop: catalystResult.shop,
      ),
    );
  }
}
