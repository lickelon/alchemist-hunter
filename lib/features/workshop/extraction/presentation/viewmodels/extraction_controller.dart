import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/use_cases/workshop_extraction_use_case.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_service_providers.dart';

enum WorkshopExtractionSubmitResult { success, queueFull, failed }

class WorkshopExtractionController {
  WorkshopExtractionController(
    this._session,
    this._alchemyService, {
    WorkshopExtractionUseCase extractionDomain =
        const WorkshopExtractionUseCase(),
    required MaterialCatalogRepository materialCatalogRepository,
    required ExtractionProfileRepository extractionProfileRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) : _extractionDomain = extractionDomain,
       _materialCatalogRepository = materialCatalogRepository,
       _extractionProfileRepository = extractionProfileRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService;

  final SessionController _session;
  final AlchemyService _alchemyService;
  final WorkshopExtractionUseCase _extractionDomain;
  final MaterialCatalogRepository _materialCatalogRepository;
  final ExtractionProfileRepository _extractionProfileRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;

  WorkshopExtractionSubmitResult extractMaterial(
    String materialId,
    String profileId, {
    int quantity = 1,
    List<String>? selectedTraits,
  }) {
    final SessionState current = _session.snapshot();
    final int queueCapacity =
        _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / 추출 $materialId x$quantity');
      return WorkshopExtractionSubmitResult.queueFull;
    }
    final SessionState nextState = _extractionDomain.extractMaterial(
      state: current,
      materialId: materialId,
      profileId: profileId,
      now: _session.now(),
      queueCapacity: queueCapacity,
      alchemyService: _alchemyService,
      materialCatalogRepository: _materialCatalogRepository,
      extractionProfileRepository: _extractionProfileRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
      quantity: quantity,
      selectedTraits: selectedTraits,
    );
    if (identical(nextState, current)) {
      _session.appendLog('추출 등록 실패 / $materialId x$quantity');
      return WorkshopExtractionSubmitResult.failed;
    }
    _session.applyState(nextState);
    _session.appendLog('추출 등록 / $materialId x$quantity');
    return WorkshopExtractionSubmitResult.success;
  }
}

final Provider<WorkshopExtractionController>
workshopExtractionControllerProvider = Provider<WorkshopExtractionController>((
  Ref ref,
) {
  return WorkshopExtractionController(
    ref.read(sessionControllerProvider.notifier),
    ref.read(alchemyServiceProvider),
    materialCatalogRepository: ref.read(materialCatalogRepositoryProvider),
    extractionProfileRepository: ref.read(extractionProfileRepositoryProvider),
    workshopSkillTreeRepository: ref.read(workshopSkillTreeRepositoryProvider),
    workshopSkillTreeService: ref.read(workshopSkillTreeServiceProvider),
    workshopSupportService: ref.read(workshopSupportServiceProvider),
  );
});
