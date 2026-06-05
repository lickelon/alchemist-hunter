import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/hire_mercenary_use_case.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/refresh_mercenary_candidates_use_case.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
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
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
    required BattleCatalogRepository battleCatalogRepository,
  }) : _refreshMercenaryCandidatesUseCase = refreshMercenaryCandidatesUseCase,
       _hireMercenaryUseCase = hireMercenaryUseCase,
       _recruitmentService = recruitmentService,
       _mercenaryTemplateRepository = mercenaryTemplateRepository,
       _townSkillTreeRepository = townSkillTreeRepository,
       _townSkillTreeService = townSkillTreeService,
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final RefreshMercenaryCandidatesUseCase _refreshMercenaryCandidatesUseCase;
  final HireMercenaryUseCase _hireMercenaryUseCase;
  final MercenaryRecruitmentService _recruitmentService;
  final MercenaryTemplateRepository _mercenaryTemplateRepository;
  final TownSkillTreeRepository _townSkillTreeRepository;
  final TownSkillTreeService _townSkillTreeService;
  final BattleCatalogRepository _battleCatalogRepository;

  void refreshMercenaryCandidates() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _refreshMercenaryCandidatesUseCase
        .refreshCandidates(
          state: current,
          recruitmentService: _recruitmentService,
          templateRepository: _mercenaryTemplateRepository,
        );
    _session.applyState(nextState);
    _session.appendLog('용병 후보 갱신');
  }

  void hireMercenary(String candidateId) {
    final SessionState current = _session.snapshot();
    final candidate = current.town.mercenaryCandidates
        .where((entry) => entry.id == candidateId)
        .firstOrNull;
    if (candidate == null) {
      _session.appendLog('용병 후보 없음: $candidateId');
      return;
    }
    final String candidateName = mercenaryCandidateDisplayName(
      candidate,
      _battleCatalogRepository,
    );
    final SessionState nextState = _hireMercenaryUseCase.hireCandidate(
      state: current,
      candidateId: candidateId,
      now: _session.now(),
      townSkillTreeRepository: _townSkillTreeRepository,
      townSkillTreeService: _townSkillTreeService,
      battleCatalogRepository: _battleCatalogRepository,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? '골드 부족 / $candidateName'
          : '용병 고용 / $candidateName',
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
        townSkillTreeRepository: ref.read(townSkillTreeRepositoryProvider),
        townSkillTreeService: ref.read(townSkillTreeServiceProvider),
        battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
      );
    });
