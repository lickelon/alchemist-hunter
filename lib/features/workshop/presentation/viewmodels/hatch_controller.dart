import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_hatch_use_case.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

enum WorkshopHatchSubmitResult {
  success,
  queueFull,
  failed,
}

class WorkshopHatchController {
  WorkshopHatchController(
    this._session, {
    WorkshopHatchUseCase hatchUseCase = const WorkshopHatchUseCase(),
    required HomunculusHatchRepository hatchRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) : _hatchUseCase = hatchUseCase,
       _hatchRepository = hatchRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService;

  final SessionController _session;
  final WorkshopHatchUseCase _hatchUseCase;
  final HomunculusHatchRepository _hatchRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;

  WorkshopHatchSubmitResult hatch(String recipeId) {
    final SessionState current = _session.snapshot();
    final recipe = _hatchRepository.findById(recipeId);
    if (recipe == null) {
      _session.appendLog('Hatch recipe missing: $recipeId');
      return WorkshopHatchSubmitResult.failed;
    }

    final int queueCapacity = _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / 부화 ${recipe.resultName}');
      return WorkshopHatchSubmitResult.queueFull;
    }
    final SessionState nextState = _hatchUseCase.hatchHomunculus(
      state: current,
      recipe: recipe,
      now: _session.now(),
      queueCapacity: queueCapacity,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      _session.appendLog('부화 등록 실패 / ${recipe.resultName}');
      return WorkshopHatchSubmitResult.failed;
    }
    _session.applyState(nextState);
    _session.appendLog('부화 등록 / ${recipe.resultName}');
    return WorkshopHatchSubmitResult.success;
  }
}

final Provider<WorkshopHatchController> workshopHatchControllerProvider =
    Provider<WorkshopHatchController>((Ref ref) {
      return WorkshopHatchController(
        ref.read(sessionControllerProvider.notifier),
        hatchRepository: ref.read(homunculusHatchRepositoryProvider),
        workshopSkillTreeRepository: ref.read(
          workshopSkillTreeRepositoryProvider,
        ),
        workshopSkillTreeService: ref.read(workshopSkillTreeServiceProvider),
        workshopSupportService: ref.read(workshopSupportServiceProvider),
      );
    });
