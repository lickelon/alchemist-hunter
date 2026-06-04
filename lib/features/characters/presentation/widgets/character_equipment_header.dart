import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';

class CharacterEquipmentHeader extends StatelessWidget {
  const CharacterEquipmentHeader({
    super.key,
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
          const AppBadge(label: '미장착')
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CatalogAssetIcon(
              assetPath: CatalogIconAssetPaths.equipment(
                slot.equippedItem!.blueprintId,
              ),
            ),
            title: Text(slot.equippedItem!.name),
            subtitle: _EquipmentStatBadges(label: slot.statLabel),
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

class _EquipmentStatBadges extends StatelessWidget {
  const _EquipmentStatBadges({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _splitEquipmentLabel(
          label,
        ).map((String part) => AppBadge(label: part)).toList(growable: false),
      ),
    );
  }
}

Iterable<String> _splitEquipmentLabel(String label) {
  return label
      .split('\n')
      .first
      .split(' / ')
      .where((String part) => part.isNotEmpty);
}
