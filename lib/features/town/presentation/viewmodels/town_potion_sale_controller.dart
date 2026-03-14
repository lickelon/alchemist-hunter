import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/sell_crafted_potion_use_case.dart';

class TownPotionSaleController {
  TownPotionSaleController(
    this._session, {
    SellCraftedPotionUseCase sellCraftedPotionUseCase =
        const SellCraftedPotionUseCase(),
  }) : _sellCraftedPotionUseCase = sellCraftedPotionUseCase;

  final SessionController _session;
  final SellCraftedPotionUseCase _sellCraftedPotionUseCase;

  void sellCraftedPotion(String stackKey, int quantity) {
    final SessionState current = _session.snapshot();
    final int owned = current.workshop.craftedPotionStacks[stackKey] ?? 0;
    final bool hasEnough = quantity > 0 && owned >= quantity;
    final bool hasDetails = current.workshop.craftedPotionDetails.containsKey(
      stackKey,
    );
    final SessionState nextState = _sellCraftedPotionUseCase.sellCraftedPotion(
      state: current,
      stackKey: stackKey,
      quantity: quantity,
    );
    final int earned = nextState.player.gold - current.player.gold;
    _session.applyState(nextState);
    _session.appendLog(
      !hasEnough
          ? 'Not enough crafted potion to sell'
          : !hasDetails
          ? 'Potion detail not found'
          : 'Sold potion $stackKey x$quantity for $earned gold',
    );
  }
}

final Provider<TownPotionSaleController> townPotionSaleControllerProvider =
    Provider<TownPotionSaleController>((Ref ref) {
      return TownPotionSaleController(
        ref.read(sessionControllerProvider.notifier),
      );
    });
