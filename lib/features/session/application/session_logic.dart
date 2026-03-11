import 'package:alchemist_hunter/features/battle/application/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

import 'session_providers.dart';

SessionState createInitialSessionState(DateTime now) {
  return SessionState(
    player: const PlayerState(
      gold: 1500,
      essence: 120,
      diamonds: 100,
      materialInventory: <String, int>{},
    ),
    town: TownState(
      generalShop: DummyData.generalShopState(now),
      catalystShop: DummyData.catalystShopState(now),
    ),
    workshop: const WorkshopState(
      queue: <CraftQueueJob>[],
      craftedPotionStacks: <String, int>{},
      craftedPotionDetails: <String, CraftedPotion>{},
      logs: <String>['Game initialized'],
    ),
    battle: const BattleState(
      progress: ProgressState(
        unlockFlags: <String>{'stage_1'},
        automationTier: 1,
        sessionPhase: SessionPhase.early,
      ),
    ),
    characters: const CharactersState(
      mercenaries: <CharacterProgress>[
        CharacterProgress(
          id: 'merc_1',
          name: 'Rookie Swordsman',
          type: CharacterType.mercenary,
          level: 1,
          rank: 1,
          xp: 0,
          mercenaryTier: MercenaryTier.rookie,
        ),
      ],
      homunculi: <CharacterProgress>[
        CharacterProgress(
          id: 'homo_1',
          name: 'Nigredo Seed',
          type: CharacterType.homunculus,
          level: 1,
          rank: 1,
          xp: 0,
          homunculusTier: HomunculusTier.nigredo,
        ),
      ],
    ),
  );
}

class SessionMutationResult {
  const SessionMutationResult({required this.state, this.logMessage});

  final SessionState state;
  final String? logMessage;
}

class TownDomain {
  const TownDomain();

  SessionMutationResult buyMaterial({
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

      return SessionMutationResult(
        state: state.copyWith(
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
        ),
        logMessage: 'Bought $quantity of $materialId (${shopType.name})',
      );
    } catch (_) {
      return SessionMutationResult(
        state: state,
        logMessage: 'Purchase failed for $materialId',
      );
    }
  }

  SessionMutationResult forceRefresh({
    required SessionState state,
    required ShopType shopType,
    required DateTime now,
    required EconomyService economy,
  }) {
    final bool isGeneral = shopType == ShopType.general;
    final ShopState target = isGeneral
        ? state.town.generalShop
        : state.town.catalystShop;
    final List<ShopItem> nextItems = isGeneral
        ? DummyData.buildGeneralShopItems()
        : DummyData.buildCatalystShopItems();

    final ({ShopState shop, int costPaid}) refreshed = economy.forceRefresh(
      shop: target,
      now: now,
      nextItems: nextItems,
    );

    if (state.player.gold < refreshed.costPaid) {
      return SessionMutationResult(
        state: state,
        logMessage: 'Not enough gold for refresh',
      );
    }

    return SessionMutationResult(
      state: state.copyWith(
        player: state.player.copyWith(gold: state.player.gold - refreshed.costPaid),
        town: state.town.copyWith(
          generalShop: isGeneral ? refreshed.shop : state.town.generalShop,
          catalystShop: isGeneral ? state.town.catalystShop : refreshed.shop,
        ),
      ),
      logMessage: 'Forced refresh ${shopType.name} shop',
    );
  }

  SessionMutationResult syncShops({
    required SessionState state,
    required DateTime now,
    required EconomyService economy,
  }) {
    final ({ShopState shop, bool refreshed}) generalResult = economy
        .applyAutoRefresh(
          shop: state.town.generalShop,
          now: now,
          nextItems: DummyData.buildGeneralShopItems(),
          refreshInterval: const Duration(minutes: 15),
        );
    final ({ShopState shop, bool refreshed}) catalystResult = economy
        .applyAutoRefresh(
          shop: state.town.catalystShop,
          now: now,
          nextItems: DummyData.buildCatalystShopItems(),
          refreshInterval: const Duration(minutes: 30),
        );

    if (!generalResult.refreshed && !catalystResult.refreshed) {
      return SessionMutationResult(state: state);
    }

    return SessionMutationResult(
      state: state.copyWith(
        town: state.town.copyWith(
          generalShop: generalResult.shop,
          catalystShop: catalystResult.shop,
        ),
      ),
      logMessage: 'Auto refresh executed',
    );
  }
}

class WorkshopDomain {
  const WorkshopDomain();

