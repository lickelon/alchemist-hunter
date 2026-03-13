import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/session/application/session_providers.dart';

import 'crafted_inventory_domain.dart';

class WorkshopCraftedInventoryController {
  WorkshopCraftedInventoryController(
    this._session, {
    WorkshopCraftedInventoryDomain craftedInventoryDomain =
        const WorkshopCraftedInventoryDomain(),
  }) : _craftedInventoryDomain = craftedInventoryDomain;

  final SessionController _session;
  final WorkshopCraftedInventoryDomain _craftedInventoryDomain;

  void sellCraftedPotion(String stackKey, int quantity) {
    final SessionState current = _session.snapshot();
    final int owned = current.workshop.craftedPotionStacks[stackKey] ?? 0;
    final bool hasEnough = quantity > 0 && owned >= quantity;
    final bool hasDetails = current.workshop.craftedPotionDetails.containsKey(
      stackKey,
    );
    final SessionState nextState = _craftedInventoryDomain.sellCraftedPotion(
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

final Provider<WorkshopCraftedInventoryController>
workshopCraftedInventoryControllerProvider =
    Provider<WorkshopCraftedInventoryController>((Ref ref) {
      return WorkshopCraftedInventoryController(
        ref.read(sessionControllerProvider.notifier),
      );
    });
