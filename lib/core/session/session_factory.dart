import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

import 'state/battle_state.dart';
import 'state/player_state.dart';
import 'state/session_state.dart';
import 'state/town_state.dart';
import 'state/workshop_state.dart';

SessionState createInitialSessionState(DateTime now) {
  return SessionState(
    player: const PlayerState(
      gold: 1500,
      essence: 120,
      diamonds: 100,
      materialInventory: <String, int>{},
    ),
    town: TownState(
      generalShop: buildGeneralShopState(now),
      catalystShop: buildCatalystShopState(now),
    ),
    workshop: const WorkshopState(
      queue: <CraftQueueJob>[],
      extractedTraitInventory: <String, double>{},
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
