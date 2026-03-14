import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_extraction_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopExtractionController {
  WorkshopExtractionController(
    this._session,
    this._alchemyService, {
    WorkshopExtractionUseCase extractionDomain =
        const WorkshopExtractionUseCase(),
  }) : _extractionDomain = extractionDomain;

  final SessionController _session;
  final AlchemyService _alchemyService;
  final WorkshopExtractionUseCase _extractionDomain;

  void extractMaterial(
    String materialId,
    String profileId, {
    List<String>? selectedTraits,
  }) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _extractionDomain.extractMaterial(
      state: current,
      materialId: materialId,
      profileId: profileId,
      alchemyService: _alchemyService,
      selectedTraits: selectedTraits,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Cannot extract $materialId / unavailable'
          : 'Extracted $materialId with $profileId',
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
  );
});
