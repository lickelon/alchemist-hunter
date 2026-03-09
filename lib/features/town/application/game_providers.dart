import 'dart:math';

import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/application/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/battle/application/services/battle_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  const GameState({
    required this.gold,
    required this.essence,
    required this.diamonds,
    required this.materialInventory,
    required this.craftedPotionStacks,
    required this.craftedPotionDetails,
    required this.generalShop,
    required this.catalystShop,
    required this.queue,
    required this.logs,
    required this.progress,
  });

  final int gold;
  final int essence;
  final int diamonds;
  final Map<String, int> materialInventory;
  final Map<String, int> craftedPotionStacks;
  final Map<String, CraftedPotion> craftedPotionDetails;
  final ShopState generalShop;
  final ShopState catalystShop;
  final List<CraftQueueJob> queue;
  final List<String> logs;
  final ProgressState progress;

  GameState copyWith({
    int? gold,
    int? essence,
    int? diamonds,
    Map<String, int>? materialInventory,
    Map<String, int>? craftedPotionStacks,
    Map<String, CraftedPotion>? craftedPotionDetails,
    ShopState? generalShop,
    ShopState? catalystShop,
    List<CraftQueueJob>? queue,
    List<String>? logs,
    ProgressState? progress,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      essence: essence ?? this.essence,
      diamonds: diamonds ?? this.diamonds,
      materialInventory: materialInventory ?? this.materialInventory,
      craftedPotionStacks: craftedPotionStacks ?? this.craftedPotionStacks,
      craftedPotionDetails: craftedPotionDetails ?? this.craftedPotionDetails,
      generalShop: generalShop ?? this.generalShop,
      catalystShop: catalystShop ?? this.catalystShop,
      queue: queue ?? this.queue,
      logs: logs ?? this.logs,
      progress: progress ?? this.progress,
    );
  }
}

final Provider<AlchemyService> alchemyServiceProvider =
    Provider<AlchemyService>((Ref ref) => AlchemyService());

final Provider<EconomyService> economyServiceProvider =
    Provider<EconomyService>((Ref ref) => EconomyService());

final Provider<CraftQueueService> craftQueueServiceProvider =
    Provider<CraftQueueService>((Ref ref) => CraftQueueService(random: Random(7)));

final Provider<BattleService> battleServiceProvider =
    Provider<BattleService>((Ref ref) => BattleService(random: Random(11)));

final Provider<PotionCraftingService> potionCraftingServiceProvider =
    Provider<PotionCraftingService>((Ref ref) => PotionCraftingService(random: Random(13)));

class GameController extends StateNotifier<GameState> {
  GameController(
    this._economy,
    this._queue,
    this._battle,
    this._potionCrafting,
  ) : super(
         GameState(
           gold: 1500,
           essence: 120,
           diamonds: 100,
           materialInventory: <String, int>{},
           craftedPotionStacks: <String, int>{},
           craftedPotionDetails: <String, CraftedPotion>{},
           generalShop: DummyData.generalShopState(DateTime.now()),
           catalystShop: DummyData.catalystShopState(DateTime.now()),
           queue: const <CraftQueueJob>[],
           logs: const <String>['Game initialized'],
           progress: const ProgressState(
             unlockFlags: <String>{'stage_1'},
             automationTier: 1,
             sessionPhase: SessionPhase.early,
           ),
         ),
       );

  final EconomyService _economy;
  final CraftQueueService _queue;
  final BattleService _battle;
  final PotionCraftingService _potionCrafting;

  void buyGeneralMaterial(String materialId, int qty) {
    _syncShopsByNow(DateTime.now());
    _buyMaterial(ShopType.general, materialId, qty);
  }

  void buyCatalystMaterial(String materialId, int qty) {
    _syncShopsByNow(DateTime.now());
    _buyMaterial(ShopType.catalyst, materialId, qty);
  }

