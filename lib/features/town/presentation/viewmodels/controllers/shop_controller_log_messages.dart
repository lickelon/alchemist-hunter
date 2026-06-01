import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';

String shopPurchaseLogMessage({
  required SessionState current,
  required SessionState nextState,
  required ShopType shopType,
  required String materialId,
  required int quantity,
}) {
  final ShopItem? item = findShopItem(current, shopType, materialId);
  final String itemName = item?.name ?? materialId;
  if (!identical(nextState, current)) {
    return '재료 구매 / $itemName x$quantity / ${shopTypeLabel(shopType)}';
  }
  if (quantity < 1) {
    return '구매 수량 오류 / $itemName';
  }
  if (item == null || item.quantity < quantity) {
    return '재료 부족 / $itemName x$quantity';
  }
  if (current.player.gold < item.price * quantity) {
    return '골드 부족 / $itemName x$quantity';
  }
  return '구매 실패 / $itemName x$quantity';
}

String shopForceRefreshFailureLog({
  required SessionState current,
  required ShopType shopType,
  required TownSkillTreeRepository townSkillTreeRepository,
  required TownSkillTreeService townSkillTreeService,
}) {
  final ShopState shop = shopFor(current, shopType);
  final int effectiveCost = townSkillTreeService.discountedGoldCost(
    baseCost: shop.forcedRefreshCost,
    discountRate: townSkillTreeService.shopRefreshDiscountRate(
      current,
      townSkillTreeRepository.nodes(),
    ),
  );
  if (current.player.gold < effectiveCost) {
    return '골드 부족 / ${shopTypeLabel(shopType)} 갱신';
  }
  return '상점 갱신 실패 / ${shopTypeLabel(shopType)}';
}

ShopState shopFor(SessionState state, ShopType shopType) {
  return shopType == ShopType.general
      ? state.town.generalShop
      : state.town.catalystShop;
}

ShopItem? findShopItem(
  SessionState state,
  ShopType shopType,
  String materialId,
) {
  for (final ShopItem item in shopFor(state, shopType).items) {
    if (item.materialId == materialId) {
      return item;
    }
  }
  return null;
}

String shopTypeLabel(ShopType shopType) {
  return switch (shopType) {
    ShopType.general => '일반 상점',
    ShopType.catalyst => '촉매 상점',
  };
}
