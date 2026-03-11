import 'package:alchemist_hunter/features/session/application/session_logic.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<EconomyService> economyServiceProvider =
    Provider<EconomyService>((Ref ref) => EconomyService());

class TownController {
  TownController(
    this._session,
    this._economy, {
    TownDomain townDomain = const TownDomain(),
    WorkshopDomain workshopDomain = const WorkshopDomain(),
  }) : _townDomain = townDomain,
       _workshopDomain = workshopDomain;

  final SessionController _session;
  final EconomyService _economy;
  final TownDomain _townDomain;
  final WorkshopDomain _workshopDomain;

  void buyGeneralMaterial(String materialId, int quantity) {
    _syncShops();
    _session.applyMutation(
      _townDomain.buyMaterial(
        state: _session.snapshot(),
        shopType: ShopType.general,
        materialId: materialId,
        quantity: quantity,
        economy: _economy,
      ),
    );
  }

  void buyCatalystMaterial(String materialId, int quantity) {
    _syncShops();
    _session.applyMutation(
      _townDomain.buyMaterial(
        state: _session.snapshot(),
        shopType: ShopType.catalyst,
        materialId: materialId,
        quantity: quantity,
        economy: _economy,
      ),
    );
  }

  void forceRefresh(ShopType shopType) {
    _syncShops();
    _session.applyMutation(
      _townDomain.forceRefresh(
        state: _session.snapshot(),
        shopType: shopType,
        now: _session.now(),
        economy: _economy,
      ),
    );
  }

  void sellCraftedPotion(String stackKey, int quantity) {
    _session.applyMutation(
      _workshopDomain.sellCraftedPotion(
        state: _session.snapshot(),
        stackKey: stackKey,
        quantity: quantity,
      ),
    );
  }

  void syncShopAutoRefresh() {
    _syncShops();
  }

  void _syncShops() {
    _session.applyMutation(
      _townDomain.syncShops(
        state: _session.snapshot(),
        now: _session.now(),
        economy: _economy,
      ),
    );
  }
}

final Provider<TownController> townControllerProvider =
    Provider<TownController>((Ref ref) {
      return TownController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(economyServiceProvider),
      );
    });

final Provider<int> townGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<ShopState> generalShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.town.generalShop),
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

final Provider<Map<String, int>> sellablePotionStacksProvider =
    Provider<Map<String, int>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionStacks,
        ),
      );
    });

final Provider<Map<String, CraftedPotion>> sellablePotionDetailsProvider =
    Provider<Map<String, CraftedPotion>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionDetails,
        ),
      );
    });
