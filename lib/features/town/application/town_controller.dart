import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/application/town_domain.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_domain.dart';
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
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.buyMaterial(
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
    _syncShops();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.buyMaterial(
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
    _syncShops();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.forceRefresh(
      state: current,
      shopType: shopType,
      now: _session.now(),
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Not enough gold for refresh'
          : 'Forced refresh ${shopType.name} shop',
    );
  }

  void sellCraftedPotion(String stackKey, int quantity) {
    final SessionState current = _session.snapshot();
    final int owned = current.workshop.craftedPotionStacks[stackKey] ?? 0;
    final bool hasEnough = quantity > 0 && owned >= quantity;
    final bool hasDetails = current.workshop.craftedPotionDetails.containsKey(
      stackKey,
    );
    final SessionState nextState = _workshopDomain.sellCraftedPotion(
      state: current,
      stackKey: stackKey,
      quantity: quantity,
    );
    final int earned = nextState.player.gold - current.player.gold;
    _apply(
      nextState,
      logMessage: !hasEnough
          ? 'Not enough crafted potion to sell'
          : !hasDetails
          ? 'Potion detail not found'
          : 'Sold potion $stackKey x$quantity for $earned gold',
    );
  }

  void syncShopAutoRefresh() {
    _syncShops();
  }

  void _syncShops() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.syncShops(
      state: current,
      now: _session.now(),
      economy: _economy,
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

final Provider<TownController> townControllerProvider =
    Provider<TownController>((Ref ref) {
      return TownController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(economyServiceProvider),
      );
    });
