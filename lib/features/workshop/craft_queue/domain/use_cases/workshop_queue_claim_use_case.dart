import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/workshop_queue_claim_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopQueueClaimUseCase {
  const WorkshopQueueClaimUseCase({
    WorkshopQueueClaimService claimService = const WorkshopQueueClaimService(),
  }) : _claimService = claimService;

  final WorkshopQueueClaimService _claimService;

  SessionState claimPending({required SessionState state}) {
    SessionState nextState = state;
    for (final String jobId
        in state.workshop.queue
            .where(
              (CraftQueueJob job) => job.status == QueueJobStatus.completed,
            )
            .map((CraftQueueJob job) => job.id)
            .toList()) {
      nextState = claimJob(state: nextState, jobId: jobId);
    }
    return nextState;
  }

  SessionState claimJob({required SessionState state, required String jobId}) {
    final int jobIndex = state.workshop.queue.indexWhere(
      (CraftQueueJob job) => job.id == jobId,
    );
    if (jobIndex == -1) {
      return state;
    }
    final CraftQueueJob job = state.workshop.queue[jobIndex];
    if (job.status != QueueJobStatus.completed) {
      return state;
    }

    final List<CraftQueueJob> nextQueue = <CraftQueueJob>[
      ...state.workshop.queue,
    ]..removeAt(jobIndex);

    return _claimService.applyCompletedJob(
      state: state,
      queue: nextQueue,
      job: job,
    );
  }
}