  void _buyMaterial(ShopType shopType, String materialId, int qty) {
    final bool isGeneral = shopType == ShopType.general;
    final ShopState target = isGeneral ? state.generalShop : state.catalystShop;
    try {
      final ({int remainingGold, List<ShopItem> purchased}) result = _economy.buyMaterial(
        currentGold: state.gold,
        items: target.items,
        itemId: materialId,
        quantity: qty,
      );

      final Map<String, int> inventory = <String, int>{...state.materialInventory};
      inventory[materialId] = (inventory[materialId] ?? 0) + qty;

      state = state.copyWith(
        gold: result.remainingGold,
        materialInventory: inventory,
        generalShop: isGeneral ? target.copyWith(items: result.purchased) : state.generalShop,
        catalystShop: isGeneral ? state.catalystShop : target.copyWith(items: result.purchased),
      );
      _appendLog('Bought $qty of $materialId (${shopType.name})');
    } catch (_) {
      _appendLog('Purchase failed for $materialId');
    }
  }

  void forceRefresh(ShopType type) {
    _syncShopsByNow(DateTime.now());
    final DateTime now = DateTime.now();
    final bool isGeneral = type == ShopType.general;
    final ShopState target = isGeneral ? state.generalShop : state.catalystShop;
    final List<ShopItem> nextItems =
        isGeneral ? DummyData.buildGeneralShopItems() : DummyData.buildCatalystShopItems();

    final ({ShopState shop, int costPaid}) refreshed = _economy.forceRefresh(
      shop: target,
      now: now,
      nextItems: nextItems,
    );

    if (state.gold < refreshed.costPaid) {
      _appendLog('Not enough gold for refresh');
      return;
    }

    state = state.copyWith(
      gold: state.gold - refreshed.costPaid,
      generalShop: isGeneral ? refreshed.shop : state.generalShop,
      catalystShop: isGeneral ? state.catalystShop : refreshed.shop,
    );
    _appendLog('Forced refresh ${type.name} shop');
  }

  void syncShopAutoRefresh() {
    _syncShopsByNow(DateTime.now());
  }

