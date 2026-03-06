import 'dart:math';

import 'package:alchemist_hunter/features/game/data/dummy_data.dart';
import 'package:alchemist_hunter/features/game/domain/models.dart';
import 'package:alchemist_hunter/features/game/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/game/services/battle_service.dart';
import 'package:alchemist_hunter/features/game/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/game/services/economy_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  const GameState({
    required this.gold,
    required this.diamonds,
    required this.inventory,
    required this.generalShop,
    required this.catalystShop,
    required this.queue,
    required this.logs,
    required this.progress,
  });

  final int gold;
  final int diamonds;
  final Map<String, int> inventory;
  final ShopState generalShop;
  final ShopState catalystShop;
  final List<CraftQueueJob> queue;
  final List<String> logs;
  final ProgressState progress;

  GameState copyWith({
    int? gold,
    int? diamonds,
    Map<String, int>? inventory,
    ShopState? generalShop,
    ShopState? catalystShop,
    List<CraftQueueJob>? queue,
    List<String>? logs,
    ProgressState? progress,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      diamonds: diamonds ?? this.diamonds,
      inventory: inventory ?? this.inventory,
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

class GameController extends StateNotifier<GameState> {
  GameController(
    this._economy,
    this._queue,
    this._battle,
  ) : super(
         GameState(
           gold: 1500,
           diamonds: 100,
           inventory: <String, int>{},
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

  void buyGeneralMaterial(String materialId, int qty) {
    final ({int remainingGold, List<ShopItem> purchased}) result = _economy.buyMaterial(
      currentGold: state.gold,
      items: state.generalShop.items,
      itemId: materialId,
      quantity: qty,
    );

    final Map<String, int> inventory = <String, int>{...state.inventory};
    inventory[materialId] = (inventory[materialId] ?? 0) + qty;

    state = state.copyWith(
      gold: result.remainingGold,
      inventory: inventory,
      generalShop: state.generalShop.copyWith(items: result.purchased),
      logs: <String>['Bought $qty of $materialId', ...state.logs].take(20).toList(),
    );
  }

  void forceRefresh(ShopType type) {
    final DateTime now = DateTime.now();
    final bool isGeneral = type == ShopType.general;
    final ShopState target = isGeneral ? state.generalShop : state.catalystShop;
    final List<ShopItem> nextItems = (isGeneral
            ? DummyData.generalShopState(now).items
            : DummyData.catalystShopState(now).items)
        .map(
          (ShopItem i) => ShopItem(
            materialId: i.materialId,
            name: i.name,
            price: i.price,
            quantity: i.quantity,
          ),
        )
        .toList();

    final ({ShopState shop, int costPaid}) refreshed = _economy.forceRefresh(
      shop: target,
      now: now,
      nextItems: nextItems,
    );

    if (state.gold < refreshed.costPaid) {
      state = state.copyWith(
        logs: <String>['Not enough gold for refresh', ...state.logs].take(20).toList(),
      );
      return;
    }

    state = state.copyWith(
      gold: state.gold - refreshed.costPaid,
      generalShop: isGeneral ? refreshed.shop : state.generalShop,
      catalystShop: isGeneral ? state.catalystShop : refreshed.shop,
      logs: <String>['Forced refresh ${type.name} shop', ...state.logs].take(20).toList(),
    );
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
      logs: <String>['Enqueued $potionId x$repeatCount', ...state.logs].take(20).toList(),
    );
  }

  void tickCraftQueue() {
    final List<CraftQueueJob> nextQueue = _queue.processTick(
      state.queue,
      const Duration(seconds: 15),
    );
    int completed = 0;
    for (final CraftQueueJob job in nextQueue) {
      if (job.status == QueueJobStatus.completed &&
          !state.queue.any((CraftQueueJob old) => old.id == job.id && old.status == QueueJobStatus.completed)) {
        completed += 1;
      }
    }
    state = state.copyWith(
      queue: nextQueue,
      gold: state.gold + (completed * 120),
      logs: <String>['Processed queue tick', ...state.logs].take(20).toList(),
    );
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

    final Map<String, int> inventory = <String, int>{...state.inventory};
    result.loot.forEach((String key, int value) {
      inventory[key] = (inventory[key] ?? 0) + value;
    });

    final int nextGold = state.gold - result.failurePenalty + (result.success ? 35 : 0);
    state = state.copyWith(
      gold: nextGold,
      inventory: inventory,
      logs: <String>[
        'Battle ${result.success ? 'win' : 'fail'} on $stageId / loot:${result.loot.length}',
        ...state.logs,
      ].take(20).toList(),
    );
  }
}

final StateNotifierProvider<GameController, GameState> gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((Ref ref) {
      return GameController(
        ref.read(economyServiceProvider),
        ref.read(craftQueueServiceProvider),
        ref.read(battleServiceProvider),
      );
    });

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) => DummyData.materials);

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) => DummyData.potions);

final Provider<List<String>> stageListProvider =
    Provider<List<String>>((Ref ref) => DummyData.stages);
