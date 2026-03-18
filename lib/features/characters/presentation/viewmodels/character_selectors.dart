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
    required this.typeLabel,
    required this.summaryLine,
    required this.growthLabel,
    required this.rankHint,
    required this.tierHint,
    required this.tierMaterialLabel,
    required this.equipmentSlots,
    required this.detailLines,
    required this.assignmentLabel,
    required this.assignmentGuideLabel,
  });

  final CharacterProgress character;
  final String typeLabel;
  final String summaryLine;
  final String growthLabel;
  final String rankHint;
  final String tierHint;
  final String tierMaterialLabel;
  final List<CharacterEquipmentSlotView> equipmentSlots;
  final List<String> detailLines;
  final String assignmentLabel;
  final String assignmentGuideLabel;
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
        stageAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.battle.stageAssignments,
          ),
        ),
        workshopSupportAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.workshop.supportAssignmentsByFunction,
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
        stageAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.battle.stageAssignments,
          ),
        ),
        workshopSupportAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.workshop.supportAssignmentsByFunction,
          ),
        ),
      );
    });

final Provider<List<CharacterListItemView>> allCharacterListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return <CharacterListItemView>[
        ...ref.watch(mercenaryListItemViewsProvider),
        ...ref.watch(homunculusListItemViewsProvider),
      ];
    });

final ProviderFamily<CharacterListItemView?, String> mercenaryItemViewProvider =
    Provider.family<CharacterListItemView?, String>((Ref ref, String id) {
      for (final CharacterListItemView item
          in ref.watch(mercenaryListItemViewsProvider)) {
        if (item.character.id == id) {
          return item;
        }
      }
      return null;
    });

final ProviderFamily<CharacterListItemView?, String> homunculusItemViewProvider =
    Provider.family<CharacterListItemView?, String>((Ref ref, String id) {
      for (final CharacterListItemView item
          in ref.watch(homunculusListItemViewsProvider)) {
        if (item.character.id == id) {
          return item;
        }
      }
      return null;
    });

List<CharacterListItemView> _buildCharacterViews({
  required List<CharacterProgress> characters,
  required Map<String, int> inventory,
  required List<EquipmentInstance> equipmentInventory,
  required Map<String, List<String>> stageAssignments,
  required Map<String, String> workshopSupportAssignments,
}) {
  return characters.map((CharacterProgress character) {
    return CharacterListItemView(
      character: character,
      typeLabel: _typeLabel(character.type),
      summaryLine: _summaryLine(character),
      growthLabel:
          'Lv ${character.level} / Rank ${character.rank} / Tier ${character.tierIndex}',
      rankHint: _rankUpHint(character),
      tierHint: _tierUpHint(character, inventory),
      tierMaterialLabel: _tierMaterialLabel(character, inventory),
      detailLines: _detailLines(character),
      assignmentLabel: _assignmentLabel(
        character.id,
        stageAssignments,
        workshopSupportAssignments,
      ),
      assignmentGuideLabel: '배치 변경은 전투/작업실 화면에서 진행',
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

String _typeLabel(CharacterType type) {
  return switch (type) {
    CharacterType.mercenary => '용병',
    CharacterType.homunculus => '호문쿨루스',
  };
}

String _summaryLine(CharacterProgress character) {
  if (character.type == CharacterType.homunculus) {
    final String role = character.homunculusRole ?? '지원';
    final String effect = character.homunculusSupportEffect ?? '효과 분석 중';
    return '$role / $effect';
  }
  if (character.canTierUp) {
    return '다음 행동: 티어업 가능';
  }
  if (character.canRankUp) {
    return '다음 행동: 랭크업 가능';
  }
  if (character.level < character.maxLevelForRank) {
    return '다음 목표: Lv ${character.maxLevelForRank}';
  }
  return '다음 목표: Rank ${character.maxRankForCurrentTier}';
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

String _tierMaterialLabel(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return '승급 재료: 없음';
  }
  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;
  return '승급 재료: $materialKey $owned/1';
}

String _assignmentLabel(
  String characterId,
  Map<String, List<String>> stageAssignments,
  Map<String, String> workshopSupportAssignments,
) {
  final List<String> assignments = stageAssignments.entries
      .where((MapEntry<String, List<String>> entry) {
        return entry.value.contains(characterId);
      })
      .map((MapEntry<String, List<String>> entry) {
        return entry.key.replaceFirst('stage_', 'Stage ');
      })
      .toList();

  final String? workshopSlot = _workshopSlotLabel(
    characterId,
    workshopSupportAssignments,
  );
  if (workshopSlot != null) {
    assignments.add('작업실($workshopSlot)');
  }

  if (assignments.isEmpty) {
    return '배치 상태: 대기';
  }
  return '배치 상태: ${assignments.join(", ")}';
}

String? _workshopSlotLabel(
  String characterId,
  Map<String, String> workshopSupportAssignments,
) {
  for (final MapEntry<String, String> entry in workshopSupportAssignments.entries) {
    if (entry.value != characterId) {
      continue;
    }
    switch (entry.key) {
      case 'extraction':
        return '추출';
      case 'crafting':
        return '제조';
      case 'enchant':
        return '인챈트';
      case 'hatch':
        return '부화';
    }
  }
  return null;
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
