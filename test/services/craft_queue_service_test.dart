import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queue tick completes or advances job state', () {
    final CraftQueueService service = CraftQueueService(random: Random(1));
    final CraftQueueJob job = CraftQueueJob(
      id: 'j1',
      potionId: 'p1',
      repeatCount: 1,
      retryPolicy: const CraftRetryPolicy(maxRetries: 0),
      status: QueueJobStatus.queued,
      eta: const Duration(seconds: 5),
    );

    final List<CraftQueueJob> result =
        service.processTick(<CraftQueueJob>[job], const Duration(seconds: 10));

    expect(result, hasLength(1));
    expect(
      <QueueJobStatus>{QueueJobStatus.completed, QueueJobStatus.failed}
          .contains(result.first.status),
      true,
    );
  });
}
