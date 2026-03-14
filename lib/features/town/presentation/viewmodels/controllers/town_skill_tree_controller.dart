import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/upgrade_town_skill_node_use_case.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';

class TownSkillTreeController {
  TownSkillTreeController(
    this._session, {
    UpgradeTownSkillNodeUseCase upgradeUseCase =
        const UpgradeTownSkillNodeUseCase(),
    TownSkillTreeService service = const TownSkillTreeService(),
    required TownSkillTreeRepository repository,
  }) : _upgradeUseCase = upgradeUseCase,
       _service = service,
       _repository = repository;

  final SessionController _session;
  final UpgradeTownSkillNodeUseCase _upgradeUseCase;
  final TownSkillTreeService _service;
  final TownSkillTreeRepository _repository;

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
          ? 'Cannot upgrade town skill $nodeId'
          : 'Upgraded town skill $nodeId',
    );
  }
}

final Provider<TownSkillTreeController> townSkillTreeControllerProvider =
    Provider<TownSkillTreeController>((Ref ref) {
      return TownSkillTreeController(
        ref.read(sessionControllerProvider.notifier),
        repository: ref.read(townSkillTreeRepositoryProvider),
      );
    });
