import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/models/hatch_models.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/use_cases/workshop_hatch_use_case.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_service_providers.dart';

enum WorkshopHatchSubmitResult {
  success,
  queueFull,
  essenceMissing,
  arcaneMissing,
  materialMissing,
  elementMissing,
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
    required BattleCatalogRepository battleCatalogRepository,
  }) : _hatchUseCase = hatchUseCase,
       _hatchRepository = hatchRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService,
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final WorkshopHatchUseCase _hatchUseCase;
  final HomunculusHatchRepository _hatchRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;
  final BattleCatalogRepository _battleCatalogRepository;

  WorkshopHatchSubmitResult hatch(String recipeId) {
    final SessionState current = _session.snapshot();
    final recipe = _hatchRepository.findById(recipeId);
    if (recipe == null) {
      _session.appendLog('부화 레시피 없음: $recipeId');
      return WorkshopHatchSubmitResult.failed;
    }
    final String recipeDisplayName = homunculusHatchDisplayName(
      recipe,
      _battleCatalogRepository,
    );

    final int queueCapacity =
        _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / 부화 $recipeDisplayName');
      return WorkshopHatchSubmitResult.queueFull;
    }
    final SessionState nextState = _hatchUseCase.hatchHomunculus(
      state: current,
      recipe: recipe,
      now: _session.now(),
      queueCapacity: queueCapacity,
      workshopSupportService: _workshopSupportService,
      battleCatalogRepository: _battleCatalogRepository,
    );
    if (identical(nextState, current)) {
      final WorkshopHatchSubmitResult failure = _hatchFailureReason(
        current,
        recipe,
        _workshopSupportService,
      );
      _session.appendLog(
        '${_hatchFailureLogLabel(failure)} / $recipeDisplayName',
      );
      return failure;
    }
    _session.applyState(nextState);
    _session.appendLog('부화 등록 / $recipeDisplayName');
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
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });

WorkshopHatchSubmitResult _hatchFailureReason(
  SessionState state,
  HomunculusHatchRecipe recipe,
  WorkshopSupportService workshopSupportService,
) {
  final int arcaneDustCost =
      (recipe.arcaneDustCost -
              workshopSupportService.hatchArcaneDustDiscount(state))
          .clamp(0, recipe.arcaneDustCost)
          .toInt();
  if (state.player.essence < recipe.essenceCost) {
    return WorkshopHatchSubmitResult.essenceMissing;
  }
  if (state.player.arcaneDust < arcaneDustCost) {
    return WorkshopHatchSubmitResult.arcaneMissing;
  }
  for (final MapEntry<String, int> entry in recipe.materialCosts.entries) {
    if ((state.player.materialInventory[entry.key] ?? 0) < entry.value) {
      return WorkshopHatchSubmitResult.materialMissing;
    }
  }
  for (final MapEntry<String, double> entry in recipe.traitCosts.entries) {
    if ((state.workshop.extractedTraitInventory[entry.key] ?? 0) <
        entry.value) {
      return WorkshopHatchSubmitResult.elementMissing;
    }
  }
  return WorkshopHatchSubmitResult.failed;
}

String _hatchFailureLogLabel(WorkshopHatchSubmitResult result) {
  return switch (result) {
    WorkshopHatchSubmitResult.essenceMissing => '정수 부족',
    WorkshopHatchSubmitResult.arcaneMissing => '신비 부족',
    WorkshopHatchSubmitResult.materialMissing => '재료 부족',
    WorkshopHatchSubmitResult.elementMissing => '원소 부족',
    WorkshopHatchSubmitResult.queueFull => '작업실 큐 가득 참',
    WorkshopHatchSubmitResult.success => '부화 등록',
    WorkshopHatchSubmitResult.failed => '부화 등록 실패',
  };
}
