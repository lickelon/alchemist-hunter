import 'package:alchemist_hunter/app/session/app_session.dart';
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
    return state.workshop.supportAssignmentsByFunction.values.contains(characterId);
  }

  List<CharacterProgress> assignedHomunculi(SessionState state) {
    final Set<String> assignedIds =
        state.workshop.supportAssignmentsByFunction.values.toSet();
    return state.characters.homunculi.where((CharacterProgress character) {
      return assignedIds.contains(character.id);
    }).toList(growable: false);
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

  String slotLabel(String slotId) {
    switch (slotId) {
      case extractionSlot:
        return '추출';
      case craftingSlot:
        return '제조';
      case enchantSlot:
        return '인챈트';
      case hatchSlot:
        return '부화';
    }
    return slotId;
  }

  String slotEffectLabel(String slotId) {
    switch (slotId) {
      case extractionSlot:
        return '추출 수율 +5%';
      case craftingSlot:
        return '제작 큐 슬롯 +1';
      case enchantSlot:
        return '인챈트 강화량 +5%';
      case hatchSlot:
        return '부화 ArcaneDust -1';
    }
    return '효과 없음';
  }

  String summaryLabel(SessionState state) {
    final List<String> labels = <String>[];
    for (final String slotId in slotOrder) {
      if (assignedCharacterId(state, slotId) != null) {
        labels.add('${slotLabel(slotId)} ${slotEffectLabel(slotId)}');
      }
    }
    if (labels.isEmpty) {
      return '보조 효과 없음';
    }
    return labels.join(' / ');
  }

  String? assignedSlotLabelForCharacter(SessionState state, String characterId) {
    for (final String slotId in slotOrder) {
      if (assignedCharacterId(state, slotId) == characterId) {
        return slotLabel(slotId);
      }
    }
    return null;
  }
}
