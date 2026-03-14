import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';

class RefreshMercenaryCandidatesUseCase {
  const RefreshMercenaryCandidatesUseCase();

  SessionState refreshCandidates({
    required SessionState state,
    required MercenaryRecruitmentService recruitmentService,
  }) {
    final int nextRefreshCount = state.town.mercenaryRefreshCount + 1;
    return state.copyWith(
      town: state.town.copyWith(
        mercenaryRefreshCount: nextRefreshCount,
        mercenaryCandidates: recruitmentService.buildCandidates(
          refreshIndex: nextRefreshCount,
        ),
      ),
    );
  }
}
