import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/craft_equipment_use_case.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentCraftController {
  EquipmentCraftController(
    this._session, {
    CraftEquipmentUseCase craftEquipmentUseCase = const CraftEquipmentUseCase(),
    required EquipmentBlueprintRepository equipmentBlueprintRepository,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
  }) : _craftEquipmentUseCase = craftEquipmentUseCase,
       _equipmentBlueprintRepository = equipmentBlueprintRepository,
       _townSkillTreeRepository = townSkillTreeRepository,
       _townSkillTreeService = townSkillTreeService;

  final SessionController _session;
  final CraftEquipmentUseCase _craftEquipmentUseCase;
  final EquipmentBlueprintRepository _equipmentBlueprintRepository;
  final TownSkillTreeRepository _townSkillTreeRepository;
  final TownSkillTreeService _townSkillTreeService;

  void craftEquipment(String blueprintId) {
    final SessionState current = _session.snapshot();
    final blueprint = _equipmentBlueprintRepository.findById(blueprintId);
    if (blueprint == null) {
      _session.appendLog('Equipment blueprint missing: $blueprintId');
      return;
    }

    final SessionState nextState = _craftEquipmentUseCase.craftEquipment(
      state: current,
      blueprint: blueprint,
      now: _session.now(),
      townSkillTreeRepository: _townSkillTreeRepository,
      townSkillTreeService: _townSkillTreeService,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Missing materials for ${blueprint.name}'
          : 'Crafted ${blueprint.name}',
    );
  }
}

final Provider<EquipmentCraftController> equipmentCraftControllerProvider =
    Provider<EquipmentCraftController>((Ref ref) {
      return EquipmentCraftController(
        ref.read(sessionControllerProvider.notifier),
        equipmentBlueprintRepository: ref.read(
          equipmentBlueprintRepositoryProvider,
        ),
        townSkillTreeRepository: ref.read(townSkillTreeRepositoryProvider),
        townSkillTreeService: ref.read(townSkillTreeServiceProvider),
      );
    });
