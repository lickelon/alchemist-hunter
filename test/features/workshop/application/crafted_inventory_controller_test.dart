import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/crafted_inventory/crafted_inventory_controller.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  test('sellCraftedPotion removes stack and adds gold', () {
    final SessionController session = buildSession();
    final WorkshopCraftedInventoryController controller =
        WorkshopCraftedInventoryController(session);
    const String stackKey = 'p_1|a';
    final CraftedPotion sample = CraftedPotion(
      id: 'crafted_1',
      typePotionId: 'p_1',
      qualityGrade: PotionQualityGrade.a,
      qualityScore: 0.82,
      traits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      createdAt: DateTime(2026, 1, 1, 10),
    );

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{stackKey: 1},
        craftedPotionDetails: <String, CraftedPotion>{stackKey: sample},
      ),
    );

    final int previousGold = session.state.player.gold;
    controller.sellCraftedPotion(stackKey, 1);

    expect(session.state.player.gold, greaterThan(previousGold));
    expect(
      session.state.workshop.craftedPotionStacks.containsKey(stackKey),
      false,
    );
    expect(
      session.state.workshop.logs.first,
      startsWith('Sold potion $stackKey x1 for '),
    );
  });
}
