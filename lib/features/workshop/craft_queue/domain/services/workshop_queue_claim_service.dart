import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/workshop_queue_craft_claim.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/workshop_queue_enchant_claim.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/workshop_queue_extraction_claim.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/workshop_queue_hatch_claim.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopQueueClaimService {
  const WorkshopQueueClaimService();

  SessionState applyCompletedJob({
    required SessionState state,
    required List<CraftQueueJob> queue,
    required CraftQueueJob job,
  }) {
    return switch (job.type) {
      WorkshopJobType.extraction => claimExtractionJob(
        state: state,
        queue: queue,
        job: job,
      ),
      WorkshopJobType.craft => claimCraftJob(
        state: state,
        queue: queue,
        job: job,
      ),
      WorkshopJobType.enchant => claimEnchantJob(
        state: state,
        queue: queue,
        job: job,
      ),
      WorkshopJobType.hatch => claimHatchJob(
        state: state,
        queue: queue,
        job: job,
      ),
    };
  }
}
