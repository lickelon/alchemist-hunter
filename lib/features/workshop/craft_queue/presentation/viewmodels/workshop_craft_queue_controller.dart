import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/use_cases/workshop_queue_claim_use_case.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_discovery_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_craft_enqueue_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';

part 'workshop_craft_queue_claim_controller.dart';
part 'workshop_craft_queue_controller_support.dart';
part 'workshop_craft_queue_enqueue_controller.dart';
part 'workshop_craft_queue_experiment_controller.dart';

class WorkshopCraftQueueController
    with
        _WorkshopCraftQueueControllerSupport,
        _WorkshopCraftQueueEnqueueController,
        _WorkshopCraftQueueExperimentController,
        _WorkshopCraftQueueClaimController {
  WorkshopCraftQueueController(
    this._session,
    this._craftingService, {
    WorkshopBrewExperimentUseCase brewExperimentUseCase =
        const WorkshopBrewExperimentUseCase(),
    WorkshopCraftEnqueueUseCase craftEnqueueUseCase =
        const WorkshopCraftEnqueueUseCase(),
    WorkshopQueueClaimUseCase queueClaimUseCase =
        const WorkshopQueueClaimUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopCraftRecipeRepository craftRecipeRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
    required PotionDiscoveryService discoveryService,
  }) : _brewExperimentUseCase = brewExperimentUseCase,
       _craftEnqueueUseCase = craftEnqueueUseCase,
       _queueClaimUseCase = queueClaimUseCase,
       _potionCatalogRepository = potionCatalogRepository,
       _craftRecipeRepository = craftRecipeRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService,
       _discoveryService = discoveryService;

  @override
  final SessionController _session;
  @override
  final PotionCraftingService _craftingService;
  @override
  final WorkshopBrewExperimentUseCase _brewExperimentUseCase;
  @override
  final WorkshopCraftEnqueueUseCase _craftEnqueueUseCase;
  @override
  final WorkshopQueueClaimUseCase _queueClaimUseCase;
  @override
  final PotionCatalogRepository _potionCatalogRepository;
  @override
  final WorkshopCraftRecipeRepository _craftRecipeRepository;
  @override
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  @override
  final WorkshopSkillTreeService _workshopSkillTreeService;
  @override
  final WorkshopSupportService _workshopSupportService;
  @override
  final PotionDiscoveryService _discoveryService;
}
