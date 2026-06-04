import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_labels.dart';

class CraftQueueJobView {
  const CraftQueueJobView({
    required this.id,
    required this.title,
    required this.statusLabel,
    this.timeLabel,
    this.canClaim = false,
  });

  final String id;
  final String title;
  final String statusLabel;
  final String? timeLabel;
  final bool canClaim;
}

class WorkshopQueueCardSummaryView {
  const WorkshopQueueCardSummaryView({
    required this.jobCount,
    required this.description,
  });

  final int jobCount;
  final String description;
}

final Provider<List<CraftQueueJob>> craftQueueProvider =
    Provider<List<CraftQueueJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.queue,
        ),
      );
    });

final Provider<List<CraftQueueJobView>> craftQueueJobViewsProvider =
    Provider<List<CraftQueueJobView>>((Ref ref) {
      final List<CraftQueueJob> queue = ref.watch(craftQueueProvider);
      final List<CraftQueueJob> sortedQueue = <CraftQueueJob>[...queue]
        ..sort((CraftQueueJob left, CraftQueueJob right) {
          final int leftRank = statusRank(left.status);
          final int rightRank = statusRank(right.status);
          if (leftRank != rightRank) {
            return leftRank.compareTo(rightRank);
          }
          return left.queuedAt.compareTo(right.queuedAt);
        });
      return sortedQueue.take(20).map((CraftQueueJob job) {
        final String title = switch (job.type) {
          WorkshopJobType.extraction => '${job.title} x${job.quantity}',
          WorkshopJobType.craft =>
            job.completedMaterials.isNotEmpty
                ? job.title
                : '${job.title} x${job.repeatCount}',
          WorkshopJobType.enchant => job.title,
          WorkshopJobType.hatch => job.title,
        };
        return CraftQueueJobView(
          id: job.id,
          title: title,
          statusLabel: queueStatusBadgeLabel(job.status),
          timeLabel: queueTimeLabel(job),
          canClaim: job.status == QueueJobStatus.completed,
        );
      }).toList();
    });

final Provider<WorkshopQueueCardSummaryView> workshopQueueCardSummaryProvider =
    Provider<WorkshopQueueCardSummaryView>((Ref ref) {
      final List<CraftQueueJob> jobs = ref.watch(craftQueueProvider);
      final int jobCount = jobs.length;
      final bool hasActiveJob = jobs.any(
        (CraftQueueJob job) => job.status == QueueJobStatus.processing,
      );
      final int completedCount = jobs
          .where((CraftQueueJob job) => job.status == QueueJobStatus.completed)
          .length;
      final String description;
      if (completedCount > 0) {
        description = '수령 $completedCount건';
      } else if (hasActiveJob) {
        description = '진행 중';
      } else if (jobCount > 0) {
        description = '대기 $jobCount건';
      } else {
        description = '비어 있음';
      }
      return WorkshopQueueCardSummaryView(
        jobCount: jobCount,
        description: description,
      );
    });
