import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_labels.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_shared_selectors.dart';

class CraftQueueJobView {
  const CraftQueueJobView({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.statusText,
    this.resultText,
    this.canClaim = false,
  });

  final String id;
  final String title;
  final String typeLabel;
  final String statusText;
  final String? resultText;
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
          WorkshopJobType.craft => '${job.title} x${job.repeatCount}',
          WorkshopJobType.enchant => job.title,
          WorkshopJobType.hatch => job.title,
        };
        return CraftQueueJobView(
          id: job.id,
          title: title,
          typeLabel: jobTypeLabel(job.type),
          statusText: queueStatusText(job),
          resultText: completedResultText(job),
          canClaim: job.status == QueueJobStatus.completed,
        );
      }).toList();
    });

final Provider<WorkshopQueueCardSummaryView> workshopQueueCardSummaryProvider =
    Provider<WorkshopQueueCardSummaryView>((Ref ref) {
      final List<CraftQueueJob> jobs = ref.watch(craftQueueProvider);
      final int jobCount = jobs.length;
      final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
      final CraftQueueJob? activeJob = jobs.cast<CraftQueueJob?>().firstWhere(
        (CraftQueueJob? job) => job?.status == QueueJobStatus.processing,
        orElse: () => null,
      );
      final int completedCount = jobs
          .where((CraftQueueJob job) => job.status == QueueJobStatus.completed)
          .length;
      final String left = activeJob == null
          ? '진행 없음'
          : '진행 ${activeJob.title}';
      return WorkshopQueueCardSummaryView(
        jobCount: jobCount,
        description: '$left / 슬롯 $jobCount/$queueCapacity / 수령 대기 $completedCount건',
      );
    });
