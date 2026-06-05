import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_list_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_assignment_section.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_combat_sections.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_section.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_sheet.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_growth_section.dart';
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
      return const AppSheetLayout(
        title: '캐릭터 정보',
        expandBody: false,
        body: Text('캐릭터 정보를 찾을 수 없습니다'),
      );
    }

    final CharacterProgress character = item.character;
    return AppSheetLayout(
      title: '${character.name} ${item.typeLabel}',
      body: ListView(
        children: <Widget>[
          CharacterGrowthSection(
            character: character,
            hasTierUpMaterial: item.hasTierUpMaterial,
            onRankUp: onRankUp,
            onTierUp: onTierUp,
          ),
          CharacterCombatSection(
            powerLabel: item.combatPowerLabel,
            statPairs: item.combatStatPairs,
          ),
          if (item.combatEffectLines.isNotEmpty)
            CharacterCombatEffectSection(effectLines: item.combatEffectLines),
          CharacterEquipmentSection(
            slots: item.equipmentSlots,
            onManage: (CharacterEquipmentSlotView slot) {
              _showEquipmentSheet(context, character: character, slot: slot);
            },
          ),
          CharacterAssignmentSection(
            assignmentLabel: item.assignmentLabel,
            assignmentGuideLabel: item.assignmentGuideLabel,
          ),
        ],
      ),
    );
  }

  void _showEquipmentSheet(
    BuildContext context, {
    required CharacterProgress character,
    required CharacterEquipmentSlotView slot,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CharacterEquipmentDialog(
          character: character,
          slot: slot,
          onEquip: onEquip,
          onUnequip: onUnequip,
        );
      },
    );
  }
}
