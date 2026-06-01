import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

SessionState claimExtractionJob({
  required SessionState state,
  required List<CraftQueueJob> queue,
  required CraftQueueJob job,
}) {
  final Map<String, double> extractedTraits = <String, double>{
    ...state.workshop.extractedTraitInventory,
  };
  job.completedExtractedTraits.forEach((String key, double value) {
    extractedTraits[key] = (extractedTraits[key] ?? 0) + value;
  });

  return state.copyWith(
    player: state.player.copyWith(
      arcaneDust: state.player.arcaneDust + job.completedArcaneDust,
    ),
    workshop: state.workshop.copyWith(
      queue: queue,
      extractedTraitInventory: extractedTraits,
      extractionCount: state.workshop.extractionCount + job.quantity,
    ),
  );
}
