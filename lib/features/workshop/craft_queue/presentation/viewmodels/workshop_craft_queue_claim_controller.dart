part of 'workshop_craft_queue_controller.dart';

mixin _WorkshopCraftQueueClaimController
    on _WorkshopCraftQueueControllerSupport {
  void claimPending() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _queueClaimUseCase.claimPending(
      state: current,
    );
    applyState(
      nextState,
      logMessage: identical(nextState, current)
          ? '수령 가능한 작업실 보상 없음'
          : '작업실 보상 수령',
    );
  }

  void claimJob(String jobId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _queueClaimUseCase.claimJob(
      state: current,
      jobId: jobId,
    );
    applyState(
      nextState,
      logMessage: identical(nextState, current)
          ? '수령 가능한 큐 작업 없음 / $jobId'
          : '큐 작업 수령 / $jobId',
    );
  }
}
