import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_enchant_use_case.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

enum WorkshopEnchantSubmitResult {
  success,
  queueFull,
  failed,
}

class WorkshopEnchantController {
  WorkshopEnchantController(
    this._session,
    this._enchantService, {
    WorkshopEnchantUseCase enchantUseCase = const WorkshopEnchantUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) : _enchantUseCase = enchantUseCase,
       _potionCatalogRepository = potionCatalogRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService;

  final SessionController _session;
  final EquipmentEnchantService _enchantService;
  final WorkshopEnchantUseCase _enchantUseCase;
  final PotionCatalogRepository _potionCatalogRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;

  WorkshopEnchantSubmitResult enchantEquipment(
    String equipmentId,
    String potionStackKey,
  ) {
    final SessionState current = _session.snapshot();
    final int queueCapacity = _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / 인챈트 $equipmentId');
      return WorkshopEnchantSubmitResult.queueFull;
    }
    final SessionState nextState = _enchantUseCase.enchantEquipment(
      state: current,
      equipmentId: equipmentId,
      potionStackKey: potionStackKey,
      now: _session.now(),
      queueCapacity: queueCapacity,
      enchantService: _enchantService,
      potionCatalogRepository: _potionCatalogRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      _session.appendLog('인챈트 등록 실패 / $equipmentId');
      return WorkshopEnchantSubmitResult.failed;
    }
    _session.applyState(nextState);
    _session.appendLog('인챈트 등록 / $equipmentId');
    return WorkshopEnchantSubmitResult.success;
  }
}

final Provider<WorkshopEnchantController> workshopEnchantControllerProvider =
    Provider<WorkshopEnchantController>((Ref ref) {
      return WorkshopEnchantController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(equipmentEnchantServiceProvider),
        potionCatalogRepository: ref.read(potionCatalogRepositoryProvider),
        workshopSkillTreeRepository: ref.read(
          workshopSkillTreeRepositoryProvider,
        ),
        workshopSkillTreeService: ref.read(workshopSkillTreeServiceProvider),
        workshopSupportService: ref.read(workshopSupportServiceProvider),
      );
    });
