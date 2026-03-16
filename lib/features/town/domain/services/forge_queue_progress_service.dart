import 'package:alchemist_hunter/features/town/domain/models.dart';

class ForgeQueueProgressService {
  const ForgeQueueProgressService();

  TownState syncQueue({
    required TownState town,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    if (town.forgeQueue.isEmpty) {
      return town;
    }

    final List<TownForgeJob> nextQueue = <TownForgeJob>[];
    DateTime cursor = syncFrom;

    for (final TownForgeJob job in town.forgeQueue) {
      if (job.status == TownForgeJobStatus.completed) {
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
                ? TownForgeJobStatus.queued
                : TownForgeJobStatus.processing,
          ),
        );
        continue;
      }

      final Duration available = _scaledDuration(
        now.difference(startTime),
        speedMultiplier,
      );
      if (job.remaining > available) {
        nextQueue.add(
          job.copyWith(
            status: TownForgeJobStatus.processing,
            startedAt: job.startedAt ?? startTime,
            remaining: job.remaining - available,
          ),
        );
        cursor = now;
        continue;
      }

      nextQueue.add(
        job.copyWith(
          status: TownForgeJobStatus.completed,
          startedAt: job.startedAt ?? startTime,
          remaining: Duration.zero,
        ),
      );
      cursor = startTime.add(job.remaining);
    }

    return town.copyWith(forgeQueue: nextQueue);
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
