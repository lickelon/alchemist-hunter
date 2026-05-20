import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/use_cases/upgrade_workshop_skill_node_use_case.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class WorkshopSkillTreeController {
  WorkshopSkillTreeController(
    this._session, {
    UpgradeWorkshopSkillNodeUseCase upgradeUseCase =
        const UpgradeWorkshopSkillNodeUseCase(),
    WorkshopSkillTreeService service = const WorkshopSkillTreeService(),
    required WorkshopSkillTreeRepository repository,
  }) : _upgradeUseCase = upgradeUseCase,
       _service = service,
       _repository = repository;

  final SessionController _session;
  final UpgradeWorkshopSkillNodeUseCase _upgradeUseCase;
  final WorkshopSkillTreeService _service;
  final WorkshopSkillTreeRepository _repository;

  void upgradeNode(String nodeId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _upgradeUseCase.upgradeNode(
      state: current,
      nodeId: nodeId,
      repository: _repository,
      service: _service,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? '작업실 스킬 강화 불가 / $nodeId'
          : '작업실 스킬 강화 / $nodeId',
    );
  }
}

final Provider<WorkshopSkillTreeController>
workshopSkillTreeControllerProvider = Provider<WorkshopSkillTreeController>((
  Ref ref,
) {
  return WorkshopSkillTreeController(
    ref.read(sessionControllerProvider.notifier),
    repository: ref.read(workshopSkillTreeRepositoryProvider),
  );
});
