import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_extraction_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

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

  void extractMaterial(
    String materialId,
    String profileId, {
    int quantity = 1,
    List<String>? selectedTraits,
  }) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _extractionDomain.extractMaterial(
      state: current,
      materialId: materialId,
      profileId: profileId,
      alchemyService: _alchemyService,
      materialCatalogRepository: _materialCatalogRepository,
      extractionProfileRepository: _extractionProfileRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
      quantity: quantity,
      selectedTraits: selectedTraits,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Cannot extract $materialId x$quantity / unavailable'
          : 'Extracted $materialId x$quantity with $profileId',
    );
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
