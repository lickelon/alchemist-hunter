import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/hire_mercenary_use_case.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/refresh_mercenary_candidates_use_case.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_catalog_providers.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MercenaryController {
  MercenaryController(
    this._session, {
    RefreshMercenaryCandidatesUseCase refreshMercenaryCandidatesUseCase =
        const RefreshMercenaryCandidatesUseCase(),
    HireMercenaryUseCase hireMercenaryUseCase = const HireMercenaryUseCase(),
    MercenaryRecruitmentService recruitmentService =
        const MercenaryRecruitmentService(),
    required MercenaryTemplateRepository mercenaryTemplateRepository,
  }) : _refreshMercenaryCandidatesUseCase = refreshMercenaryCandidatesUseCase,
       _hireMercenaryUseCase = hireMercenaryUseCase,
       _recruitmentService = recruitmentService,
       _mercenaryTemplateRepository = mercenaryTemplateRepository;

  final SessionController _session;
  final RefreshMercenaryCandidatesUseCase _refreshMercenaryCandidatesUseCase;
  final HireMercenaryUseCase _hireMercenaryUseCase;
  final MercenaryRecruitmentService _recruitmentService;
  final MercenaryTemplateRepository _mercenaryTemplateRepository;

  void refreshMercenaryCandidates() {
    final SessionState current = _session.snapshot();
    final SessionState nextState =
        _refreshMercenaryCandidatesUseCase.refreshCandidates(
          state: current,
          recruitmentService: _recruitmentService,
          templateRepository: _mercenaryTemplateRepository,
        );
    _session.applyState(nextState);
    _session.appendLog('Refreshed mercenary candidates');
  }

  void hireMercenary(String candidateId) {
    final SessionState current = _session.snapshot();
    final candidate = current.town.mercenaryCandidates
        .where((entry) => entry.id == candidateId)
        .firstOrNull;
    if (candidate == null) {
      _session.appendLog('Mercenary candidate missing: $candidateId');
      return;
    }
    final SessionState nextState = _hireMercenaryUseCase.hireCandidate(
      state: current,
      candidateId: candidateId,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Not enough gold for ${candidate.name}'
          : 'Hired ${candidate.name}',
    );
  }
}

final Provider<MercenaryController> mercenaryControllerProvider =
    Provider<MercenaryController>((Ref ref) {
      return MercenaryController(
        ref.read(sessionControllerProvider.notifier),
        recruitmentService: ref.read(mercenaryRecruitmentServiceProvider),
        mercenaryTemplateRepository: ref.read(
          mercenaryTemplateRepositoryProvider,
        ),
      );
    });
