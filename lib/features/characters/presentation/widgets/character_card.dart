import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_sheet.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.item,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterListItemView item;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    final CharacterProgress character = item.character;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              character.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Lv ${character.level} / Rank ${character.rank} / Tier ${character.tierIndex}',
            ),
            Text(
              'XP ${character.xp}/${character.xpToNextLevel} / MaxLv ${character.maxLevelForRank}',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: character.canRankUp ? () => onRankUp(character.id) : null,
                  child: const Text('Rank Up'),
                ),
                FilledButton.tonal(
                  onPressed: character.canTierUp ? () => onTierUp(character.id) : null,
                  child: const Text('Tier Up'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.rankHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              item.tierHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              '장비 슬롯',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...item.equipmentSlots.map((CharacterEquipmentSlotView slot) {
              final bool canManage =
                  slot.equippedItem != null || slot.availableItems.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${slot.slotLabel}: ${slot.currentLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot.statLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: canManage
                          ? () => _showEquipmentSheet(
                              context,
                              character: character,
                              slot: slot,
                            )
                          : null,
                      child: Text(slot.equippedItem == null ? '장착' : '관리'),
                    ),
                  ],
                ),
              );
            }),
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
