import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class WorkshopSupportService {
  const WorkshopSupportService();

  static const String extractionSlot = 'extraction';
  static const String craftingSlot = 'crafting';
  static const String enchantSlot = 'enchant';
  static const String hatchSlot = 'hatch';

  static const int maxAssignedCount = 3;

  static const List<String> slotOrder = <String>[
    extractionSlot,
    craftingSlot,
    enchantSlot,
    hatchSlot,
  ];

  int assignedCount(SessionState state) {
    return state.workshop.supportAssignmentsByFunction.length;
  }

  String? assignedCharacterId(SessionState state, String slotId) {
    return state.workshop.supportAssignmentsByFunction[slotId];
  }

  bool isAssignedAnywhere(SessionState state, String characterId) {
    return state.workshop.supportAssignmentsByFunction.values.contains(
      characterId,
    );
  }

  List<CharacterProgress> assignedHomunculi(SessionState state) {
    final Set<String> assignedIds = state
        .workshop
        .supportAssignmentsByFunction
        .values
        .toSet();
    return state.characters.homunculi
        .where((CharacterProgress character) {
          return assignedIds.contains(character.id);
        })
        .toList(growable: false);
  }

  double extractionYieldBonusRate(SessionState state) {
    return assignedCharacterId(state, extractionSlot) == null ? 0 : 0.05;
  }

  int craftQueueCapacityBonus(SessionState state) {
    return assignedCharacterId(state, craftingSlot) == null ? 0 : 1;
  }

  double enchantPotencyBonusRate(SessionState state) {
    return assignedCharacterId(state, enchantSlot) == null ? 0 : 0.05;
  }

  int hatchArcaneDustDiscount(SessionState state) {
    return assignedCharacterId(state, hatchSlot) == null ? 0 : 1;
  }
}
