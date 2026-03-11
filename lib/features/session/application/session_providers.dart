import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class PlayerState {
  const PlayerState({
    required this.gold,
    required this.essence,
    required this.diamonds,
    required this.materialInventory,
  });

  final int gold;
  final int essence;
  final int diamonds;
  final Map<String, int> materialInventory;

  PlayerState copyWith({
    int? gold,
    int? essence,
    int? diamonds,
    Map<String, int>? materialInventory,
  }) {
    return PlayerState(
      gold: gold ?? this.gold,
      essence: essence ?? this.essence,
      diamonds: diamonds ?? this.diamonds,
      materialInventory: materialInventory ?? this.materialInventory,
    );
  }
}

class TownState {
  const TownState({required this.generalShop, required this.catalystShop});

  final ShopState generalShop;
  final ShopState catalystShop;

  TownState copyWith({ShopState? generalShop, ShopState? catalystShop}) {
    return TownState(
      generalShop: generalShop ?? this.generalShop,
      catalystShop: catalystShop ?? this.catalystShop,
    );
  }
}

class WorkshopState {
  const WorkshopState({
    required this.queue,
    required this.craftedPotionStacks,
    required this.craftedPotionDetails,
    required this.logs,
  });

  final List<CraftQueueJob> queue;
  final Map<String, int> craftedPotionStacks;
  final Map<String, CraftedPotion> craftedPotionDetails;
  final List<String> logs;

  WorkshopState copyWith({
    List<CraftQueueJob>? queue,
    Map<String, int>? craftedPotionStacks,
    Map<String, CraftedPotion>? craftedPotionDetails,
    List<String>? logs,
  }) {
    return WorkshopState(
      queue: queue ?? this.queue,
      craftedPotionStacks: craftedPotionStacks ?? this.craftedPotionStacks,
      craftedPotionDetails: craftedPotionDetails ?? this.craftedPotionDetails,
      logs: logs ?? this.logs,
    );
  }
}

class BattleState {
  const BattleState({required this.progress});

  final ProgressState progress;

  BattleState copyWith({ProgressState? progress}) {
    return BattleState(progress: progress ?? this.progress);
  }
}

class SessionState {
  const SessionState({
    required this.player,
    required this.town,
    required this.workshop,
    required this.battle,
    required this.characters,
  });

  final PlayerState player;
  final TownState town;
  final WorkshopState workshop;
  final BattleState battle;
  final CharactersState characters;

  SessionState copyWith({
    PlayerState? player,
    TownState? town,
    WorkshopState? workshop,
    BattleState? battle,
    CharactersState? characters,
  }) {
    return SessionState(
      player: player ?? this.player,
      town: town ?? this.town,
      workshop: workshop ?? this.workshop,
      battle: battle ?? this.battle,
      characters: characters ?? this.characters,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  SessionController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(createInitialSessionState((clock ?? DateTime.now)()));

  final DateTime Function() _clock;

  DateTime now() => _clock();

  SessionState snapshot() => state;

  void applyState(SessionState nextState) => state = nextState;

  void appendLog(String message) {
    if (state.workshop.logs.isNotEmpty &&
        state.workshop.logs.first == message) {
      return;
    }
    state = state.copyWith(
      workshop: state.workshop.copyWith(
        logs: <String>[message, ...state.workshop.logs].take(20).toList(),
      ),
    );
  }
}

final StateNotifierProvider<SessionController, SessionState>
sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((Ref ref) {
      return SessionController();
    });

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) => DummyData.materials);

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) => DummyData.potions);

final Provider<List<String>> stageCatalogProvider = Provider<List<String>>(
  (Ref ref) => DummyData.stages,
);
