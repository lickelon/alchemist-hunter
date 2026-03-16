import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/characters/domain/models/characters_state.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

import 'player_state.dart';
import 'session_state.dart';

SessionState createInitialSessionState(DateTime now) {
  return SessionState(
    lastSyncAt: now,
    player: const PlayerState(
      gold: 1500,
      essence: 120,
      townInsight: 2,
      arcaneDust: 2,
      diamonds: 100,
      timeAcceleration: 1,
      materialInventory: <String, int>{},
    ),
    town: TownState(
      generalShop: buildGeneralShopState(now),
      catalystShop: buildCatalystShopState(now),
      equipmentInventory: const <EquipmentInstance>[],
      forgeQueue: const <TownForgeJob>[],
      mercenaryCandidates: const MercenaryRecruitmentService().buildCandidates(
        refreshIndex: 0,
        templateRepository: const StaticMercenaryTemplateRepository(),
      ),
      mercenaryRefreshCount: 0,
      skillTree: TownSkillTreeState(
        unlockedNodes: <String>{
          const StaticTownSkillTreeRepository().nodes().first.id,
        },
        nodeLevels: const <String, int>{},
        availablePoints: 0,
        spentPoints: 0,
      ),
      potionSalesTotal: 0,
      equipmentCraftCount: 0,
    ),
    workshop: const WorkshopState(
      queue: <CraftQueueJob>[],
      pendingClaim: WorkshopPendingClaim(),
      supportAssignmentsByFunction: <String, String>{},
      extractedTraitInventory: <String, double>{},
      craftedPotionStacks: <String, int>{},
      craftedPotionDetails: <String, CraftedPotion>{},
      logs: <String>['Game initialized'],
      skillTree: WorkshopSkillTreeState(
        unlockedNodes: <String>{
          'workshop_alembic',
        },
        nodeLevels: <String, int>{},
        availablePoints: 0,
        spentPoints: 0,
      ),
      extractionCount: 0,
      potionCraftCount: 0,
      enchantCount: 0,
    ),
    battle: const BattleState(
      progress: ProgressState(
        unlockFlags: <String>{'stage_1'},
        automationTier: 1,
        sessionPhase: SessionPhase.early,
      ),
      stageAssignments: <String, List<String>>{
        'stage_1': <String>['merc_1', 'homo_1'],
      },
      stageExpeditions: <String, BattleExpeditionState>{},
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
          homunculusOrigin: 'Base Seed Vessel',
          homunculusRole: '지원',
          homunculusSupportEffect: '기초 연성 보조',
        ),
      ],
    ),
  );
}
