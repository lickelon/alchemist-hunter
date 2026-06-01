import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

String characterRankUpLogMessage(CharacterProgress? character) {
  if (character == null) {
    return '캐릭터를 찾을 수 없음';
  }
  if (!character.canRankUp) {
    return '랭크업 조건 미충족';
  }
  return '${character.name} 랭크업 -> 랭크 ${character.rank + 1}';
}

String characterTierUpLogMessage({
  required SessionState current,
  required CharacterProgress? character,
  required String? requiredMaterial,
}) {
  if (character == null) {
    return '캐릭터를 찾을 수 없음';
  }
  if (!character.canTierUp) {
    return '티어업 조건 미충족';
  }
  if ((current.player.materialInventory[requiredMaterial] ?? 0) < 1) {
    return '승급 재료 부족';
  }
  return '${character.name} 티어업 -> 티어 ${character.tierIndex + 1}';
}

String characterEquipLogMessage({
  required CharacterProgress? character,
  required EquipmentInstance? item,
}) {
  if (character == null) {
    return '캐릭터를 찾을 수 없음';
  }
  if (item == null) {
    return '장비를 찾을 수 없음';
  }
  return '${character.name}에 ${item.name} 장착';
}

String characterUnequipLogMessage({
  required CharacterProgress? character,
  required EquipmentInstance? item,
  required EquipmentSlot slot,
}) {
  if (character == null) {
    return '캐릭터를 찾을 수 없음';
  }
  if (item == null) {
    return '${equipmentSlotLogLabel(slot)} 슬롯에 장착된 장비 없음';
  }
  return '${character.name}에서 ${item.name} 해제';
}

String characterTierMaterialKey(CharacterProgress character) {
  final int nextTier = character.tierIndex + 1;
  if (character.type == CharacterType.mercenary) {
    return 'tier_mat_mercenary_$nextTier';
  }
  return 'tier_mat_homunculus_$nextTier';
}

String equipmentSlotLogLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.weapon => '무기',
    EquipmentSlot.armor => '방어구',
    EquipmentSlot.accessory => '장신구',
  };
}
