import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/alchemy_service.dart';

import '../workshop_service_providers.dart';
import 'extraction_domain.dart';

class WorkshopExtractionController {
  WorkshopExtractionController(
    this._session,
    this._alchemyService, {
    WorkshopExtractionDomain extractionDomain =
        const WorkshopExtractionDomain(),
  }) : _extractionDomain = extractionDomain;

  final SessionController _session;
  final AlchemyService _alchemyService;
  final WorkshopExtractionDomain _extractionDomain;

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
