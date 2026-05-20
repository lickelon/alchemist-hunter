import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopController {
  ShopController(
    this._session,
    this._economy, {
    TownUseCase townUseCase = const TownUseCase(),
    required ShopCatalogRepository shopCatalogRepository,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
  }) : _townUseCase = townUseCase,
       _shopCatalogRepository = shopCatalogRepository,
       _townSkillTreeRepository = townSkillTreeRepository,
       _townSkillTreeService = townSkillTreeService;

  final SessionController _session;
  final EconomyService _economy;
  final TownUseCase _townUseCase;
  final ShopCatalogRepository _shopCatalogRepository;
  final TownSkillTreeRepository _townSkillTreeRepository;
  final TownSkillTreeService _townSkillTreeService;

  void buyGeneralMaterial(String materialId, int quantity) {
    syncShopAutoRefresh();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townUseCase.buyMaterial(
      state: current,
      shopType: ShopType.general,
      materialId: materialId,
      quantity: quantity,
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: _purchaseLogMessage(
        current: current,
        nextState: nextState,
        shopType: ShopType.general,
        materialId: materialId,
        quantity: quantity,
      ),
    );
  }

  void buyCatalystMaterial(String materialId, int quantity) {
    syncShopAutoRefresh();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townUseCase.buyMaterial(
      state: current,
      shopType: ShopType.catalyst,
      materialId: materialId,
      quantity: quantity,
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: _purchaseLogMessage(
        current: current,
        nextState: nextState,
        shopType: ShopType.catalyst,
        materialId: materialId,
        quantity: quantity,
      ),
    );
  }

  void forceRefresh(ShopType shopType) {
    syncShopAutoRefresh();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townUseCase.forceRefresh(
      state: current,
      shopType: shopType,
      now: _session.now(),
      economy: _economy,
      shopCatalogRepository: _shopCatalogRepository,
      townSkillTreeRepository: _townSkillTreeRepository,
      townSkillTreeService: _townSkillTreeService,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? _forceRefreshFailureLog(current, shopType)
          : '상점 갱신 / ${_shopLabel(shopType)}',
    );
  }

  void syncShopAutoRefresh() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townUseCase.syncShops(
      state: current,
      now: _session.now(),
      economy: _economy,
      shopCatalogRepository: _shopCatalogRepository,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current) ? null : '상점 자동 갱신',
    );
  }

  void _apply(SessionState nextState, {String? logMessage}) {
    _session.applyState(nextState);
    if (logMessage != null) {
      _session.appendLog(logMessage);
    }
  }

  String _purchaseLogMessage({
    required SessionState current,
    required SessionState nextState,
    required ShopType shopType,
    required String materialId,
    required int quantity,
  }) {
    final ShopItem? item = _findShopItem(current, shopType, materialId);
    final String itemName = item?.name ?? materialId;
    if (!identical(nextState, current)) {
      return '재료 구매 / $itemName x$quantity / ${_shopLabel(shopType)}';
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

  String _forceRefreshFailureLog(SessionState current, ShopType shopType) {
    final ShopState shop = _shopFor(current, shopType);
    final int effectiveCost = _townSkillTreeService.discountedGoldCost(
      baseCost: shop.forcedRefreshCost,
      discountRate: _townSkillTreeService.shopRefreshDiscountRate(
        current,
        _townSkillTreeRepository.nodes(),
      ),
    );
    if (current.player.gold < effectiveCost) {
      return '골드 부족 / ${_shopLabel(shopType)} 갱신';
    }
    return '상점 갱신 실패 / ${_shopLabel(shopType)}';
  }

  ShopState _shopFor(SessionState state, ShopType shopType) {
    return shopType == ShopType.general
        ? state.town.generalShop
        : state.town.catalystShop;
  }

  ShopItem? _findShopItem(
    SessionState state,
    ShopType shopType,
    String materialId,
  ) {
    for (final ShopItem item in _shopFor(state, shopType).items) {
      if (item.materialId == materialId) {
        return item;
      }
    }
    return null;
  }

  String _shopLabel(ShopType shopType) {
    return switch (shopType) {
      ShopType.general => '일반 상점',
      ShopType.catalyst => '촉매 상점',
    };
  }
}

final Provider<ShopController> shopControllerProvider =
    Provider<ShopController>((Ref ref) {
      return ShopController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(economyServiceProvider),
        shopCatalogRepository: ref.read(shopCatalogRepositoryProvider),
        townSkillTreeRepository: ref.read(townSkillTreeRepositoryProvider),
        townSkillTreeService: ref.read(townSkillTreeServiceProvider),
      );
    });
