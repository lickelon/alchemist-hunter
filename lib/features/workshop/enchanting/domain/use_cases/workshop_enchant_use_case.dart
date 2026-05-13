import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/crafted_potion_stack_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_target_service.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/workshop_enchant_job_factory.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';

class WorkshopEnchantUseCase {
  const WorkshopEnchantUseCase({
    EquipmentEnchantTargetService targetService =
        const EquipmentEnchantTargetService(),
    CraftedPotionStackService potionStackService =
        const CraftedPotionStackService(),
    WorkshopEnchantJobFactory jobFactory = const WorkshopEnchantJobFactory(),
  }) : _targetService = targetService,
       _potionStackService = potionStackService,
       _jobFactory = jobFactory;

  final EquipmentEnchantTargetService _targetService;
  final CraftedPotionStackService _potionStackService;
  final WorkshopEnchantJobFactory _jobFactory;

  SessionState enchantEquipment({
    required SessionState state,
    required String equipmentId,
    required String potionStackKey,
    DateTime? now,
    int queueCapacity = 99,
    required EquipmentEnchantService enchantService,
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) {
    if (state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final CraftedPotion? potion = _potionStackService.potionForStack(
      state.workshop,
      potionStackKey,
    );
    if (potion == null) {
      return state;
    }

    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potion.typePotionId,
    );
    if (blueprint == null) {
      return state;
    }

    final EquipmentEnchantTarget? target = _targetService.findTarget(
      town: state.town,
      characters: state.characters,
      equipmentId: equipmentId,
    );
    if (target == null) {
      return state;
    }

    final double potencyBonusRate =
        workshopSkillTreeService.enchantPotencyBonusRate(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.enchantPotencyBonusRate(state);
    final EquipmentEnchant enchant = enchantService.buildEnchant(
      equipment: target.item,
      potion: potion,
      blueprint: blueprint,
      potencyBonusRate: potencyBonusRate,
    );
    final EquipmentInstance completedEquipment = target.item.copyWith(
      enchant: enchant,
    );

    final EquipmentEnchantReservation reservation = _targetService.reserve(
      town: state.town,
      characters: state.characters,
      target: target,
    );
    final WorkshopState reservedWorkshop = _potionStackService.consumeOne(
      state.workshop,
      potionStackKey,
    );
    final bool hasActiveJob = reservedWorkshop.queue.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
    final DateTime queuedAt = now ?? DateTime.now();
    final CraftQueueJob job = _jobFactory.createJob(
      queuedAt: queuedAt,
      equipmentId: equipmentId,
      potionStackKey: potionStackKey,
      potion: potion,
      target: target,
      completedEquipment: completedEquipment,
      hasActiveJob: hasActiveJob,
    );

    return state.copyWith(
      town: reservation.town,
      characters: reservation.characters,
      workshop: reservedWorkshop.copyWith(
        queue: <CraftQueueJob>[...reservedWorkshop.queue, job],
      ),
    );
  }
}
