import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
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
    final String baseLabel =
        'ATK ${item.totalAttack} / DEF ${item.totalDefense} / HP ${item.totalHealth}';
    final String? enchantLabel = item.enchant?.label;
    if (enchantLabel == null) {
      return baseLabel;
    }
    return '$baseLabel / $enchantLabel';
  }
}

class CharacterListItemView {
  const CharacterListItemView({
    required this.character,
    required this.rankHint,
    required this.tierHint,
    required this.equipmentSlots,
    required this.detailLines,
  });

  final CharacterProgress character;
  final String rankHint;
  final String tierHint;
  final List<CharacterEquipmentSlotView> equipmentSlots;
  final List<String> detailLines;
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
      detailLines: _detailLines(character),
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

List<String> _detailLines(CharacterProgress character) {
  if (character.type == CharacterType.homunculus) {
    return <String>[
      '출처 ${character.homunculusOrigin ?? "미확인 시드"}',
      '역할 ${character.homunculusRole ?? "지원"}',
      '보조효과 ${character.homunculusSupportEffect ?? "효과 분석 중"}',
    ];
  }

  final String role = switch (character.mercenaryTier ?? MercenaryTier.rookie) {
    MercenaryTier.rookie => '기본 전열',
    MercenaryTier.veteran => '숙련 전열',
    MercenaryTier.elite => '정예 전열',
    MercenaryTier.champion => '챔피언 전열',
    MercenaryTier.legend => '전설 전열',
  };
  return <String>['역할 $role'];
}

final Provider<List<CharacterProgress>> homunculusListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.homunculi,
        ),
      );
    });
