import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class CraftQueueService {
  CraftQueueService();

  List<CraftQueueJob> enqueue(List<CraftQueueJob> jobs, CraftQueueJob job) {
    return <CraftQueueJob>[...jobs, job];
  }

  List<CraftQueueJob> processTick(
    List<CraftQueueJob> jobs,
    Duration deltaTime,
  ) {
    if (jobs.isEmpty) {
      return jobs;
    }

    final List<CraftQueueJob> updated = <CraftQueueJob>[];
    Duration remaining = deltaTime;

    for (final CraftQueueJob job in jobs) {
      if (job.status == QueueJobStatus.completed) {
        updated.add(job);
        continue;
      }

      if (remaining <= Duration.zero) {
        updated.add(job);
        continue;
      }

      final Duration nextEta = job.eta - remaining;
      if (nextEta > Duration.zero) {
        updated.add(
          job.copyWith(status: QueueJobStatus.processing, eta: nextEta),
        );
        remaining = Duration.zero;
        continue;
      }

      final int nextRepeat = job.currentRepeat + 1;
      if (nextRepeat >= job.repeatCount) {
        updated.add(
          job.copyWith(
            status: QueueJobStatus.completed,
            currentRepeat: nextRepeat,
            eta: Duration.zero,
          ),
        );
      } else {
        updated.add(
          job.copyWith(
            status: QueueJobStatus.queued,
            currentRepeat: nextRepeat,
            eta: const Duration(seconds: 15),
          ),
        );
      }

      remaining = Duration.zero;
    }

    return updated;
  }

  List<CraftQueueJob> resumeBlocked(List<CraftQueueJob> jobs, String jobId) {
    return jobs.map((CraftQueueJob job) {
      if (job.id != jobId || job.status != QueueJobStatus.blocked) {
        return job;
      }
      return job.copyWith(
        status: QueueJobStatus.queued,
        eta: const Duration(seconds: 15),
      );
    }).toList();
  }
}
