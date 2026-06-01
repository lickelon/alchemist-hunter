import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

SessionState claimHatchJob({
  required SessionState state,
  required List<CraftQueueJob> queue,
  required CraftQueueJob job,
}) {
  final CharacterProgress? homunculus = job.completedHomunculus;
  if (homunculus == null) {
    return state;
  }

  return state.copyWith(
    workshop: state.workshop.copyWith(queue: queue),
    characters: state.characters.copyWith(
      homunculi: <CharacterProgress>[...state.characters.homunculi, homunculus],
    ),
  );
}
