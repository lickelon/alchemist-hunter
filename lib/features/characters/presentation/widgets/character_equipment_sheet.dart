import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_header.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_item_grid.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';

class CharacterEquipmentSheet extends StatelessWidget {
  const CharacterEquipmentSheet({
    super.key,
    required this.character,
    required this.slot,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    return _CharacterEquipmentContent(
      character: character,
      slot: slot,
      onEquip: onEquip,
      onUnequip: onUnequip,
      presentation: _CharacterEquipmentPresentation.sheet,
    );
  }
}

class CharacterEquipmentDialog extends StatelessWidget {
  const CharacterEquipmentDialog({
    super.key,
    required this.character,
    required this.slot,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    return _CharacterEquipmentContent(
      character: character,
      slot: slot,
      onEquip: onEquip,
      onUnequip: onUnequip,
      presentation: _CharacterEquipmentPresentation.dialog,
    );
  }
}

enum _CharacterEquipmentPresentation { sheet, dialog }

class _CharacterEquipmentContent extends StatelessWidget {
  const _CharacterEquipmentContent({
    required this.character,
    required this.slot,
    required this.onEquip,
    required this.onUnequip,
    required this.presentation,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;
  final _CharacterEquipmentPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final Widget header = CharacterEquipmentHeader(
      character: character,
      slot: slot,
      onUnequip: onUnequip,
    );
    final Widget itemList = CharacterEquipmentItemGrid(
      character: character,
      slot: slot,
      onEquip: onEquip,
      showDetailDialog: presentation == _CharacterEquipmentPresentation.sheet,
    );

    if (presentation == _CharacterEquipmentPresentation.dialog) {
      return AppDialogLayout(
        title: '${character.name} / ${slot.slotLabel}',
        body: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.sizeOf(context).height * AppDialogHeights.medium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              header,
              const SizedBox(height: AppSpacing.md),
              Expanded(child: itemList),
            ],
          ),
        ),
      );
    }

    return AppSheetLayout(
      title: '${character.name} / ${slot.slotLabel}',
      header: header,
      body: itemList,
    );
  }
}
