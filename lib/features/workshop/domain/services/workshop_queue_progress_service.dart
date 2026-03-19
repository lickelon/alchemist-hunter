import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopQueueProgressService {
  const WorkshopQueueProgressService();

  WorkshopState syncQueue({
    required WorkshopState workshop,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    if (workshop.queue.isEmpty) {
      return workshop;
    }

    final List<CraftQueueJob> nextQueue = <CraftQueueJob>[];
    DateTime cursor = syncFrom;

    for (final CraftQueueJob job in workshop.queue) {
      if (job.status == QueueJobStatus.blocked) {
        nextQueue.add(job);
        continue;
      }

      if (job.status == QueueJobStatus.completed) {
        nextQueue.add(job);
        continue;
      }

      final DateTime startTime = _laterOf(
        cursor,
        job.startedAt ?? job.queuedAt,
      );
      if (!now.isAfter(startTime)) {
        nextQueue.add(
          job.copyWith(
            status: job.startedAt == null
                ? QueueJobStatus.queued
                : QueueJobStatus.processing,
          ),
        );
        continue;
      }

      final Duration available = _scaledDuration(
        now.difference(startTime),
        speedMultiplier,
      );
      if (job.eta > available) {
        nextQueue.add(
          job.copyWith(
            status: QueueJobStatus.processing,
            startedAt: job.startedAt ?? startTime,
            eta: job.eta - available,
          ),
        );
        cursor = now;
        continue;
      }

      nextQueue.add(
        job.copyWith(
          status: QueueJobStatus.completed,
          eta: Duration.zero,
        ),
      );
      cursor = startTime.add(job.eta);
    }

    return workshop.copyWith(queue: nextQueue);
  }

  DateTime _laterOf(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Duration _scaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds * multiplier).round());
  }
}
