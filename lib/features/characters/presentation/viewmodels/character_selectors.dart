import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterEquipmentSlotView {
  const CharacterEquipmentSlotView({
    required this.slot,
    required this.equippedItem,
    required this.availableItems,
  });

  final EquipmentSlot slot;
  final EquipmentInstance? equippedItem;
  final List<EquipmentInstance> availableItems;

  String get slotLabel {
    switch (slot) {
      case EquipmentSlot.weapon:
        return '무기';
      case EquipmentSlot.armor:
        return '방어구';
      case EquipmentSlot.accessory:
        return '장신구';
    }
  }

  String get currentLabel => equippedItem?.name ?? '미장착';

  String get statLabel {
    final EquipmentInstance? item = equippedItem;
    if (item == null) {
      return '장착 가능한 장비 ${availableItems.length}개';
    }
    return 'ATK ${item.attack} / DEF ${item.defense} / HP ${item.health}';
  }
}

class CharacterListItemView {
  const CharacterListItemView({
    required this.character,
    required this.rankHint,
    required this.tierHint,
    required this.equipmentSlots,
  });

  final CharacterProgress character;
  final String rankHint;
  final String tierHint;
  final List<CharacterEquipmentSlotView> equipmentSlots;
}

final Provider<List<CharacterProgress>> mercenaryListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.mercenaries,
        ),
      );
    });

final Provider<List<CharacterListItemView>> mercenaryListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(mercenaryListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
        equipmentInventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.town.equipmentInventory,
          ),
        ),
      );
    });

final Provider<List<CharacterListItemView>> homunculusListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(homunculusListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
        equipmentInventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.town.equipmentInventory,
          ),
        ),
      );
    });

List<CharacterListItemView> _buildCharacterViews({
  required List<CharacterProgress> characters,
  required Map<String, int> inventory,
  required List<EquipmentInstance> equipmentInventory,
}) {
  return characters.map((CharacterProgress character) {
    return CharacterListItemView(
      character: character,
      rankHint: _rankUpHint(character),
      tierHint: _tierUpHint(character, inventory),
      equipmentSlots: EquipmentSlot.values
          .map((EquipmentSlot slot) {
            return CharacterEquipmentSlotView(
              slot: slot,
              equippedItem: character.equipment.itemForSlot(slot),
              availableItems: equipmentInventory
                  .where((EquipmentInstance item) => item.slot == slot)
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
  }).toList();
}

String _rankUpHint(CharacterProgress character) {
  if (character.canRankUp) {
    return '랭크업 가능';
  }
  if (character.rank >= character.maxRankForCurrentTier) {
    return '현재 티어 최대 랭크 도달';
  }
  return '랭크업 조건: Lv ${character.maxLevelForRank} 도달 필요';
}

String _tierUpHint(CharacterProgress character, Map<String, int> inventory) {
  if (character.tierIndex >= character.maxTier) {
    return '티어 승급 완료';
  }

  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;

  if (character.canTierUp) {
    if (owned > 0) {
      return '티어업 가능';
    }
    return '티어업 조건 충족, 승급 재료 부족';
  }

  return '티어업 조건: Rank ${character.maxRankForCurrentTier} 도달 필요';
}

final Provider<List<CharacterProgress>> homunculusListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.homunculi,
        ),
      );
    });
