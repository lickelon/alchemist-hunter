import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_sections.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_sheet.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailSheet extends ConsumerWidget {
  const CharacterDetailSheet({
    super.key,
    required this.type,
    required this.characterId,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterType type;
  final String characterId;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CharacterListItemView? item = switch (type) {
      CharacterType.mercenary => ref.watch(
        mercenaryItemViewProvider(characterId),
      ),
      CharacterType.homunculus => ref.watch(
        homunculusItemViewProvider(characterId),
      ),
    };
    if (item == null) {
      return const AppBottomSheet(child: Text('캐릭터 정보를 찾을 수 없습니다'));
    }

    final CharacterProgress character = item.character;
    final String totalStatLabel = characterTotalStatLabel(item.equipmentSlots);
    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${character.name} / ${item.typeLabel}',
        body: ListView(
          children: <Widget>[
            CharacterGrowthSection(
              character: character,
              growthLabel: item.growthLabel,
            ),
            CharacterDetailSection(title: '총합 스탯', child: Text(totalStatLabel)),
            CharacterGoalSection(
              rankHint: item.rankHint,
              tierHint: item.tierHint,
              tierMaterialLabel: item.tierMaterialLabel,
            ),
            CharacterAssignmentSection(
              assignmentLabel: item.assignmentLabel,
              assignmentGuideLabel: item.assignmentGuideLabel,
            ),
            CharacterCombatSection(
              powerLabel: item.combatPowerLabel,
              statLines: item.combatStatLines,
            ),
            if (item.detailLines.isNotEmpty)
              CharacterProfileSection(detailLines: item.detailLines),
            CharacterActionSection(
              character: character,
              onRankUp: onRankUp,
              onTierUp: onTierUp,
            ),
            CharacterEquipmentSection(
              slots: item.equipmentSlots,
              onManage: (CharacterEquipmentSlotView slot) {
                _showEquipmentSheet(context, character: character, slot: slot);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEquipmentSheet(
    BuildContext context, {
    required CharacterProgress character,
    required CharacterEquipmentSlotView slot,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CharacterEquipmentSheet(
          character: character,
          slot: slot,
          onEquip: onEquip,
          onUnequip: onUnequip,
        );
      },
    );
  }
}
