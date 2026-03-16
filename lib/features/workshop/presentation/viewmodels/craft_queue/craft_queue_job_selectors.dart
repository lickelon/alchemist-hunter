import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_labels.dart';

class CraftQueueJobView {
  const CraftQueueJobView({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.statusText,
  });

  final String id;
  final String title;
  final String typeLabel;
  final String statusText;
}

class WorkshopPendingClaimView {
  const WorkshopPendingClaimView({
    required this.canClaim,
    required this.summary,
  });

  final bool canClaim;
  final String summary;
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
        );
      }).toList();
    });

final Provider<WorkshopPendingClaimView> workshopPendingClaimViewProvider =
    Provider<WorkshopPendingClaimView>((Ref ref) {
      final WorkshopPendingClaim claim = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.pendingClaim,
        ),
      );
      if (claim.isEmpty) {
        return const WorkshopPendingClaimView(
          canClaim: false,
          summary: '수령 가능한 작업실 보상 없음',
        );
      }

      final int traitTypes = claim.extractedTraits.length;
      final int potionStacks = claim.potionStacks.values.fold<int>(
        0,
        (int total, int value) => total + value,
      );
      return WorkshopPendingClaimView(
        canClaim: true,
        summary:
            '추출 특성 $traitTypes종 / ArcaneDust +${claim.arcaneDust} / 포션 $potionStacks개 / 장비 ${claim.equipmentClaims.length}개 / 호문쿨루스 ${claim.homunculi.length}체',
      );
    });
