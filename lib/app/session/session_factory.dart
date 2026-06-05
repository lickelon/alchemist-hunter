import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_id_factory.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

import 'player_state.dart';
import 'session_state.dart';

class InitialSessionCatalogs {
  const InitialSessionCatalogs({
    required this.shopCatalogRepository,
    required this.mercenaryTemplateRepository,
    required this.townSkillTreeRepository,
  });

  final ShopCatalogRepository shopCatalogRepository;
  final MercenaryTemplateRepository mercenaryTemplateRepository;
  final TownSkillTreeRepository townSkillTreeRepository;
}

SessionState createInitialSessionStateFromCatalogs(
  DateTime now,
  InitialSessionCatalogs catalogs,
) {
  final String starterMercenaryId = createOpaqueCharacterId(now: now, seed: 0);
  final String starterHomunculusId = createOpaqueCharacterId(
    now: now,
    seed: 1,
    reservedIds: <String>{starterMercenaryId},
  );

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
      generalShop: catalogs.shopCatalogRepository.createGeneralShopState(now),
      catalystShop: catalogs.shopCatalogRepository.createCatalystShopState(now),
      equipmentInventory: const <EquipmentInstance>[],
      forgeQueue: const <TownForgeJob>[],
      mercenaryCandidates: const MercenaryRecruitmentService().buildCandidates(
        refreshIndex: 0,
        templateRepository: catalogs.mercenaryTemplateRepository,
      ),
      mercenaryRefreshCount: 0,
      skillTree: TownSkillTreeState(
        unlockedNodes: <String>{
          catalogs.townSkillTreeRepository.nodes().first.id,
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
        unlockedNodes: <String>{'workshop_alembic'},
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
        unlockFlags: <String>{},
        clearedStageIds: <String>{},
        automationTier: 1,
        sessionPhase: SessionPhase.early,
      ),
      stageAssignments: <String, List<String>>{},
      stagePotionLoadouts: <String, Map<String, int>>{},
      stageExpeditions: <String, BattleExpeditionState>{},
    ),
    characters: CharactersState(
      mercenaries: <CharacterProgress>[
        CharacterProgress(
          id: starterMercenaryId,
          name: '전사',
          type: CharacterType.mercenary,
          combatJobId: CombatJobIds.mercenaryWarrior,
          level: 1,
          rank: 1,
          xp: 0,
          mercenaryTier: MercenaryTier.rookie,
        ),
      ],
      homunculi: <CharacterProgress>[
        CharacterProgress(
          id: starterHomunculusId,
          name: '마법사',
          type: CharacterType.homunculus,
          combatJobId: CombatJobIds.homunculusMage,
          level: 1,
          rank: 1,
          xp: 0,
          homunculusTier: HomunculusTier.nigredo,
        ),
      ],
    ),
  );
}
