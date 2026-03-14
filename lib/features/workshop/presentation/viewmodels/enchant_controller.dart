import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_enchant_use_case.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopEnchantController {
  WorkshopEnchantController(
    this._session,
    this._enchantService, {
    WorkshopEnchantUseCase enchantUseCase = const WorkshopEnchantUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
  }) : _enchantUseCase = enchantUseCase,
       _potionCatalogRepository = potionCatalogRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService;

  final SessionController _session;
  final EquipmentEnchantService _enchantService;
  final WorkshopEnchantUseCase _enchantUseCase;
  final PotionCatalogRepository _potionCatalogRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;

  void enchantEquipment(String equipmentId, String potionStackKey) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _enchantUseCase.enchantEquipment(
      state: current,
      equipmentId: equipmentId,
      potionStackKey: potionStackKey,
      enchantService: _enchantService,
      potionCatalogRepository: _potionCatalogRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Cannot enchant $equipmentId with $potionStackKey'
          : 'Enchanted $equipmentId with $potionStackKey',
    );
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
      );
    });