  SessionMutationResult enqueuePotion({
    required SessionState state,
    required String potionId,
    required int repeatCount,
    required DateTime now,
    required CraftQueueService queueService,
  }) {
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.millisecondsSinceEpoch}',
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: const CraftRetryPolicy(maxRetries: 2),
      status: QueueJobStatus.queued,
      eta: const Duration(seconds: 15),
    );

    return SessionMutationResult(
      state: state.copyWith(
        workshop: state.workshop.copyWith(
          queue: queueService.enqueue(state.workshop.queue, job),
        ),
      ),
      logMessage: 'Enqueued $potionId x$repeatCount',
    );
  }

  SessionMutationResult tickCraftQueue({
    required SessionState state,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
  }) {
    final List<CraftQueueJob> previousQueue = state.workshop.queue;
    final List<CraftQueueJob> nextQueue = queueService.processTick(
      state.workshop.queue,
      const Duration(seconds: 15),
    );

    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };

    int producedCount = 0;
    for (final CraftQueueJob job in nextQueue) {
      final CraftQueueJob? previousJob = previousQueue
          .where((CraftQueueJob candidate) => candidate.id == job.id)
          .firstOrNull;
      if (job.status != QueueJobStatus.completed || previousJob == null) {
        continue;
      }
      if (previousJob.status == QueueJobStatus.completed) {
        continue;
      }

      final PotionBlueprint blueprint = _findBlueprint(job.potionId);
      for (int index = 0; index < job.currentRepeat; index++) {
        final Map<String, double> inputTraits = craftingService
            .generateCraftInputTraits(blueprint);
        final CraftedPotion crafted = craftingService.craftPotion(
          requestedBlueprint: blueprint,
          extractedTraits: inputTraits,
          recipeRules: DummyData.potionRecipeRules,
          branchRules: DummyData.potionRecipeBranchRules,
          qualityRule: DummyData.potionQualityRule,
        );
        final String stackKey =
            '${crafted.typePotionId}|${crafted.qualityGrade.name}';
        stacks[stackKey] = (stacks[stackKey] ?? 0) + 1;
        details.putIfAbsent(stackKey, () => crafted);
        producedCount += 1;
      }
    }

    return SessionMutationResult(
      state: state.copyWith(
        workshop: state.workshop.copyWith(
          queue: nextQueue,
          craftedPotionStacks: stacks,
          craftedPotionDetails: details,
        ),
      ),
      logMessage: 'Processed queue tick / produced $producedCount',
    );
  }

  SessionMutationResult sellCraftedPotion({
    required SessionState state,
    required String stackKey,
    required int quantity,
  }) {
    final int owned = state.workshop.craftedPotionStacks[stackKey] ?? 0;
    if (quantity < 1 || owned < quantity) {
      return SessionMutationResult(
        state: state,
        logMessage: 'Not enough crafted potion to sell',
      );
    }

    final CraftedPotion? sample = state.workshop.craftedPotionDetails[stackKey];
    if (sample == null) {
      return SessionMutationResult(
        state: state,
        logMessage: 'Potion detail not found',
      );
    }

    final PotionBlueprint blueprint = _findBlueprint(sample.typePotionId);
    final double multiplier = switch (sample.qualityGrade) {
      PotionQualityGrade.s => 1.6,
      PotionQualityGrade.a => 1.3,
      PotionQualityGrade.b => 1.0,
      PotionQualityGrade.c => 0.8,
    };
    final int earned = (blueprint.baseValue * multiplier * quantity).round();

    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };
    final int nextQuantity = owned - quantity;

    if (nextQuantity <= 0) {
      stacks.remove(stackKey);
      details.remove(stackKey);
    } else {
      stacks[stackKey] = nextQuantity;
    }

    return SessionMutationResult(
      state: state.copyWith(
        player: state.player.copyWith(gold: state.player.gold + earned),
        workshop: state.workshop.copyWith(
          craftedPotionStacks: stacks,
          craftedPotionDetails: details,
        ),
      ),
      logMessage: 'Sold potion $stackKey x$quantity for $earned gold',
    );
  }

  PotionBlueprint _findBlueprint(String potionId) {
    return DummyData.potions.firstWhere(
      (PotionBlueprint potion) => potion.id == potionId,
      orElse: () => DummyData.potions.first,
    );
  }
}

class BattleDomain {
  const BattleDomain();

  SessionMutationResult runAutoBattle({
    required SessionState state,
    required String stageId,
    required BattleService battleService,
  }) {
    final BattleResult result = battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: const <HeroProfile>[
          HeroProfile(id: 'h1', name: 'Alchemist', power: 120),
          HeroProfile(id: 'h2', name: 'Hunter', power: 110),
        ],
        potionLoadout: const <String, int>{'p_1': 2, 'p_2': 1},
        stageId: stageId,
      ),
      dropTable: DummyData.dropTable(stageId),
    );

    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
    };
    result.loot.forEach((String materialId, int quantity) {
      inventory[materialId] = (inventory[materialId] ?? 0) + quantity;
    });

    final Set<String> unlocks = <String>{...state.battle.progress.unlockFlags};
    if ((result.loot['m_27'] ?? 0) > 0) {
      unlocks.add('potion_special_1');
    }
    if ((result.loot['m_30'] ?? 0) > 0) {
      unlocks.add('potion_special_2');
      unlocks.add('stage_2');
    }

    final int nextGold =
        state.player.gold - result.failurePenalty + (result.success ? 35 : 0);
    final int essenceGain = result.success ? 6 : 2;

    return SessionMutationResult(
      state: state.copyWith(
        player: state.player.copyWith(
          gold: nextGold,
          essence: state.player.essence + essenceGain,
          materialInventory: inventory,
        ),
        battle: state.battle.copyWith(
          progress: ProgressState(
            unlockFlags: unlocks,
            automationTier: state.battle.progress.automationTier,
            sessionPhase: state.battle.progress.sessionPhase,
          ),
        ),
      ),
      logMessage: 'Battle ${result.success ? 'win' : 'fail'} on $stageId / essence+$essenceGain',
    );
  }
}
