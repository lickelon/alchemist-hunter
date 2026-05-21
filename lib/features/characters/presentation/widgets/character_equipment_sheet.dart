import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
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
    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${character.name} / ${slot.slotLabel}',
        header: Column(
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
            const Text('보관 장비', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        body: slot.availableItems.isEmpty
            ? const Center(child: Text('장착 가능한 장비가 없습니다'))
            : ListView(
                children: slot.availableItems.map((EquipmentInstance item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CatalogAssetIcon(
                      assetPath: CatalogIconAssetPaths.equipment(
                        item.blueprintId,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.detailLabel),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEquip(character.id, item.id);
                      },
                      child: Text(slot.equippedItem == null ? '장착' : '교체'),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
