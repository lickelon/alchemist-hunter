import 'dart:math';

import 'package:alchemist_hunter/features/battle/application/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/application/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_logic.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/application/town_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession({DateTime? now}) {
    return SessionController(clock: () => now ?? DateTime(2026, 1, 1, 10));
  }

  TownController buildTownController(SessionController session) {
    return TownController(
      session,
      EconomyService(),
      townDomain: const TownDomain(),
      workshopDomain: const WorkshopDomain(),
    );
  }

  WorkshopController buildWorkshopController(
    SessionController session, {
    int queueSeed = 7,
    int craftingSeed = 13,
  }) {
    return WorkshopController(
      session,
      CraftQueueService(random: Random(queueSeed)),
      PotionCraftingService(random: Random(craftingSeed)),
      workshopDomain: const WorkshopDomain(),
    );
  }

  BattleController buildBattleController(
    SessionController session, {
    int battleSeed = 11,
  }) {
    return BattleController(
      session,
      BattleService(random: Random(battleSeed)),
      battleDomain: const BattleDomain(),
    );
  }

  test('buyGeneralMaterial updates gold inventory and shop stock', () {
    final SessionController session = buildSession();
    final TownController controller = buildTownController(session);

    final ShopItem item = session.state.town.generalShop.items.first;
    controller.buyGeneralMaterial(item.materialId, 2);

    expect(session.state.player.gold, 1400);
    expect(session.state.player.materialInventory[item.materialId], 2);
    expect(
      session.state.town.generalShop.items
          .firstWhere(
            (ShopItem current) => current.materialId == item.materialId,
          )
          .quantity,
      18,
    );
    expect(
      session.state.workshop.logs.first,
      'Bought 2 of ${item.materialId} (general)',
    );
  });

  test('forceRefresh updates shop and consumes gold', () {
    final SessionController session = buildSession();
    final TownController controller = buildTownController(session);
    final int previousGold = session.state.player.gold;
    final DateTime previousRefreshAt = session.state.town.generalShop.nextRefreshAt;

    controller.forceRefresh(ShopType.general);

    expect(session.state.player.gold, previousGold - 25);
    expect(session.state.town.generalShop.cycleRefreshCount, 1);
    expect(session.state.town.generalShop.nextRefreshAt, previousRefreshAt);
    expect(session.state.workshop.logs.first, 'Forced refresh general shop');
  });

  test('tickCraftQueue produces crafted potion entries', () {
    final SessionController session = buildSession();
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: <String, int>{'m_1': 2, 'm_2': 2},
      ),
    );
    final WorkshopController controller = buildWorkshopController(
      session,
      queueSeed: 3,
      craftingSeed: 5,
    );

    controller.enqueuePotion('p_1', 1);
    controller.tickCraftQueue();

    expect(session.state.workshop.queue.single.status, QueueJobStatus.completed);
    expect(
      session.state.workshop.craftedPotionStacks.values.fold<int>(
        0,
        (int sum, int value) => sum + value,
      ),
      1,
    );
    expect(session.state.workshop.craftedPotionDetails, isNotEmpty);
    expect(session.state.workshop.logs.first, 'Processed queue tick / produced 1');
    expect(session.state.player.materialInventory['m_1'], 1);
    expect(session.state.player.materialInventory['m_2'], 1);
  });

  test('enqueuePotion is blocked when materials are missing', () {
    final SessionController session = buildSession();
    final WorkshopController controller = buildWorkshopController(
      session,
      queueSeed: 3,
      craftingSeed: 5,
    );

    controller.enqueuePotion('p_1', 1);

    expect(session.state.workshop.queue, isEmpty);
    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(
      session.state.workshop.logs.first,
      'Cannot enqueue p_1 x1 / materials missing',
    );
  });

  test('sellCraftedPotion removes stack and adds gold', () {
    final SessionController session = buildSession();
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: <String, int>{'m_1': 2, 'm_2': 2},
      ),
    );
    final WorkshopController workshopController = buildWorkshopController(
      session,
      queueSeed: 3,
      craftingSeed: 5,
    );
    final TownController townController = buildTownController(session);

    workshopController.enqueuePotion('p_1', 1);
    workshopController.tickCraftQueue();

    final String stackKey = session.state.workshop.craftedPotionStacks.keys.first;
    final int previousGold = session.state.player.gold;

    townController.sellCraftedPotion(stackKey, 1);

    expect(session.state.player.gold, greaterThan(previousGold));
    expect(session.state.workshop.craftedPotionStacks.containsKey(stackKey), false);
    expect(
      session.state.workshop.logs.first,
      startsWith('Sold potion $stackKey x1 for '),
    );
  });

  test('runAutoBattle updates rewards and progression state', () {
    final SessionController session = buildSession();
    final BattleController controller = buildBattleController(session);
    final int previousGold = session.state.player.gold;
    final int previousEssence = session.state.player.essence;
    final int previousMercLevel = session.state.characters.mercenaries.first.level;
    final int previousMercXp = session.state.characters.mercenaries.first.xp;
    final int previousHomoLevel = session.state.characters.homunculi.first.level;
    final int previousHomoXp = session.state.characters.homunculi.first.xp;

    controller.runAutoBattle('stage_1');

    expect(session.state.player.gold, isNot(previousGold));
    expect(session.state.player.essence, greaterThan(previousEssence));
    expect(session.state.player.materialInventory, isNotEmpty);
    expect(
      session.state.characters.mercenaries.first.level > previousMercLevel ||
          session.state.characters.mercenaries.first.xp > previousMercXp,
      true,
    );
    expect(
      session.state.characters.homunculi.first.level > previousHomoLevel ||
          session.state.characters.homunculi.first.xp > previousHomoXp,
      true,
    );
    expect(session.state.workshop.logs.first, contains('Battle '));
  });

  test('runAutoBattle does not overflow xp at rank max level', () {
    final SessionController session = buildSession();
    final BattleController controller = buildBattleController(session);
    final CharacterProgress merc = session.state.characters.mercenaries.first;
    final CharacterProgress homo = session.state.characters.homunculi.first;

    session.state = session.state.copyWith(
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          merc.copyWith(level: merc.maxLevelForRank, xp: 999),
        ],
        homunculi: <CharacterProgress>[
          homo.copyWith(level: homo.maxLevelForRank, xp: 999),
        ],
      ),
    );

    controller.runAutoBattle('stage_5');

    expect(session.state.characters.mercenaries.first.level, merc.maxLevelForRank);
    expect(session.state.characters.homunculi.first.level, homo.maxLevelForRank);
    expect(session.state.characters.mercenaries.first.xp, 0);
    expect(session.state.characters.homunculi.first.xp, 0);
  });
}
