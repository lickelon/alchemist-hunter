import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopController {
  ShopController(
    this._session,
    this._economy, {
    TownUseCase townUseCase = const TownUseCase(),
    required ShopCatalogRepository shopCatalogRepository,
  }) : _townUseCase = townUseCase,
       _shopCatalogRepository = shopCatalogRepository;

  final SessionController _session;
  final EconomyService _economy;
  final TownUseCase _townUseCase;
  final ShopCatalogRepository _shopCatalogRepository;

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
      logMessage: identical(nextState, current)
          ? 'Purchase failed for $materialId'
          : 'Bought $quantity of $materialId (${ShopType.general.name})',
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
      logMessage: identical(nextState, current)
          ? 'Purchase failed for $materialId'
          : 'Bought $quantity of $materialId (${ShopType.catalyst.name})',
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
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Not enough gold for refresh'
          : 'Forced refresh ${shopType.name} shop',
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
      logMessage: identical(nextState, current)
          ? null
          : 'Auto refresh executed',
    );
  }

  void _apply(SessionState nextState, {String? logMessage}) {
    _session.applyState(nextState);
    if (logMessage != null) {
      _session.appendLog(logMessage);
    }
  }
}

final Provider<ShopController> shopControllerProvider =
    Provider<ShopController>((Ref ref) {
      return ShopController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(economyServiceProvider),
        shopCatalogRepository: ref.read(shopCatalogRepositoryProvider),
      );
    });
