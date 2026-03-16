import 'package:alchemist_hunter/features/characters/domain/models.dart';
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
    WorkshopPendingClaim pendingClaim = workshop.pendingClaim;
    DateTime cursor = syncFrom;

    for (final CraftQueueJob job in workshop.queue) {
      if (job.status == QueueJobStatus.blocked) {
        nextQueue.add(job);
        continue;
      }

      if (job.status == QueueJobStatus.completed) {
        pendingClaim = _appendPendingClaim(pendingClaim, job);
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

      pendingClaim = _appendPendingClaim(pendingClaim, job);
      cursor = startTime.add(job.eta);
    }

    return workshop.copyWith(queue: nextQueue, pendingClaim: pendingClaim);
  }

  WorkshopPendingClaim _appendPendingClaim(
    WorkshopPendingClaim pendingClaim,
    CraftQueueJob job,
  ) {
    switch (job.type) {
      case WorkshopJobType.extraction:
        final Map<String, double> nextTraits = <String, double>{
          ...pendingClaim.extractedTraits,
        };
        job.completedExtractedTraits.forEach((String key, double value) {
          nextTraits[key] = (nextTraits[key] ?? 0) + value;
        });
        return pendingClaim.copyWith(
          extractedTraits: nextTraits,
          arcaneDust: pendingClaim.arcaneDust + job.completedArcaneDust,
          extractionCount: pendingClaim.extractionCount + job.quantity,
        );
      case WorkshopJobType.craft:
        if (job.completedPotionStackKey == null ||
            job.completedPotion == null) {
          return pendingClaim;
        }
        final Map<String, int> nextStacks = <String, int>{
          ...pendingClaim.potionStacks,
        };
        nextStacks[job.completedPotionStackKey!] =
            (nextStacks[job.completedPotionStackKey!] ?? 0) + job.repeatCount;
        final Map<String, CraftedPotion> nextDetails = <String, CraftedPotion>{
          ...pendingClaim.potionDetails,
        };
        nextDetails.putIfAbsent(
          job.completedPotionStackKey!,
          () => job.completedPotion!,
        );
        return pendingClaim.copyWith(
          potionStacks: nextStacks,
          potionDetails: nextDetails,
          potionCraftCount: pendingClaim.potionCraftCount + job.repeatCount,
        );
      case WorkshopJobType.enchant:
        if (job.completedEquipment == null) {
          return pendingClaim;
        }
        return pendingClaim.copyWith(
          equipmentClaims: <WorkshopEquipmentClaim>[
            ...pendingClaim.equipmentClaims,
            WorkshopEquipmentClaim(
              equipment: job.completedEquipment!,
              ownerCharacterId: job.equipmentOwnerId,
              ownerType: job.equipmentOwnerType,
            ),
          ],
          enchantCount: pendingClaim.enchantCount + 1,
        );
      case WorkshopJobType.hatch:
        if (job.completedHomunculus == null) {
          return pendingClaim;
        }
        return pendingClaim.copyWith(
          homunculi: <CharacterProgress>[
            ...pendingClaim.homunculi,
            job.completedHomunculus!,
          ],
        );
    }
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
