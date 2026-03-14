import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_extraction_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopExtractionController {
  WorkshopExtractionController(
    this._session,
    this._alchemyService, {
    WorkshopExtractionUseCase extractionDomain =
        const WorkshopExtractionUseCase(),
    required MaterialCatalogRepository materialCatalogRepository,
    required ExtractionProfileRepository extractionProfileRepository,
  }) : _extractionDomain = extractionDomain,
       _materialCatalogRepository = materialCatalogRepository,
       _extractionProfileRepository = extractionProfileRepository;

  final SessionController _session;
  final AlchemyService _alchemyService;
  final WorkshopExtractionUseCase _extractionDomain;
  final MaterialCatalogRepository _materialCatalogRepository;
  final ExtractionProfileRepository _extractionProfileRepository;

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
  );
});
