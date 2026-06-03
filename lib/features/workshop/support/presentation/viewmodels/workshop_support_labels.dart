import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';

String workshopSupportSlotLabel(String slotId) {
  switch (slotId) {
    case WorkshopSupportService.extractionSlot:
      return '추출';
    case WorkshopSupportService.craftingSlot:
      return '제조';
    case WorkshopSupportService.enchantSlot:
      return '인챈트';
    case WorkshopSupportService.hatchSlot:
      return '부화';
  }
  return slotId;
}

String workshopSupportSlotEffectLabel(String slotId) {
  switch (slotId) {
    case WorkshopSupportService.extractionSlot:
      return '추출 수율 +5%';
    case WorkshopSupportService.craftingSlot:
      return '제작 큐 슬롯 +1';
    case WorkshopSupportService.enchantSlot:
      return '인챈트 강화량 +5%';
    case WorkshopSupportService.hatchSlot:
      return '부화 신비 -1';
  }
  return '효과 없음';
}

String workshopSupportSummaryLabel(
  WorkshopSupportService supportService,
  SessionState state,
) {
  final List<String> labels = <String>[];
  for (final String slotId in WorkshopSupportService.slotOrder) {
    if (supportService.assignedCharacterId(state, slotId) != null) {
      labels.add(
        '${workshopSupportSlotLabel(slotId)} '
        '${workshopSupportSlotEffectLabel(slotId)}',
      );
    }
  }
  if (labels.isEmpty) {
    return '보조 효과 없음';
  }
  return labels.join(' / ');
}

String? assignedWorkshopSupportSlotLabelForCharacter(
  WorkshopSupportService supportService,
  SessionState state,
  String characterId,
) {
  for (final String slotId in WorkshopSupportService.slotOrder) {
    if (supportService.assignedCharacterId(state, slotId) == characterId) {
      return workshopSupportSlotLabel(slotId);
    }
  }
  return null;
}