  void enqueuePotion(String potionId, int repeatCount) {
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: const CraftRetryPolicy(maxRetries: 2),
      status: QueueJobStatus.queued,
      eta: const Duration(seconds: 15),
    );
    state = state.copyWith(
      queue: _queue.enqueue(state.queue, job),
    );
    _appendLog('Enqueued $potionId x$repeatCount');
  }

  void tickCraftQueue() {
    final List<CraftQueueJob> prevQueue = state.queue;
    final List<CraftQueueJob> nextQueue = _queue.processTick(
      state.queue,
      const Duration(seconds: 15),
    );

    final Map<String, int> stacks = <String, int>{...state.craftedPotionStacks};
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{...state.craftedPotionDetails};

    int producedCount = 0;
    for (final CraftQueueJob job in nextQueue) {
      final CraftQueueJob? prevJob = prevQueue.where((CraftQueueJob j) => j.id == job.id).firstOrNull;
      if (job.status != QueueJobStatus.completed || prevJob == null) {
        continue;
      }
      if (prevJob.status == QueueJobStatus.completed) {
        continue;
      }

      final PotionBlueprint blueprint = DummyData.potions.firstWhere(
        (PotionBlueprint p) => p.id == job.potionId,
        orElse: () => DummyData.potions.first,
      );

      for (int i = 0; i < job.currentRepeat; i++) {
        final Map<String, double> inputTraits = _potionCrafting.generateCraftInputTraits(blueprint);
        final CraftedPotion crafted = _potionCrafting.craftPotion(
          requestedBlueprint: blueprint,
          extractedTraits: inputTraits,
          recipeRules: DummyData.potionRecipeRules,
          branchRules: DummyData.potionRecipeBranchRules,
          qualityRule: DummyData.potionQualityRule,
        );
        final String stackKey = '${crafted.typePotionId}|${crafted.qualityGrade.name}';
        stacks[stackKey] = (stacks[stackKey] ?? 0) + 1;
        details.putIfAbsent(stackKey, () => crafted);
        producedCount += 1;
      }
    }

    state = state.copyWith(
      queue: nextQueue,
      craftedPotionStacks: stacks,
      craftedPotionDetails: details,
    );
    _appendLog('Processed queue tick / produced $producedCount');
  }

  void sellCraftedPotion(String stackKey, int qty) {
    final int owned = state.craftedPotionStacks[stackKey] ?? 0;
    if (qty < 1 || owned < qty) {
      _appendLog('Not enough crafted potion to sell');
      return;
    }

    final CraftedPotion? sample = state.craftedPotionDetails[stackKey];
    if (sample == null) {
      _appendLog('Potion detail not found');
      return;
    }

    final PotionBlueprint blueprint = DummyData.potions.firstWhere(
      (PotionBlueprint p) => p.id == sample.typePotionId,
      orElse: () => DummyData.potions.first,
    );

    final double multiplier = switch (sample.qualityGrade) {
      PotionQualityGrade.s => 1.6,
      PotionQualityGrade.a => 1.3,
      PotionQualityGrade.b => 1.0,
      PotionQualityGrade.c => 0.8,
    };

    final int earned = (blueprint.baseValue * multiplier * qty).round();
    final Map<String, int> stacks = <String, int>{...state.craftedPotionStacks};
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{...state.craftedPotionDetails};

    final int nextQty = owned - qty;
    if (nextQty <= 0) {
      stacks.remove(stackKey);
      details.remove(stackKey);
    } else {
      stacks[stackKey] = nextQty;
    }

    state = state.copyWith(
      gold: state.gold + earned,
      craftedPotionStacks: stacks,
      craftedPotionDetails: details,
    );
    _appendLog('Sold potion $stackKey x$qty for $earned gold');
  }

  void runAutoBattle(String stageId) {
    final BattleResult result = _battle.runAutoBattle(
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

    final Map<String, int> inventory = <String, int>{...state.materialInventory};
    result.loot.forEach((String key, int value) {
      inventory[key] = (inventory[key] ?? 0) + value;
    });

    final Set<String> unlocks = <String>{...state.progress.unlockFlags};
    if ((result.loot['m_27'] ?? 0) > 0) {
      unlocks.add('potion_special_1');
    }
    if ((result.loot['m_30'] ?? 0) > 0) {
      unlocks.add('potion_special_2');
      unlocks.add('stage_2');
    }

    final int nextGold = state.gold - result.failurePenalty + (result.success ? 35 : 0);
    final int essenceGain = result.success ? 6 : 2;

    state = state.copyWith(
      gold: nextGold,
      essence: state.essence + essenceGain,
      materialInventory: inventory,
      progress: ProgressState(
        unlockFlags: unlocks,
        automationTier: state.progress.automationTier,
        sessionPhase: state.progress.sessionPhase,
      ),
    );
    _appendLog('Battle ${result.success ? 'win' : 'fail'} on $stageId / essence+$essenceGain');
  }

  void _appendLog(String message) {
    state = state.copyWith(
      logs: <String>[message, ...state.logs].take(20).toList(),
    );
  }

  void _syncShopsByNow(DateTime now) {
    final ({ShopState shop, bool refreshed}) generalResult = _economy.applyAutoRefresh(
      shop: state.generalShop,
      now: now,
      nextItems: DummyData.buildGeneralShopItems(),
      refreshInterval: const Duration(minutes: 15),
    );
    final ({ShopState shop, bool refreshed}) catalystResult = _economy.applyAutoRefresh(
      shop: state.catalystShop,
      now: now,
      nextItems: DummyData.buildCatalystShopItems(),
      refreshInterval: const Duration(minutes: 30),
    );

    if (!generalResult.refreshed && !catalystResult.refreshed) {
      return;
    }

    state = state.copyWith(
      generalShop: generalResult.shop,
      catalystShop: catalystResult.shop,
    );
    _appendLog('Auto refresh executed');
  }
}

final StateNotifierProvider<GameController, GameState> gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((Ref ref) {
      return GameController(
        ref.read(economyServiceProvider),
        ref.read(craftQueueServiceProvider),
        ref.read(battleServiceProvider),
        ref.read(potionCraftingServiceProvider),
      );
    });

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) => DummyData.materials);

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) => DummyData.potions);

final Provider<List<String>> stageListProvider =
    Provider<List<String>>((Ref ref) => DummyData.stages);
