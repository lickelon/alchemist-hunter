import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/craft_queue_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queue tick completes job without random failure', () {
    final CraftQueueService service = CraftQueueService();
    final CraftQueueJob job = CraftQueueJob(
      id: 'j1',
      type: WorkshopJobType.craft,
      queuedAt: DateTime(2026, 1, 1, 10),
      duration: const Duration(seconds: 5),
      potionId: 'p1',
      repeatCount: 1,
      retryPolicy: const CraftRetryPolicy(maxRetries: 0),
      status: QueueJobStatus.queued,
      eta: const Duration(seconds: 5),
    );

    final List<CraftQueueJob> result = service.processTick(<CraftQueueJob>[
      job,
    ], const Duration(seconds: 10));

    expect(result, hasLength(1));
    expect(result.first.status, QueueJobStatus.completed);
  });
}
