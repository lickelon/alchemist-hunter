import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
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
    final Widget header = _EquipmentHeader(
      character: character,
      slot: slot,
      onUnequip: onUnequip,
    );
    final Widget itemList = _EquipmentItemList(
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

class _EquipmentHeader extends StatelessWidget {
  const _EquipmentHeader({
    required this.character,
    required this.slot,
    required this.onUnequip,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (slot.equippedItem == null)
          Text('현재 미장착', style: Theme.of(context).textTheme.bodyMedium)
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CatalogAssetIcon(
              assetPath: CatalogIconAssetPaths.equipment(
                slot.equippedItem!.blueprintId,
              ),
            ),
            title: Text(slot.equippedItem!.name),
            subtitle: Text(slot.statLabel),
            trailing: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onUnequip(character.id, slot.slot);
              },
              child: const Text('해제'),
            ),
          ),
        const Divider(),
        Text('보관 장비', style: AppTextStyles.of(context).subsectionTitle),
      ],
    );
  }
}

class _EquipmentItemList extends StatelessWidget {
  const _EquipmentItemList({
    required this.character,
    required this.slot,
    required this.onEquip,
    required this.showDetailDialog,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, String equipmentId) onEquip;
  final bool showDetailDialog;

  @override
  Widget build(BuildContext context) {
    if (slot.availableItems.isEmpty) {
      return const AppEmptyState('장착 가능한 장비가 없습니다');
    }
    return ResourceIconGrid(
      items: slot.availableItems.map((EquipmentInstance item) {
        final String actionLabel = slot.equippedItem == null ? '장착' : '교체';
        return ResourceIconGridItem(
          key: ValueKey<String>('character_equipment_${item.id}'),
          assetPath: CatalogIconAssetPaths.equipment(item.blueprintId),
          badgeLabel: _slotBadgeLabel(item.slot),
          semanticLabel: item.name,
          tooltipMessage: '${item.name}\n${item.detailLabel}',
          onTap: () {
            if (!showDetailDialog) {
              Navigator.of(context).pop();
              onEquip(character.id, item.id);
              return;
            }
            showDialog<void>(
              context: context,
              builder: (BuildContext dialogContext) {
                return _EquipmentDetailDialog(
                  item: item,
                  actionLabel: actionLabel,
                  onEquip: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                    onEquip(character.id, item.id);
                  },
                );
              },
            );
          },
        );
      }).toList(),
    );
  }
}

class _EquipmentDetailDialog extends StatelessWidget {
  const _EquipmentDetailDialog({
    required this.item,
    required this.actionLabel,
    required this.onEquip,
  });

  final EquipmentInstance item;
  final String actionLabel;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: item.name,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_slotLabel(item.slot)),
          const SizedBox(height: AppSpacing.sm),
          Text(item.statLabel),
          if (item.enchant != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text('인챈트 ${item.enchant!.label}'),
          ],
          if (item.totalStatModifiers.isNotEmpty ||
              item.totalModifiers.isNotEmpty ||
              item.totalPassives.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(item.effectLabel),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          label: const Text('닫기'),
        ),
        FilledButton(onPressed: onEquip, child: Text(actionLabel)),
      ],
    );
  }
}

String _slotBadgeLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.weapon => '무기',
    EquipmentSlot.armor => '방어구',
    EquipmentSlot.accessory => '장신구',
  };
}

String _slotLabel(EquipmentSlot slot) => '슬롯 ${_slotBadgeLabel(slot)}';
